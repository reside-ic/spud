context("utils")

test_that("clean input text", {
  expect_equal(clean_input_text('"foo"'), "foo") # strip quotes
  expect_equal(clean_input_text('  foo'), "foo") # strip leading whitespace
  expect_equal(clean_input_text('foo  '), "foo") # strip trailing whitespace
  expect_equal(clean_input_text(' foo '), "foo") # strip all whitespace
  expect_equal(clean_input_text(' "foo" '), "foo") # strip all whitespace/quotes
  expect_equal(clean_input_text(" 'foo' "), "foo") # strip all whitespace/quotes
  ## But allow use of quotes to preserve whitespace
  expect_equal(clean_input_text(' " foo " '), " foo ")
  expect_equal(clean_input_text(" ' foo ' "), " foo ")
  expect_equal(clean_input_text("f oo"), "f oo")
})

test_that("asserts", {
  expect_error(assert_scalar_character(c("one", "two"), "test"),
               "'test' must be a scalar")
  expect_error(assert_scalar_character(1, "test"),
               "'test' must be a character")
  expect_error(assert_scalar_character(NA_character_, "test"),
               "'test' must not be NA")
  expect_error(assert_scalar_character("", "test"),
               "'test' must be nonempty")
})

test_that("tempfile_inherit_ext", {

  tmpf <- tempfile_inherit_ext("jibberish.wahoo")
  expect_equal(tools::file_ext(tmpf), "wahoo")
  expect_equal(dirname(tmpf), tempdir())

  tmpf2 <- tempfile_inherit_ext("jibberish")
  expect_equal(tools::file_ext(tmpf2), "")
})


test_that("download filename validation", {
  expect_equal(download_dest("a.x", "b.y"), "a.x")
  expect_equal(download_dest(raw(), "b.y"), raw())
  expect_match(download_dest(NULL, "b.y"), "\\.y$")
  expect_error(download_dest(1, "b.y"),
               "'dest' must be a character")
  expect_error(download_dest(c("a", "b"), "b.y"),
               "'dest' must be a scalar")
  expect_error(download_dest(NA_character_, "b.y"),
               "'dest' must not be NA")
})


test_that("Can download raw data", {
  client <- mock_download_client()
  res <- download(client, "/gzip", raw(), "my.zip", FALSE, FALSE)
  expect_is(res, "raw")
})


test_that("Can create a helpful temp name", {
  client <- mock_download_client()
  res <- download(client, "/gzip", NULL, "my.zip", FALSE, FALSE)
  expect_is(res, "character")
  expect_true(file.exists(res))
  expect_match(res, "\\.zip$")
})


test_that("Can overwrite", {
  client <- mock_download_client()
  dest <- tempfile()
  file.create(dest)
  res <- download(client, "/gzip", dest, "my.zip", FALSE, TRUE)
  expect_true(file.size(dest) > 0)
  expect_error(
    download(client, "/gzip", dest, "my.zip", FALSE, FALSE))
})


test_that("Don't write file on 404", {
  client <- mock_download_client()
  dest <- tempfile()
  expect_error(
    download(client, "/status/404", dest, "my.zip", FALSE, FALSE),
    "Remote file not found at 'my.zip'")
  expect_false(file.exists(dest))
})
