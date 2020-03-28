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

test_that("download encodes URL", {
  ## Mock out authentication steps
  security_token_res <- readRDS("mocks/security_token_response.rds")
  cookies_res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(security_token_res, cookies_res)

  mock_get <- mockery::mock(mock_response())

  t <- tempfile()
  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("httr::POST" = mock_post,
              "httr::GET" = mock_get, {
      download <- sharepoint_download("https://httpbin.org",
                                      "anything/any thing", t)
    })
  )

  mockery::expect_called(mock_get, 1)
  expect_equal(mockery::mock_args(mock_get)[[1]][[1]],
               "https://httpbin.org/anything/any%20thing")
})

test_that("httr download can print verbose output", {
  ## Mock out authentication steps
  security_token_res <- readRDS("mocks/security_token_response.rds")
  cookies_res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(security_token_res, cookies_res)

  mock_get <- mockery::mock(mock_response())

  t <- tempfile()
  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("httr::POST" = mock_post,
              "httr::GET" = mock_get, {
                download <- sharepoint_download("https://httpbin.org",
                                                "anything/any thing", t, TRUE)
              })
  )

  mockery::expect_called(mock_get, 1)
  expect_equal(mockery::mock_args(mock_get)[[1]][[1]],
               "https://httpbin.org/anything/any%20thing")
  expect_equal(mockery::mock_args(mock_get)[[1]][[2]],
               httr::verbose())
})

test_that("sharepoint_download errors on 404", {
  ## Mock out authentication steps
  security_token_res <- readRDS("mocks/security_token_response.rds")
  cookies_res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(security_token_res, cookies_res)

  t <- tempfile()
  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("httr::POST" = mock_post, {
      expect_error(
        sharepoint_download("https://httpbin.org", "/status/404", t),
        "Remote file not found at '/status/404'")
    })
  )

  expect_false(file.exists(t))
})
