context("utils")

test_that("null-or-value works", {
  expect_equal(1 %||% NULL, 1)
  expect_equal(1 %||% 2, 1)
  expect_equal(NULL %||% NULL, NULL)
  expect_equal(NULL %||% 2, 2)
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
  expect_equal(normalizePath(dirname(tmpf)), normalizePath(tempdir()))

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

test_that("can get system env", {
  expect_null(sys_getenv("ENV_VAR"))
  expect_equal(sys_getenv("ENV_VAR", unset = ""), "")
  withr::with_envvar(
    c("ENV_VAR" = "123"),
    expect_equal(sys_getenv("ENV_VAR"), "123"))
})
