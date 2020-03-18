context("credentials")

test_that("can get user auth credentials", {
  mock_get_pass <- mockery::mock("mock_cred", cycle = TRUE)
  ## Mock interactive to default true so we can test this behaviour during tests
  mock_interactive <- mockery::mock(TRUE, cycle = TRUE)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = NA, "SHAREPOINT_PASS" = NA),
    with_mock("getPass::getPass" = mock_get_pass,
              "pointr:::is_interactive" = mock_interactive, {
      creds <- get_credentials()
    })
  )
  expect_equal(creds, list(username = "mock_cred", password = "mock_cred"))
  mockery::expect_called(mock_get_pass, 2)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = NA),
    with_mock("getPass::getPass" = mock_get_pass,
              "pointr:::is_interactive" = mock_interactive, {
      creds <- get_credentials()
    })
  )
  expect_equal(creds, list(username = "user", password = "mock_cred"))
  mockery::expect_called(mock_get_pass, 3)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("getPass::getPass" = mock_get_pass,
              "pointr:::is_interactive" = mock_interactive, {
      creds <- get_credentials()
    })
  )
  expect_equal(creds, list(username = "user", password = "pass"))
  mockery::expect_called(mock_get_pass, 3)
})

test_that("error thrown if no credential entered by user", {
  mock_get_pass <- mockery::mock(NA)
  ## Mock interactive to default true so we can test this behaviour during tests
  mock_interactive <- mockery::mock(TRUE, cycle = TRUE)
  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = NA),
    with_mock("getPass::getPass" = mock_get_pass,
              "pointr:::is_interactive" = mock_interactive, {
      expect_error(
        get_single_credential("SHAREPOINT_USERNAME", "username"),
        "Failed to retrieve username, either set env var SHAREPOINT_USERNAME or enter in interactive session"
      )
    })
  )
})
