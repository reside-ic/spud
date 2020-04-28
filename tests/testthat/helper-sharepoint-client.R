#' Create a sharepoint client using mocks to skip authentication steps
#'
#' @return An authenticated sharepoint client with root url httpbin.org
#' @keywords internal
#' @noRd
mock_sharepoint_client <- function(sharepoint_url) {
  security_token_res <- readRDS("mocks/security_token_response.rds")
  cookies_res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(security_token_res, cookies_res)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("httr::POST" = mock_post, {
      client <- sharepoint_client$new(sharepoint_url)
    })
  )
  client
}


mock_pointr <- function(sharepoint_url) {
  security_token_res <- readRDS("mocks/security_token_response.rds")
  cookies_res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(security_token_res, cookies_res)
  t <- tempfile()
  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("httr::POST" = mock_post, {
      pointr$new("https://httpbin.org")
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
