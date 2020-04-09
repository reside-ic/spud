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

test_that("tempfile_inherit_ext" {

  tmpf <- tempfile_inherit_ext("jibberish.wahoo")

  expect_equal(tools::file_ext(tmpf), "wahoo")
  expect_equal(dirname(tmpf), tempdir())
})
