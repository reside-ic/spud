get_credentials <- function() {
  list(
    username = get_single_credential("SHAREPOINT_USERNAME",
                                     "Sharepoint username"),
    password = get_single_credential("SHAREPOINT_PASS", "Sharepoint password")
  )
}

get_single_credential <- function(env_var, credential) {
  cred <- Sys.getenv(env_var)
  if (is_empty(cred) && is_interactive()) {
    cred <- getPass::getPass(msg = credential)
  }
  if (is_empty(cred)) {
    stop(sprintf(
      "Failed to retrieve %s, either set env var %s or enter in interactive session",
      credential, env_var))
  }
  cred
}

is_interactive <- function() {
  interactive()
}
