is_empty <- function(var) {
  is.na(var) || !nzchar(var)
}

get_pass <- function(prompt) {
  getPass::getPass(prompt, TRUE) # nocov
}

get_string <- function(prompt) {
  # nocov start
  if (interactive()) {
    clean_input_text(readline(prompt))
  } else {
    message(prompt, appendLF = FALSE)
    clean_input_text(scan("stdin", character(), n = 1, quiet = TRUE))
  }
  # nocov end
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


response_from_json <- function(x, simplifyVector = FALSE, ...) {
  txt <- httr::content(x, "text", encoding = "UTF-8")
  jsonlite::fromJSON(txt, simplifyVector, ...)
}


vcapply <- function(X, FUN, ...) {
  vapply(X, FUN, character(1), ...)
}


vnapply <- function(X, FUN, ...) {
  vapply(X, FUN, numeric(1), ...)
}


to_time <- function(str) {
  strptime(str, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}


download <- function(client, url, dest, path, progress, overwrite) {
  dest <- download_dest(dest, path)
  opts <- if (progress) httr::progress() else NULL
  write <- if (is.raw(dest)) NULL else httr::write_disk(dest, overwrite)

  r <- client$GET(url, opts, write)
  if (httr::status_code(r) == 404) {
    if (!is.raw(dest)) {
      unlink(dest)
    }
    stop(sprintf("Remote file not found at '%s'", path))
  }
  httr::stop_for_status(r)
  if (is.raw(dest)) {
    dest <- httr::content(r, "raw")
  }
  dest
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


read_binary <- function(path) {
  readBin(path, raw(), file.size(path))
}


file_path2 <- function(a, b) {
  if (is.null(b)) a else file.path(a, b)
}
