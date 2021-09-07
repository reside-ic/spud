sharepoint_auth <- function(
  site_name = NULL, site_url = NULL, site_id = NULL,
  tenant = NULL, app  = NULL, scopes = NULL, auth = NULL) {

  args <- as.list(environment())
  if (is.null(auth)) {
    auth <- list(
      site_name = site_name %||% sys_getenv("SHAREPOINT_SITE_NAME"),
      site_url = site_url %||% sys_getenv("SHAREPOINT_SITE_URL"),
      site_id = site_id %||% sys_getenv("SHAREPOINT_SITE_ID"),
      tenant = tenant %||% sys_getenv("SHAREPOINT_TENANT", "common"),
      app = app %||% sys_getenv("SHAREPOINT_APP_ID", ""),
      scopes = scopes %||% c("Group.ReadWrite.All", "Directory.Read.All",
                             "Sites.Manage.All")
    )
  } else {
    assert_sharepoint_auth(auth)
    null <- vapply(args, is.null, logical(1))
    auth_args <- args[names(args) != "auth" & !null]
    auth[names(auth_args)] <- auth_args
  }
  class(auth) <- "sharepoint_auth"
  auth
}

is_sharepoint_auth <- function(object) {
  inherits(object, "sharepoint_auth")
}

assert_sharepoint_auth <- function(object) {
  if (!is_sharepoint_auth(object)) {
    stop("Must be a sharepoint_auth object")
  }
}
