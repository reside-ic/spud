pointr_download <- function(root_url, data_path, username, password, path) {
  ## Get security token
  token <- get_security_token(root_url, username, password)

  ## Get access cookies
  access_cookies <- get_access_cookies(root_url, token)

  ## Get request digest?
  ## Is this necessary?

  ## Get data
  download_data(paste(root_url, data_path, sep = "/"), access_cookies, path)
}

get_security_token <- function(root_url, username, password) {
  payload <- paste(readLines(system.file("security_token_request.xml",
                                   package = "pointr")),
                   collapse = "\n")
  payload <- glue::glue(payload, root_url = root_url, username = username,
                        password = password)
  response <- httr::POST("https://login.microsoftonline.com/extSTS.srf",
                    body = payload)
  browser()
  xml <- httr::content(response, "text", "text/xml", encoding = "UTF-8")
  parsed_xml <- xml2::read_xml(xml)
  token_node <- xml2::xml_find_first(parsed_xml, "//wsse:BinarySecurityToken")
  token <- xml2::xml_text(token_node)
}

get_access_cookies <- function(root_url, security_token) {
  cookie_url <- paste(root_url, "_forms/default.aspx?wa=wsignin1.0", sep = "/")
  response <- httr::POST(cookie_url, body = security_token)
  cookies <- httr::cookies(response)
  setNames(cookies$name, cookies$value)
}

download_data <- function(url, cookies, path) {
  httr::GET(url, httr::set_cookies(cookies), httr::write_disk(path))
}
