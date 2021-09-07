#' Download a dataset from sharepoint
#'
#' @param sharepoint_path The path to the dataset you want to download - this
#' should include any subsites in the url and should be of the form
#' sites/nested/subsites/docs/path/to/document
#' e.g. if you want to get the file at Data/shape files/example.geojson from
#' the site groupA which is in site facultyA the full path would be
#' sites/facultyA/groupA/docs/Data/shape files/example.geojson
#' You should be able to get this if you locate the data you want to download
#' in a browser and click menu on the RHS of the file name which appears on
#' hover -> Copy link and manually edit to get the file path. See vignette for
#' more details.
#'
#' @param dest Path to location you want to save the data. The default
#' save location is a tempfile with the same file extension as the downloaded
#' file.
#'
#' @param progress If \code{TRUE} then HTTP requests will print a progress bar
#'
#' @param overwrite if \code{TRUE} then the \code{dest} will be
#'   ovewritten if it exists (otherwise it an error will be thrown)
#'
#' @return Path to downloaded data
#'
#' @export
sharepoint_download <- function(
  sharepoint_path, dest = NULL, overwrite = FALSE,
  site_name = NULL, site_url = NULL, site_id = NULL,
  tenant = Sys.getenv("CLIMICROSOFT365_TENANT", "common"),
  app = Sys.getenv("CLIMICROSOFT365_AADAPPID"),
  scopes = c("Group.ReadWrite.All", "Directory.Read.All", "Sites.Manage.All")) {

  sp <- sharepoint_new(site_name = site_name,
                       site_url = site_url,
                       site_id = site_id,
                       tenant = tenant,
                       app = app,
                       scopes = scopes,
                       auth = NULL)
  sp$download(sharepoint_path, dest, overwrite)
}

sharepoint_new <- function(site_name, site_url, site_id, tenant, app, scopes,
                           auth) {
  sharepoint$new(site_name, site_url, site_id, tenant, app, scopes, auth)
}

#' Create sharepoint connection for downloading data.
#'
#' @export
sharepoint <- R6::R6Class(
  "sharepoint",
  cloneable = FALSE,

  public = list(
    #' @field client
    #' A sharepoint_folder object
    client = NULL,

    #' @description
    #' Create sharepoint object for downloading data from sharepoint
    #' @param auth Authentication data passed to the client
    #' @param sharepoint_url Root URL of sharepoint site to download from
    #' @return A new `sharepoint` object
    initialize = function(
      site_name = NULL, site_url = NULL, site_id = NULL,
      tenant = Sys.getenv("CLIMICROSOFT365_TENANT", "common"),
      app = Sys.getenv("CLIMICROSOFT365_AADAPPID"),
      scopes = c("Group.ReadWrite.All", "Directory.Read.All", "Sites.Manage.All"),
      auth = NULL) {

      auth <- sharepoint_auth(site_name, site_url, site_id, tenant, app,
                              scopes, auth)
      self$client <- sharepoint_folder_new(auth)
    },

    #' @description
    #' Download data from sharepoint
    #' @param sharepoint_path Path to the resource within sharepoint
    #' @param dest Path to save downloaded data to
    #' @param overwrite Overwrite existing files?
    #' @return Path to saved data
    download = function(sharepoint_path, dest = NULL, overwrite = FALSE) {
      self$client$download(sharepoint_path, dest, overwrite)
    },

    #' @description
    #' Create a \code{folder} object representing a sharepoint folder,
    #' with which one can list, download and upload files.  See
    #' \code{\link{sharepoint_folder}} for more details.
    #'
    #' @param path Path to folder from root of sharepoint site. Defaults to
    #' "/" for the root.
    folder = function(path = "/") {
      self$client$folder(path)
    }
  )
)
