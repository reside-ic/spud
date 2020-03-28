#' Get username and password
#'
#' Defaults to get from environment variable, falling back to getting them
#' interactively if supported
#'
#' @return The username and password entered
#' @keywords internal
#' @noRd
get_credentials <- function() {
  list(
    username = get_single_credential("SHAREPOINT_USERNAME",
                                     "Sharepoint username",
                                     get_string),
    password = get_single_credential("SHAREPOINT_PASS",
                                     "Sharepoint password",
                                     get_pass)
  )
}

get_single_credential <- function(env_var, credential, read_func) {
  cred <- Sys.getenv(env_var)
  if (is_empty(cred)) {
    cred <- read_func(paste0(credential, ": "))
  }
  tryCatch(
    assert_scalar_character(cred, credential),
    error = function(e) {
      e$message <- paste0(
        e$message,
        sprintf(", either set env var %s or enter at prompt",
                env_var))
      stop(e)
    })
  cred
}
