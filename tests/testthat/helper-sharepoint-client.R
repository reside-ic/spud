#' Create a sharepoint client using mocks to skip authentication steps
#'
#' @return An authenticated sharepoint client with root url httpbin.org
#' @keywords internal
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
