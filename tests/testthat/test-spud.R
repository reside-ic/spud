context("spud")


test_that("sharepoint passes args to sharepoint folder", {
  mock_download <- mockery::mock(NULL)
  mock_folder <- mockery::mock(NULL)
  mock_sharepoint_folder <- mockery::mock(list(
    download = mock_download,
    folder = mock_folder
  ))

  with_mock("spud::sharepoint_folder_new" = mock_sharepoint_folder, {
    sp <- sharepoint$new(site_name = "site")
  })

  mockery::expect_called(mock_sharepoint_folder, 1)
  args <- mockery::mock_args(mock_sharepoint_folder)[[1]]
  expect_equal(args[[1]]$site_name, "site")

  t <- tempfile()
  download <- sp$download("path/to/file", t)

  mockery::expect_called(mock_download, 1)
  args <- mockery::mock_args(mock_download)[[1]]
  expect_equal(args, list("path/to/file", t, FALSE))

  folder <- sp$folder("path")

  mockery::expect_called(mock_folder, 1)
  args <- mockery::mock_args(mock_folder)[[1]]
  expect_equal(args, list("path"))
})


test_that("sharepoint_download saves data to disk", {
  t <- tempfile()

  mock_download <- mockery::mock(t)
  mock_sharepoint_new <- mockery::mock(list(
      download = mock_download
  ))
  with_mock("spud::sharepoint_new" = mock_sharepoint_new, {
    download <- sharepoint_download(sharepoint_path = "/json", dest = t,
                                    site_name = "site")
  })

  expect_equal(download, t)
  mockery::expect_called(mock_sharepoint_new, 1)
  sharepoint_args <- mockery::mock_args(mock_sharepoint_new)[[1]]
  expect_equal(sharepoint_args, list(
    site_name = "site",
    site_url = NULL,
    site_id = NULL,
    tenant = NULL,
    app = NULL,
    scopes = NULL,
    auth = NULL
  ))

  mockery::expect_called(mock_download, 1)
  download_args <- mockery::mock_args(mock_download)[[1]]
  expect_equal(download_args, list(
    "/json",
    t,
    FALSE
  ))
})


test_that("sharepoint_new creates new sharepoint", {
  with_mock("Microsoft365R::get_sharepoint_site" = mock_get_sharepoint_site, {
    sp <- sharepoint_new(site_name = "site")
  })
  expect_is(sp, "sharepoint")
})
