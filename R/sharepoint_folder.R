#' Interact with sharepoint folders and their files.
sharepoint_folder <- R6::R6Class(
  "sharepoint_folder",
  cloneable = FALSE,

  private = list(
    auth = NULL,
    site = NULL
  ),

  public = list(
    #' @field path Path of the folder (readonly)
    path = NULL,

    drive = NULL,

    #' @description Create sharepoint_folder object to enable listing, creating
    #' downloading and uploading files & folders
    #' @param auth Auth info passed to [Microsoft365R::get_sharepoint_site()]
    #' contains site_name, site_url, site_id, tenant, app and scopes.
    #' @param path Relative path within that shared site.
    initialize = function(auth, path = NULL) {
      assert_sharepoint_auth(auth)
      private$auth <- auth
      private$site <- do.call(Microsoft365R::get_sharepoint_site, private$auth)
      if (is.null(path)) {
        path <- "/"
      }
      self$path <- path
      drive <- private$site$get_drive()
      self$drive <- drive$get_item(self$path)
      lockBinding("path", self)
    },

    #' @description List all files within the folder
    #' @param path Folder relative to this folder, uses this folder if NULL
    files = function(path = "/") {
      if (is.null(path)) {
        path <- "/"
      }
      items <- self$list(path)
      items[!items$isdir, ]
    },

    #' @description List all folders within the folder
    #' @param path Folder relative to this folder, uses this folder if NULL
    folders = function(path = "/") {
      if (is.null(path)) {
        path <- "/"
      }
      items <- self$list(path)
      items[items$isdir, ]
    },

    #' @description List all folders and files within the folder; this is a
    #' convenience wrapper around the \code{files} and \code{folders} methods.
    #' @param path Folder relative to this folder, uses this folder if NULL
    list = function(path = "/") {
      if (is.null(path)) {
        path <- "/"
      }
      items <- self$drive$list_items(path, info = "all")
      items <- items[, c("name", "size", "isdir", "createdDateTime",
                         "lastModifiedDateTime")]
      colnames(items) <- c("name", "size", "isdir", "created", "modified")
      items
    },

    #' @description Delete a folder or file. Be extremely careful as you
    #' could use this to delete an entire sharepoint. Deleted files are sent
    #' to the recycle bin, so can be restored with relative ease, but
    #' it will still be alarming. There is a mechanism to prevent
    #' accidental deletion.
    #'
    #' @param path The path to delete. Use \code{NULL} to delete the current
    #'   folder.
    #' @param check If TRUE then prompts user for confirmation before deleting
    delete = function(path, check = TRUE) {
      self$drive$get_item(path)$delete(confirm = check)
    },

    #' @description Create an object referring to the parent folder. If this
    #' folder is the root, retrieving parent just returns the root again.
    parent = function() {
      sharepoint_folder$new(private$auth, dirname(self$path))
    },

    #' @description Create an object referring to a child folder
    #' @param path The name of the folder, relative to this folder
    #' @param verify Verify that the folder exists (which it must really here)
    folder = function(path) {
      sharepoint_folder$new(private$auth, file.path(self$path, path))
    },

    #' @description Create a folder on sharepoint
    #' @param path Folder relative to this folder
    create = function(path) {
      self$drive$create_folder(path)
      invisible(self$folder(path))
    },

    #' @description Download a file from a folder
    #' @param path The path of the file to download, relative to this folder
    #' @param dest Path to save downloaded data to. If \code{NULL} then a
    #'   temporary file with the same file extension as \code{path} is used.
    #'   If code{raw()} (or any other raw value) then the raw bytes will be
    #'   returned.
    #' @param overwrite Overwrite the file if it exists?
    download = function(path, dest = NULL, overwrite = FALSE) {
      dest <- download_dest(dest, path)
      self$drive$get_item(path)$download(dest = dest, overwrite = overwrite)
      dest
    },

    #' @description Upload a file into a folder
    #' @param path The name of the path to upload, absolute, or relative to
    #' R's working directory.
    #' @param dest Remote path save downloaded data to, relative to this
    #' folder.  If \code{NULL} then uploaded to active folder.
    upload = function(path, dest = NULL) {
      self$drive$upload(path, dest)
    }
  )
)

sharepoint_folder_new <- function(auth) {
  sharepoint_folder$new(auth)
}
