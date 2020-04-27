context("sharepoint_folder")

test_that("list files", {
  p <- mock_pointr()
  folder <- p$folder("site", "path")
  expect_is(folder, "sharepoint_folder")

  folder_files_res <- readRDS("mocks/folder_files_response.rds")
  mock_get <- mockery::mock(folder_files_res)
  dat <- with_mock("httr::GET" = mock_get,
                   folder$files())
  expect_is(dat, "tbl_df")
  expect_equal(names(dat), c("name", "size", "created", "modified"))
  expect_equal(dat$name, c("clipboard.txt", "test.txt"))
})


test_that("list folders", {
  p <- mock_pointr()
  folder <- p$folder("site", "path")
  expect_is(folder, "sharepoint_folder")

  folder_folder_res <- readRDS("mocks/folder_folders_response.rds")
  mock_get <- mockery::mock(folder_folder_res)
  dat <- with_mock("httr::GET" = mock_get,
                   folder$folders())
  expect_is(dat, "tbl_df")
  expect_equal(names(dat), c("name", "items", "created", "modified"))
  expect_equal(dat$name, c("data_offers", "administration_station"))
})


test_that("list everything", {
  p <- mock_pointr()
  folder <- p$folder("site", "path")
  expect_is(folder, "sharepoint_folder")

  folder_files_res <- readRDS("mocks/folder_files_response.rds")
  folder_folders_res <- readRDS("mocks/folder_folders_response.rds")
  mock_get <- mockery::mock(folder_folders_res, folder_files_res)

  dat <- with_mock("httr::GET" = mock_get, folder$list())
  expect_is(dat, "tbl_df")
  expect_equal(names(dat),
               c("name", "items", "size", "is_folder", "created", "modified"))
  expect_equal(dat$name, c("data_offers", "administration_station",
                           "clipboard.txt", "test.txt"))
})


test_that("get parent directory", {
  p <- mock_pointr()
  folder <- p$folder("site", "a/b/c")
  parent <- folder$parent()
  expect_equal(r6_private(parent)$path, "a/b")
  expect_equal(r6_private(parent$parent()$parent())$path, ".")
})


test_that("get child directory", {
  p <- mock_pointr()
  folder <- p$folder("site", "a")
  child <- folder$folder("b")$folder("c")
  expect_is(folder, "sharepoint_folder")
  expect_equal(r6_private(child)$path, "a/b/c")
})


test_that("download from folder", {
  p <- mock_pointr()
  folder <- p$folder("site", "a/b/c")

  mock_get <- mockery::mock(mock_response())
  res <- with_mock(
    "httr::GET" = mock_get,
    folder$download("file.txt"))

  expect_match(res, "\\.txt$")
  mockery::expect_called(mock_get, 1)
  expect_equal(
    mockery::mock_args(mock_get)[[1]][[1]],
    paste0("https://httpbin.org//sites/site/_api/web/",
           "GetFolderByServerRelativeURL('a/b/c')/Files('file.txt')/$value"))
})


test_that("download from subdirectory", {
  p <- mock_pointr()
  folder <- p$folder("site", "a/b")

  mock_get <- mockery::mock(mock_response())
  res <- with_mock(
    "httr::GET" = mock_get,
    folder$download("c/file.txt"))

  expect_match(res, "\\.txt$")
  mockery::expect_called(mock_get, 1)
  expect_equal(
    mockery::mock_args(mock_get)[[1]][[1]],
    paste0("https://httpbin.org//sites/site/_api/web/",
           "GetFolderByServerRelativeURL('a/b/c')/Files('file.txt')/$value"))
})


test_that("download from folder fails with informative message if missing", {
  p <- mock_pointr()
  folder <- p$folder("site", "a/b/c")

  mock_get <- mockery::mock(mock_response(404))
  expect_error(
    with_mock("httr::GET" = mock_get, folder$download("file.txt")),
    "Remote file not found at 'site:a/b/c/file.txt'")

  mockery::expect_called(mock_get, 1)
  expect_equal(
    mockery::mock_args(mock_get)[[1]][[1]],
    paste0("https://httpbin.org//sites/site/_api/web/",
           "GetFolderByServerRelativeURL('a/b/c')/Files('file.txt')/$value"))
})


test_that("upload", {
  p <- mock_pointr()
  folder <- p$folder("site", "a/b/c")

  contextinfo_res <- readRDS("mocks/contextinfo_response.rds")
  mock_post <- mockery::mock(contextinfo_res, mock_response(200))
  tmp <- tempfile()
  writeLines("content", tmp)

  res <- with_mock(
    "httr::POST" = mock_post,
    folder$upload(tmp, "file.txt"))
  expect_null(res)

  mockery::expect_called(mock_post, 2)
  expect_equal(
    mockery::mock_args(mock_post)[[1]][[1]],
    "https://httpbin.org//sites/site/_api/contextinfo")

  expect_equal(
    mockery::mock_args(mock_post)[[2]][[1]],
    paste0("https://httpbin.org//sites/site/_api/web/",
           "GetFolderByServerRelativeURL('a/b/c')/Files/",
           "Add(url='file.txt',overwrite=true)"))
})


test_that("upload to subdirectory", {
  p <- mock_pointr()
  folder <- p$folder("site", "a/b")

  contextinfo_res <- readRDS("mocks/contextinfo_response.rds")
  mock_post <- mockery::mock(contextinfo_res, mock_response(200))
  tmp <- tempfile()
  writeLines("content", tmp)

  res <- with_mock(
    "httr::POST" = mock_post,
    folder$upload(tmp, "c/file.txt"))
  expect_null(res)

  mockery::expect_called(mock_post, 2)
  expect_equal(
    mockery::mock_args(mock_post)[[1]][[1]],
    "https://httpbin.org//sites/site/_api/contextinfo")

  expect_equal(
    mockery::mock_args(mock_post)[[2]][[1]],
    paste0("https://httpbin.org//sites/site/_api/web/",
           "GetFolderByServerRelativeURL('a/b/c')/Files/",
           "Add(url='file.txt',overwrite=true)"))
})


test_that("verify folder exists", {
  p <- mock_pointr()
  mock_get <- mockery::mock(mock_response(200), mock_response(404))

  expect_is(
    with_mock("httr::GET" = mock_get,
              p$folder("site", "a/b/c", verify = TRUE)),
    "sharepoint_folder")
  expect_error(
    with_mock("httr::GET" = mock_get,
              p$folder("site", "a/b/c", verify = TRUE)),
    "Path 'a/b/c' was not found on site 'site'")

  mockery::expect_called(mock_get, 2)
  expect_equal(
    mockery::mock_args(mock_get)[[1]][[1]],
    paste0("https://httpbin.org//sites/site/_api/web/",
           "GetFolderByServerRelativeURL('a/b/c')"))
  expect_equal(
    mockery::mock_args(mock_get)[[2]][[1]],
    mockery::mock_args(mock_get)[[1]][[1]])
})
