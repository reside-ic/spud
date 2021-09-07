test_that("sharepoint folder", {
  testthat::skip_if_not(interactive())
  auth <- sharepoint_auth()
  folder <- sharepoint_folder$new(auth)
  expect_equal(folder$path, "/")
  sub <- folder$create("spud-test")
  expect_equal(sub$path, "//spud-test")
  sub$upload("mocks/README.md", "testing.md")
  all_items <- sub$list()
  expect_equal(nrow(all_items), 1)
  files <- sub$files()
  expect_equal(nrow(files), 1)
  folders <- sub$folders()
  expect_equal(nrow(folders), 0)
  t <- sub$download("testing.md")
  expect_true(file.exists(t))
  expect_equivalent(tools::md5sum(t), tools::md5sum("mocks/README.md"))
  parent <- sub$parent()
  parent$delete("spud-test", check = FALSE)
  all_items <- parent$list()
  expect_false(any(grepl("spud-test", all_items$name)))
})

test_that("sharepoint download", {
  testthat::skip_if_not(interactive())
  auth <- sharepoint_auth()
  sp <- sharepoint$new(site_url = auth$site_url,
                       tenant = auth$tenant,
                       app = auth$app)

  expect_equal(sp$client$path, "/")

  ## Create a folder & upload a file to test downloading
  sub <- sp$client$create("spud-test")
  expect_equal(sub$path, "//spud-test")
  sub$upload("mocks/README.md", "testing.md")
  all_items <- sub$list()
  expect_equal(nrow(all_items), 1)

  t <- sp$download("spud-test/testing.md")
  expect_true(file.exists(t))
  expect_equivalent(tools::md5sum(t), tools::md5sum("mocks/README.md"))

  ## Via main download function
  t2 <- sharepoint_download("spud-test/testing.md",
                            site_url = auth$site_url,
                            tenant = auth$tenant,
                            app = auth$app)
  expect_true(file.exists(t2))
  expect_equivalent(tools::md5sum(t2), tools::md5sum("mocks/README.md"))

  ## Cleanup
  sp$client$delete("spud-test", check = FALSE)
  all_items <- sp$client$list()
  expect_false(any(grepl("spud-test", all_items$name)))
})
