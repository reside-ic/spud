context("credentials")

test_that("can get user auth credentials", {
  mock_read_cred <- mockery::mock("mock_cred", cycle = TRUE)
  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = NA, "SHAREPOINT_PASS" = NA),
    with_mock("getPass::getPass" = mock_read_cred,
              "spud:::get_string" = mock_read_cred, {
      creds <- get_credentials()
    })
  )
  expect_equal(creds, list(username = "mock_cred", password = "mock_cred"))
  mockery::expect_called(mock_read_cred, 2)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = NA),
    with_mock("getPass::getPass" = mock_read_cred,
              "spud:::get_string" = mock_read_cred, {
      creds <- get_credentials()
    })
  )
  expect_equal(creds, list(username = "user", password = "mock_cred"))
  mockery::expect_called(mock_read_cred, 3)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("getPass::getPass" = mock_read_cred,
              "spud:::get_string" = mock_read_cred, {
      creds <- get_credentials()
    })
  )
  expect_equal(creds, list(username = "user", password = "pass"))
  mockery::expect_called(mock_read_cred, 3)
})

test_that("error thrown if no credential entered by user", {
  read_cred <- function(msg) NA
  ## Mock interactive to default true so we can test this behaviour during tests
  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = NA),
    expect_error(
      get_single_credential("SHAREPOINT_USERNAME", "username", read_cred),
      "'username' must be a character, either set env var SHAREPOINT_USERNAME or enter at prompt"
    ))
})
