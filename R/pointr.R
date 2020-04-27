#' Download a dataset from sharepoint
#'
#' @param sharepoint_url The base URL of sharepoint e.g.
#' https://imperiallondon.sharepoint.com
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
sharepoint_download <- function(sharepoint_url, sharepoint_path, dest = NULL,
                                progress = FALSE, overwrite = FALSE) {
  pointr <- pointr$new(sharepoint_url)
  pointr$download(sharepoint_path, dest, progress, overwrite)
}

#' Create sharepoint connection for downloading data.
#'
#' @export
pointr <- R6::R6Class(
  "pointr",
  cloneable = FALSE,

  public = list(
    #' @description
    #' Create pointr object for downloading data from sharepoint
    #' @param sharepoint_url Root URL of sharepoint site to download from
    #' @return A new `pointr` object
    initialize = function(sharepoint_url, auth = NULL) {
      if (is.character(auth)) {
        auth <- read_binary(auth)
      }
      private$client <- sharepoint_client$new(sharepoint_url, auth)
    },

    #' @description
    #' Download data from sharepoint
    #' @param sharepoint_path Path to the resource within sharepoint
    #' @param dest Path to save downloaded data to
    #' @param progress Display a progress bar during download?
    #' @return Path to saved data
    download = function(sharepoint_path, dest = NULL, progress = FALSE,
                        overwrite = FALSE) {
      download(private$client, URLencode(sharepoint_path), dest,
               sharepoint_path, progress, overwrite)
    },

    #' @description
    #' Create a \code{folder} object representing a sharepoint folder,
    #' with which one can list, download and upload files.  See
    #' \code{\link{sharepoint_folder}} for more details.
    #'
    #' @param site The name of the sharepoint site (most likely a short string)
    #'
    #' @param path Relative path within that shared site.  It seems
    #' that "Shared Documents" is a common path that most likely
    #' represents a "Documents" collection when viewed in the
    #' sharepoint web interface.
    #'
    #' @param verify Logical, indicating if the site/path combination is
    #' valid (slower but safer).
    folder = function(site, path, verify = FALSE) {
      sharepoint_folder$new(private$client, site, path, verify)
    },

    #' @description
    #' Get the authentication data from the client.  If this is saved
    #' to a file it provides a way of re-authenticating with a server
    #' for a limited period (typically between a few days and a few
    #' weeks) without re-entering the username and password, and may be
    #' suitable for automated tasks.  Note that unlike proper OAuth-based
    #' access, there is no way of revoking such access and so the
    #' authentication data should be treated very carefully.
    #'
    #' @param file A file to write the data to. If \code{NULL} the raw data
    #' is returned directly.
    get_auth_data = function(file) {
      dat <- private$client$get_auth_data()
      if (is.null(file)) {
        dat
      } else {
        writeBin(dat, file)
        file
      }
    }
  ),

  private = list(
    client = NULL
  )
)
