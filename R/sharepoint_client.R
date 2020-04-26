#' Create sharepoint client, to manage HTTP requests to sharepoint.
#'
#' @keywords internal
#' @noRd
sharepoint_client <- R6::R6Class(
  "sharepoint_client",
  cloneable = FALSE,

  public = list(
    sharepoint_url = NULL,

    #' @description
    #' Create client object for sending http requests to sharepoint.
    #'
    #' This manages authenticating with sharepoint via sending credentails to
    #' microsoft to retrieve an access token which it then sends to sharepoint
    #' to retrieve cookies used for subsequent authentication.
    #'
    #' @param sharepoint_url Root URL of sharepoint site to download from
    #' @return A new `sharepoint_client` object
    initialize = function(sharepoint_url) {
      self$sharepoint_url <- sharepoint_url
      private$handle <- httr::handle(sharepoint_url)

      creds <- get_credentials()
      response <- httr::POST(
        "https://login.microsoftonline.com/extSTS.srf",
        body = prepare_security_token_payload(self$sharepoint_url, creds))
      ## Not sure if this ever returns a non 200 response but left here to
      ## be safe. On failed auth it sends a different set of xml but still 200
      if (response$status_code != 200) {
        stop(sprintf("Failed to authenticate user '%s'.", creds$username))
      }
      ## Note that httr preserves cookies and settings over multiple requests
      ## via the handle. Means that if we auth once and retrieve cookies httr
      ## will automatically send these on subsequent requests if using the same
      ## handle object
      security_token <- parse_security_token_response(response)
      if (is.na(security_token)) {
        stop(sprintf("Failed to retrieve security token for user '%s'.",
                     creds$username))
      }
      res <- self$POST("_forms/default.aspx?wa=wsignin1.0",
                       body = security_token)
      validate_cookies(res)
    },

    #' @description
    #' Send GET request to sharepoint
    #'
    #' @param ... Args passed on to httr
    #'
    #' @return HTTP response
    GET = function(...) {
      self$request(httr::GET, ...)
    },

    #' @description
    #' Send POST request to sharepoint
    #'
    #' @param ... Args passed on to httr
    #'
    #' @return HTTP response
    POST = function(...) {
      self$request(httr::POST, ...)
    },

    #' @description
    #' Send POST request to sharepoint
    #'
    #' @param verb A httr function for type of request to send e.g. httr::GET
    #' @param path Request path
    #' @param ... Additional args passed on to httr
    #'
    #' @return HTTP response
    request = function(verb, path, ...) {
      url <- paste(self$sharepoint_url, path, sep = "/")
      verb(url, ..., handle = private$handle)
    },

    digest = function(site) {
      url <- sprintf("/sites/%s/_api/contextinfo", site)
      r <- self$POST(url, httr::accept_json())
      httr::stop_for_status(r)
      dat <- response_from_json(r)
      httr::add_headers("X-RequestDigest" = dat$FormDigestValue)
    }
  ),

  private = list(
    handle = NULL
  )
)

#' Prepare payload for retrieving security token
#'
#' @param url URL for site you are requesting a token for
#' @param credentials Username and password for site request token
#'
#' @return Formatted xml body for security token request
#' @keywords internal
#' @noRd
prepare_security_token_payload <- function(url, credentials) {
  payload <- paste(readLines(pointr_file("security_token_request.xml")),
                   collapse = "\n")
  glue::glue(payload, root_url = url,
             username = credentials$username,
             password = credentials$password)
}

#' Parse response from security token request
#'
#' This takes the full response and pulls out the part of the xml containing
#' the security token.
#'
#' @param response httr response object
#'
#' @return The security token or NA if failed to retrieve
#' @keywords internal
#' @noRd
parse_security_token_response <- function(response) {
  xml <- httr::content(response, "text", "text/xml", encoding = "UTF-8")
  parsed_xml <- xml2::read_xml(xml)
  token_node <- xml2::xml_find_first(parsed_xml, "//wsse:BinarySecurityToken")
  xml2::xml_text(token_node)
}

#' Validate cookies in response
#'
#' To be able to use cookies in subsequent requests to sharepoint we
#' require the rtFa and FedAuth cookies to be set
#'
#' @param response
#'
#' @return Invisible TRUE if valid, error otherwise
#' @keywords internal
#' @noRd
validate_cookies <- function(response) {
  cookies <- httr::cookies(response)
  if (!(all(c("rtFa", "FedAuth") %in% cookies$name))) {
    stop(sprintf("Failed to retrieve all required cookies from URL '%s'.
Must provide rtFa and FedAuth cookies, got %s",
                 response$url,
                 paste(cookies$name, collapse = ", ")))
  }
  invisible(TRUE)
}
