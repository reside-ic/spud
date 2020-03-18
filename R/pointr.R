pointr_download <- function(sharepoint_url, sharepoint_path, save_path) {
  pointr <- pointr$new(sharepoint_url)
  pointr$download_data(sharepoint_path, save_path)
}

pointr <- R6::R6Class(
  "pointr",
  cloneable = FALSE,

  public = list(
    initialize = function(sharepoint_url) {
      private$client <- sharepoint_client$new(sharepoint_url)
    },

    download = function(sharepoint_path, save_path) {
      res <- private$client$GET(sharepoint_path, httr::write_disk(save_path))
      save_path
    }
  ),

  private = list(
    client = NULL
  )
)

