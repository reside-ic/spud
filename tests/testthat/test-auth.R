test_that("auth object can be created", {
  with_emptyenv(auth <- sharepoint_auth())
  expect_is(auth, "sharepoint_auth")
  expect_equal(names(auth),
               c("site_name", "site_url", "site_id", "tenant", "app", "scopes"))
  expect_null(auth$site_name)
  expect_null(auth$site_url)
  expect_null(auth$site_id)
  expect_equal(auth$tenant, "common")
  expect_equal(auth$app, "")
  expect_equal(auth$scopes, c("Group.ReadWrite.All", "Directory.Read.All",
                              "Sites.Manage.All"))

  auth <- sharepoint_auth(site_name = "HIV Inference Group - WP",
                          site_url = "123",
                          site_id = "12345",
                          tenant = "imperiallondon",
                          app = "app_id",
                          scopes = c("scope1", "scope2"))
  expect_is(auth, "sharepoint_auth")
  expect_equal(names(auth),
               c("site_name", "site_url", "site_id", "tenant", "app", "scopes"))
  expect_equal(auth$site_name, "HIV Inference Group - WP")
  expect_equal(auth$site_url, "123")
  expect_equal(auth$site_id, "12345")
  expect_equal(auth$tenant, "imperiallondon")
  expect_equal(auth$app, "app_id")
  expect_equal(auth$scopes, c("scope1", "scope2"))
})

test_that("auth object can be created from env vars", {
  withr::with_envvar(list(
    "SHAREPOINT_SITE_NAME" = "site_name",
    "SHAREPOINT_SITE_URL" = "site_url",
    "SHAREPOINT_SITE_ID" = "site_id",
    "SHAREPOINT_TENANT" = "tenant",
    "SHAREPOINT_APP_ID" = "app_id"
  ), auth <- sharepoint_auth())

  expect_is(auth, "sharepoint_auth")
  expect_equal(names(auth),
               c("site_name", "site_url", "site_id", "tenant", "app", "scopes"))
  expect_equal(auth$site_name, "site_name")
  expect_equal(auth$site_url, "site_url")
  expect_equal(auth$site_id, "site_id")
  expect_equal(auth$tenant, "tenant")
  expect_equal(auth$app, "app_id")
})

test_that("auth object can be created from existing object", {
  with_emptyenv(auth <- sharepoint_auth(site_url = "http://example.com",
                                        tenant = "example"))

  auth <- sharepoint_auth(site_url = "http://example.org",
                          auth = auth)
  expect_is(auth, "sharepoint_auth")
  expect_null(auth$site_name)
  expect_equal(auth$site_url, "http://example.org")
  expect_null(auth$site_id)
  expect_equal(auth$tenant, "example")
  expect_equal(auth$app, "")
  expect_equal(auth$scopes, c("Group.ReadWrite.All", "Directory.Read.All",
                              "Sites.Manage.All"))
})
