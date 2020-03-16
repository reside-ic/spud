pointr_download <- function(root_url, data_path, username, path) {
  ## Get security token
  token <- get_security_token(root_url, username, password)

  ## Get access cookies
  access_cookies <- get_access_cookies(root_url, token)

  ## Get data
  download_data(paste(root_url, data_path, sep = "/"), access_cookies, path)
}

get_access_cookies <- function(root_url, security_token) {
  ## This looks like it is caching? If I do a successful post to this then next
  ## time if I do it I can call without any security token and get a response
  ## Is httr caching? Looks like it as this went on a fresh R session
  cookie_url <- paste(root_url, "_forms/default.aspx?wa=wsignin1.0", sep = "/")
  ## Note that httr preserves cookies and settings over multiple requests
  ## via handle see ?httr::handle
  ## This means that if users successfully authenticate once then re-running
  ## this httr will send those auth cookies to this URL which passes auth checks
  ## meaning that users can type in their pw incorrectly but still successfully
  ## retrieve data
  ## We should probably check for presence of required cookies before we ask
  ## for pws again.
  response <- httr::POST(cookie_url, body = security_token)
  cookies <- httr::cookies(response)
  setNames(cookies$value, cookies$name)
}

download_data <- function(url, cookies, path) {
  ## TODO: Separate path here and send the data to get as a parameter
  ## this will handle any encoding needed
  x <- httr::GET(url, httr::set_cookies(cookies), httr::write_disk(path))
  browser()
  x
  ## Error handling!
  ## Will return with status 403
}
