is_empty <- function(var) {
  is.na(var) || !nzchar(var)
}

get_pass <- function(prompt) {
  getPass::getPass(prompt, TRUE) # nocov
}

get_string <- function(prompt) {
  message(prompt, appendLF = FALSE) # nocov
  clean_input_text(scan("stdin", character(), n = 1, quiet = TRUE)) # nocov
}

clean_input_text <- function(x) {
  re <- "(^\\s*[\"']?|[\"']?\\s*$)"
  gsub(re, "", x, perl = TRUE)
}

assert_scalar_character <- function(x, name = deparse(substitute(x))) {
  assert_character(x, name)
  assert_scalar(x, name)
  assert_nonmissing(x, name)
  if (!nzchar(x)) {
    stop(sprintf("'%s' must be nonempty", name), call. = FALSE)
  }
}

assert_character <- function(x, name = deparse(substitute(x))) {
  if (!is.character(x)) {
    stop(sprintf("'%s' must be a character", name), call. = FALSE)
  }
}

assert_scalar <- function(x, name = deparse(substitute(x))) {
  if (length(x) != 1) {
    stop(sprintf("'%s' must be a scalar", name), call. = FALSE)
  }
}

assert_nonmissing <- function(x, name = deparse(substitute(x))) {
  if (any(is.na(x))) {
    stop(sprintf("'%s' must not be NA", name), call. = FALSE)
  }
}

pointr_file <- function(...) {
  system.file(..., package = "pointr", mustWork = TRUE)
}
