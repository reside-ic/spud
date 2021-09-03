m365r_folder <- R6::R6Class(
  "M365R Folder",
  cloneable = FALSE,

  private = list(
    tenant = NULL,
    app = NULL,
    site_name = NULL,
    scopes = NULL,
    site = NULL,
    drive <- NULL,
    path = NULL
  ),

  public = list(
    initialize = function(site_name, tenant, app, scopes, path) {
      private$site_name <- site_name
      private$tenant <- tenant
      private$app <- app
      private$scopes <- scopes
      private$path <- path
      private$site <- Microsoft365R::get_sharepoint_site(
        site_name = private$site_name,
        app = private$app,
        tenant = private$tenant,
        scopes = private$scopes)
      private$drive <- private$site$get_drive()
      if (!is.null(path)) {
        private$drive <- private$drive$get_item(path)
      }
    },

    files = function(path = "/") {
      items <- self$list(path)
      items[!items$isdir, ]
    },

    folders = function(path = "/") {
      items <- self$list(path)
      items[items$isdir, ]
    },

    list = function(path = "/") {
      private$drive$list_items(path)
    },

    delete = function(path, check) {
      private$drive$delete_item(path, confirm = check)
    },

    parent = function() {
      ## TODO
    },

    folder = function(path) {
      m365r_folder$new(private$site_name, private$tenant, private$app,
                       private$scopes, file.path(private$path, path))
    },

    create = function(path) {
      private$drive$create_folder(path)
    },

    download = function(path, dest = NULL, overwrite = FALSE) {
      dest <- download_dest(dest, path)
      private$drive$download_file(path, dest = dest, overwrite = overwrite)
    }
  )
)
