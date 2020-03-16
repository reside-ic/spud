context("pointr")

test_that("get_security_token formats payload and parses response", {
  res <- readRDS("mocks/security_token_response.rds")
  mock_post <- mockery::mock(res)

  with_mock("httr::POST" = mock_post, {
    token <- get_security_token("https://example.com", "test_name", "test_pw")
  })

  ## Correct body was sent to endpoint
  mockery::expect_called(mock_post, 1)
  body_arg <- mockery::mock_args(mock_post)[[1]][[2]] # Second arg in first call
  expect_true(grepl("<o:Username>test_name</o:Username>", body_arg))
  expect_true(grepl("<o:Password>test_pw</o:Password>", body_arg))
  expect_true(grepl("<a:Address>https://example.com</a:Address>", body_arg))

  ## URL is correct
  expect_equal(mockery::mock_args(mock_post)[[1]][[1]],
               "https://login.microsoftonline.com/extSTS.srf")

  ## Pulled token out of response
  expect_equal(token, "t=EXAMPLE_TOKEN==&p=")
})

test_that("get_access_cookies retireves cookies using security token", {
  res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(res)

  with_mock("httr::POST" = mock_post, {
    cookies <- get_access_cookies("https://example.com", "example_token")
  })

  mockery::expect_called(mock_post, 1)
  args <- mockery::mock_args(mock_post)[[1]]
  expect_equal(args[[1]],
               "https://example.com/_forms/default.aspx?wa=wsignin1.0")
  expect_equal(args[[2]], "example_token")

  expected_cookies <- c(
    rtFa = "example_rtFa",
    FedAuth = "example_FedAuth",
    RpsContextCookie = "example_RpsContextCookie",
    SPWorkLoadAttribution = "example_SPWorkLoadAttribution"
  )
  expect_equal(cookies, expected_cookies)
})

test_that("download_data stores data to disk", {
  res <- readRDS("mocks/download_response.rds")
  mock_get <- mockery::mock(res)

  t <- tempfile()
  cookies <- c(
    RpsContextCookie = "example_RpsContextCookie",
    SPWorkLoadAttribution = "example_SPWorkLoadAttribution")
  with_mock("httr::GET" = mock_get, {
    response <- download_data(
      "https://example.com/sites/example/data/shape%20files/ex.zip", cookies, t)
  })

  mockery::expect_called(mock_get, 1)
  args <- mockery::mock_args(mock_get)[[1]]
  expect_equal(args[[1]],
               "https://example.com/sites/example/data/shape%20files/ex.zip")
  expect_equal(names(args[[2]]$options), "cookie")
  expect_equal(args[[2]]$options$cookie,
               "RpsContextCookie=example_RpsContextCookie;SPWorkLoadAttribution=example_SPWorkLoadAttribution")
  expect_equal(args[[3]]$output$path, t)
})
