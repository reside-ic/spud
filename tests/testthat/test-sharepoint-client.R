context("sharepoint-client")

test_that("sharepoint client can initialize a connection", {
  ## Mock out sharepoint interactions
  security_token_res <- readRDS("mocks/security_token_response.rds")
  cookies_res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(security_token_res, cookies_res)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("httr::POST" = mock_post, {
      client <- sharepoint_client$new("https://example.com")
    })
  )

  mockery::expect_called(mock_post, 2)
  args <- mockery::mock_args(mock_post)[[1]]
  expect_equal(args[[1]],
               "https://login.microsoftonline.com/extSTS.srf")
  expect_true(grepl("<o:Username>user</o:Username>", args[[2]]))
  expect_true(grepl("<o:Password>pass</o:Password>", args[[2]]))
  expect_true(grepl("<a:Address>https://example.com</a:Address>", args[[2]]))

  args <- mockery::mock_args(mock_post)[[2]]
  expect_equal(args[[1]],
               "https://example.com/_forms/default.aspx?wa=wsignin1.0")
  expect_equal(args[[2]], "t=EXAMPLE_TOKEN==&p=")
  ## Handle has been setup to use sharepoint URL
  expect_s3_class(args[[3]], handle)
  expect_equal(args[[3]]$url, "https://example.com")
})

test_that("sharepoint client caches cookies between requests", {
  ## Mock out sharepoint interactions for initialising object
  security_token_res <- readRDS("mocks/security_token_response.rds")
  cookies_res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(security_token_res, cookies_res)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("httr::POST" = mock_post, {
      client <- sharepoint_client$new("https://httpbin.org")
    })
  )

  res <- client$GET("/cookies/set/test_cookie/123")
  cookies <- httr::cookies(res)
  expect_equal(cookies$name, "test_cookie")
  expect_equal(cookies$value, "123")

  ## client sends cookies on subsequent requests
  res <- client$GET("/cookies")
  content <- httr::content(res)
  expect_equal(content,
               list(cookies = list(
                 test_cookie = "123"
               )
  ))
})

test_that("sharepoint client handles errors", {

})

test_that("can construct security token payload", {
  creds <- list(
    username = "user@example.com",
    password = "password123"
  )
  payload <- prepare_security_token_payload("https://example.com", creds)

  expect_true(grepl("<o:Username>user@example.com</o:Username>", payload))
  expect_true(grepl("<o:Password>password123</o:Password>", payload))
  expect_true(grepl("<a:Address>https://example.com</a:Address>", payload))
})

test_that("can get security token from response", {
  res <- readRDS("mocks/security_token_response.rds")
  token <- parse_security_token_response(res)

  expect_equal(token, "t=EXAMPLE_TOKEN==&p=")
})
