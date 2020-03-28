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
#' @param save_path Path to location you want to save the data
#' @param verbose If TRUE then HTTP requests will print verbose output
#'
#' @return Path to downloaded data
#' @export
sharepoint_download <- function(sharepoint_url, sharepoint_path,
                                save_path = tempfile(), verbose = FALSE) {
  pointr <- pointr$new(sharepoint_url)
  pointr$download(sharepoint_path, save_path, verbose)
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
    initialize = function(sharepoint_url) {
      private$client <- sharepoint_client$new(sharepoint_url)
    },

    #' @description
    #' Download data from sharepoint
    #' @param sharepoint_path Path to the resource within sharepoint
    #' @param save_path Path to save downloaded data to
    #' @param verbose If TRUE then HTTP requests will print verbose output
    #' @return Path to saved data
    download = function(sharepoint_path, save_path, verbose = FALSE) {
      if (verbose) {
        opts <- httr::verbose()
      } else {
        opts <- NULL
      }
      res <- private$client$GET(URLencode(sharepoint_path),
                                opts,
                                httr::write_disk(save_path))
      if (httr::status_code(res) == 404) {
        unlink(save_path)
        stop(sprintf("Remote file not found at '%s'", sharepoint_path))
      }
      httr::stop_for_status(res)
      save_path
    }
  ),

  private = list(
    client = NULL
  )
)
