sharepoint_client <- R6::R6Class(
  "sharepoint_client",
  cloneable = FALSE,

  public = list(
    sharepoint_url = NULL,

    initialize = function(sharepoint_url) {
      self$sharepoint_url <- sharepoint_url
      private$handle <- httr::handle(sharepoint_url)

      creds <- get_credentials()
      message("Authenticating user")
      response <- httr::POST(
        "https://login.microsoftonline.com/extSTS.srf",
        body = prepare_security_token_payload(self$sharepoint_url, creds))
      ## Note that httr preserves cookies and settings over multiple requests
      ## via the handle. Means that if we auth once and retrieve cookies httr
      ## will automatically send these on subsequent requests if usnig the same
      ## handle object
      security_token <- parse_security_token_response(response)
      message("Retrieving cookies")
      self$POST("_forms/default.aspx?wa=wsignin1.0", body = security_token)
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
