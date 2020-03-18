context("pointr")

test_that("sharepoint_download saves data to disk", {
  ## Mock out authentication steps
  security_token_res <- readRDS("mocks/security_token_response.rds")
  cookies_res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(security_token_res, cookies_res)

  t <- tempfile()
  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("httr::POST" = mock_post, {
      download <- sharepoint_download("https://httpbin.org", "/json", t)
    })
  )

  expect_equal(download, t)
  ## Data has been successfully downloaded
  expect_true(file.exists(t))
  expect_true(file.size(t) > 0)
  expect_equal(readLines(t)[[1]], "{")
})
