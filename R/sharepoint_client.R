sharepoint_client <- R6::R6Class(
  "sharepoint_client",
  cloneable = FALSE,

  public = list(
    initialize = function(sharepoint_url) {
      ## Do the exchange to get cookies for hintr -

      ## TBD: Managing handler - we could enable a client to have a handle
      ## associated with it and manage here. This can be cleared for each test
      ## giving us fresh auth stuff

    },

    GET = function(...) {
      ## GET
    },

    POST = function(...) {
      ## POST to some URL
    },

    request = function(verb, path, ...) {
      ## Handle a generic request via GET or POST
    }
  ),

)

get_security_token <- function(root_url) {
  payload <- paste(readLines(system.file("security_token_request.xml",
                                         package = "pointr")),
                   collapse = "\n")
  creds <- get_credentials()
  payload <- glue::glue(payload, root_url = root_url, username = creds$username,
                        password = creds$password)
  response <- httr::POST("https://login.microsoftonline.com/extSTS.srf",
                         body = payload)
  xml <- httr::content(response, "text", "text/xml", encoding = "UTF-8")
  parsed_xml <- xml2::read_xml(xml)
  token_node <- xml2::xml_find_first(parsed_xml, "//wsse:BinarySecurityToken")
  xml2::xml_text(token_node)
}
