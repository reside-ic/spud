context("credentials")

test_that("can get user auth credentials", {
  mock_get_pass <- mockery::mock("mock_cred", cycle = TRUE)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = NA, "SHAREPOINT_PASS" = NA),
    with_mock("getPass::getPass" = mock_get_pass, {
      creds <- get_credentials()
    })
  )
  expect_equal(creds, list(username = "mock_cred", password = "mock_cred"))
  mockery::expect_called(mock_get_pass, 2)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = NA),
    with_mock("getPass::getPass" = mock_get_pass, {
      creds <- get_credentials()
    })
  )
  expect_equal(creds, list(username = "user", password = "mock_cred"))
  mockery::expect_called(mock_get_pass, 3)

  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("getPass::getPass" = mock_get_pass, {
      creds <- get_credentials()
    })
  )
  expect_equal(creds, list(username = "user", password = "pass"))
  mockery::expect_called(mock_get_pass, 3)
})
