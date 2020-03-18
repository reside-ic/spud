sharepoint_client <- R6::R6Class(
  "sharepoint_client",
  cloneable = FALSE,

  public = list(
    sharepoint_url = NULL,

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

    GET = function(...) {
      self$request(httr::GET, ...)
    },

    POST = function(...) {
      self$request(httr::POST, ...)
    },

    request = function(verb, path, ...) {
      url <- paste(self$sharepoint_url, path, sep = "/")
      verb(url, ..., handle = private$handle)
    }
  ),

  private = list(
    handle = NULL
  )
)

prepare_security_token_payload <- function(url, credentials) {
  payload <- paste(readLines(system.file("security_token_request.xml",
                                         package = "pointr")),
                   collapse = "\n")
  glue::glue(payload, root_url = url,
             username = credentials$username,
             password = credentials$password)
}

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
