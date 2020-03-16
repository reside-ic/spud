is_empty <- function(var) {
  is.na(var) || !nzchar(var)
}
