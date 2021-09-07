context("sharepoint_folder")

test_that("list files", {
  folder <- test_folder()
  expect_is(folder, "sharepoint_folder")

  dat <- folder$files()
  expect_is(dat, "data.frame")
  expect_setequal(names(dat), c("name", "size", "isdir", "created", "modified"))
  expect_equal(dat$name, "testing.md")

  mockery::expect_called(folder$drive$list_items, 1)
  expect_equal(
    mockery::mock_args(folder$drive$list_items)[[1]],
    list("/", info = "all"))
})


test_that("list folders", {
  folder <- test_folder()
  expect_is(folder, "sharepoint_folder")

  dat <- folder$folders()
  expect_is(dat, "data.frame")
  expect_setequal(names(dat), c("name", "size", "isdir", "created", "modified"))
  expect_equal(dat$name, "folder")

  mockery::expect_called(folder$drive$list_items, 1)
  expect_equal(
    mockery::mock_args(folder$drive$list_items)[[1]],
    list("/", info = "all"))
})


test_that("list everything", {
  folder <- test_folder()
  expect_is(folder, "sharepoint_folder")

  dat <- folder$list()
  expect_is(dat, "data.frame")
  expect_setequal(names(dat), c("name", "size", "isdir", "created", "modified"))
  expect_setequal(dat$name, c("folder", "testing.md"))

  mockery::expect_called(folder$drive$list_items, 1)
  expect_equal(
    mockery::mock_args(folder$drive$list_items)[[1]],
    list("/", info = "all"))
})


test_that("get child & parent directories", {
  folder <- test_folder()
  expect_equal(folder$path, "/")

  ## Parent of root is root again
  with_mock("Microsoft365R::get_sharepoint_site" = mock_get_sharepoint_site, {
    parent <- folder$parent()
  })
  expect_equal(parent$path, "/")

  with_mock("Microsoft365R::get_sharepoint_site" = mock_get_sharepoint_site, {
    child <- folder$folder("path/to")
  })
  expect_equal(child$path, "//path/to")

  with_mock("Microsoft365R::get_sharepoint_site" = mock_get_sharepoint_site, {
    child2 <- child$folder("folder")
  })
  expect_equal(child2$path, "//path/to/folder")

  with_mock("Microsoft365R::get_sharepoint_site" = mock_get_sharepoint_site, {
    parent <- child2$parent()
  })
  expect_equal(parent$path, "//path/to")

  with_mock("Microsoft365R::get_sharepoint_site" = mock_get_sharepoint_site, {
    parent2 <- parent$parent()
  })
  expect_equal(parent2$path, "//path")

  with_mock("Microsoft365R::get_sharepoint_site" = mock_get_sharepoint_site, {
    parent3 <- parent2$parent()
  })
  expect_equal(parent3$path, "/")
})


test_that("download from folder", {
  folder <- test_folder()
  res <- folder$download("file.txt")

  expect_match(res, "\\.txt$")
  mockery::expect_called(folder$drive$get_item, 1)
  expect_equal(mockery::mock_args(folder$drive$get_item)[[1]],
               list("file.txt"))

  item <- folder$drive$get_item()
  mockery::expect_called(item$download, 1)
  expect_equal(mockery::mock_args(item$download)[[1]],
               list(
                 dest = res,
                 overwrite = FALSE
               ))

  res2 <- folder$download("file.txt", dest = "dest_file.txt", overwrite = TRUE)

  expect_equal(res2, "dest_file.txt")
  mockery::expect_called(folder$drive$get_item, 3)
  expect_equal(mockery::mock_args(folder$drive$get_item)[[3]],
               list("file.txt"))

  mockery::expect_called(item$download, 2)
  expect_equal(mockery::mock_args(item$download)[[2]],
               list(
                 dest = res2,
                 overwrite = TRUE
               ))
})


test_that("upload", {
  folder <- test_folder()
  folder$upload("file.txt", "destination/file")

  mockery::expect_called(folder$drive$upload, 1)
  expect_equal(
    mockery::mock_args(folder$drive$upload)[[1]],
    list("file.txt", "destination/file"))
})


test_that("create folder", {
  folder <- test_folder()
  with_mock("Microsoft365R::get_sharepoint_site" = mock_get_sharepoint_site, {
    res <- folder$create("path/to/folder")
  })

  mockery::expect_called(folder$drive$create_folder, 1)
  expect_equal(
    mockery::mock_args(folder$drive$create_folder)[[1]],
    list("path/to/folder"))

  expect_equal(res$path, "//path/to/folder")
})


test_that("delete folder", {
  folder <- test_folder()
  folder$delete("d/e", TRUE)

  mockery::expect_called(folder$drive$get_item, 1)
  expect_equal(mockery::mock_args(folder$drive$get_item)[[1]],
               list("d/e"))

  item <- folder$drive$get_item()
  mockery::expect_called(item$delete, 1)
  expect_equal(mockery::mock_args(item$delete)[[1]],
               list(confirm = TRUE))
})
