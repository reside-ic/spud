context("integration tests")

test_that("Basic operations", {
  folder <- integration_test_client()$folder
  tmp <- basename(tempfile())
  new <- folder$create(tmp)

  expect_equal(basename(new$path), tmp)
  expect_equal(new$parent()$path, folder$path)
  expect_equal(
    folder$list(tmp),
    tibble::tibble(name = character(),
                   items = numeric(),
                   size = numeric(),
                   is_folder = logical(),
                   created = to_time(character()),
                   modified = to_time(character())))

  path_txt <- tempfile()
  path_bin <- tempfile()
  writeLines(letters, path_txt)
  saveRDS(mtcars, path_bin)

  new$upload(path_txt, "letters.txt", progress = FALSE)
  new$upload(path_bin, "mtcars.rds", progress = FALSE)

  contents <- new$files()
  expect_equal(nrow(contents), 2)
  expect_setequal(contents$name, c("letters.txt", "mtcars.rds"))
  expect_equal(contents$size[contents$name == "mtcars.rds"],
               file.size(path_bin))
  expect_lt(contents$size[contents$name == "letters.txt"],
            contents$size[contents$name == "mtcars.rds"])

  ## Download text
  p <- new$download("letters.txt")
  expect_match(p, "\\.txt")
  expect_true(file.exists(p))
  expect_equal(normalizePath(dirname(p)), normalizePath(tempdir()))
  expect_identical(readLines(p), letters)

  ## Download binary
  p <- tempfile()
  expect_equal(new$download("mtcars.rds", p), p)
  expect_identical(readRDS(p), mtcars)

  contents <- folder$folders()
  expect_true(tmp %in% contents$name)
  i <- which(tmp == contents$name)
  expect_equal(contents$items[[i]], 2)

  expect_error(
    folder$delete(tmp, "nothere"),
    "The file 'nothere' was not found in the folder to delete '.+'")
  folder$delete(tmp, "letters.txt")
  expect_false(tmp %in% folder$folders()$name)
})
