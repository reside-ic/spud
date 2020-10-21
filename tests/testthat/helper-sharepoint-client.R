#' Create a sharepoint client using mocks to skip authentication steps
#'
#' @return An authenticated sharepoint client with root url httpbin.org
#' @keywords internal
#' @noRd
mock_sharepoint_client <- function(sharepoint_url, set_cookies = FALSE) {
  security_token_res <- readRDS("mocks/security_token_response.rds")
  cookies_res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(security_token_res, cookies_res)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("httr::POST" = mock_post, {
      client <- sharepoint_client$new(sharepoint_url)
    })
  )

  if (set_cookies) {
    handle <- r6_private(client)$handle
    set_cookies(handle, cookies_res)
  }

  client
}


mock_sharepoint <- function(sharepoint_url) {
  security_token_res <- readRDS("mocks/security_token_response.rds")
  cookies_res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(security_token_res, cookies_res)
  t <- tempfile()
  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("httr::POST" = mock_post, {
      sharepoint$new("https://httpbin.org")
    })
  )
}


mock_response <- function(status_code = 200L) {
  structure(
    list(status_code = status_code),
    class = "response")
}


mock_download_client <- function() {
  list(GET = function(url, ...)
    httr::GET(paste0("https://httpbin.org", url), ...))
}


strip_url <- function(x) {
  gsub("https://[^/]+/sites/[^/]+/", "https://example.com/sites/mysite/", x)
}


strip_site <- function(x) {
  gsub("/sites/[^/]+/", "/sites/mysite/", x)
}

strip_response <- function(r) {
  r$url <- sub("https://.*?/sites/.*?/",
               "https://example.com/sites/mysite/", r$url)
  r$headers <- NULL
  r$all_headers <- NULL
  r$cookies <- NULL
  r$request <- NULL
  r$handle <- NULL
  r
}


r6_private <- function(x) {
  environment(x$initialize)$private
}


## This is super difficult to because curl does not have a way of
## setting cookies on a handle.  So we fudge it:
set_cookies <- function(handle, data) {
  cookies <- setNames(as.list(data$cookies$value), data$cookies$name)
  httr::GET("https://httpbin.org/cookies/set", query = cookies,
            handle = handle)
}
