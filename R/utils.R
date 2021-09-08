is_empty <- function(var) {
  is.na(var) || !nzchar(var)
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

spud_file <- function(...) {
  system.file(..., package = "spud", mustWork = TRUE)
}

tempfile_inherit_ext <- function(file) {
  ext <- tools::file_ext(file)
  if (ext != "") {
    ext <- paste0(".", ext)
  }
  tempfile(fileext = ext)
}

download_dest <- function(dest, src) {
  if (is.null(dest)) {
    dest <- tempfile_inherit_ext(src)
  } else if (!is.raw(dest)) {
    assert_scalar_character(dest)
  }
  dest
}

`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}

sys_getenv <- function(env, unset = NULL) {
  e <- Sys.getenv(env)
  if (is_empty(e)) {
    e <- unset
  }
  e
}
