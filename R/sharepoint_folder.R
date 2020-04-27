## There are lots of details that are not exposed here yet, in
## particular, see
##
## https://docs.microsoft.com/en-us/previous-versions/office/sharepoint-csom/ee542189(v=office.15)
##
## which seems to be the documentation for the underlying code that
## the API is built on top of

#' Interact with sharepoint folders and their files.
sharepoint_folder <- R6::R6Class(
  "sharepoint_folder",
  cloneable = FALSE,

  private = list(
    client = NULL,
    site = NULL,
    path = NULL,
    api_root = NULL
  ),

  public = list(
    initialize = function(client, site, path, verify = FALSE) {
      private$client <- client
      private$site <- site
      private$path <- path
      private$api_root <- sprintf(
        "/sites/%s/_api/web/GetFolderByServerRelativeURL('%s')",
        site, URLencode(path))

      if (verify) {
        r <- private$client$GET(private$api_root)
        if (httr::status_code(r) == 404) {
          stop(sprintf("Path '%s' was not found on site '%s'", path, site),
               call. = FALSE)
        }
        httr::stop_for_status(r)
      }
    },

    #' @description List all files within the folder
    files = function() {
      url <- sprintf(
        "/sites/%s/_api/web/GetFolderByServerRelativeURL('%s')/files",
        private$site, URLencode(private$path))
      r <- private$client$GET(url)
      httr::stop_for_status(r)
      dat <- response_from_json(r)
      ## NOTE: Despite the reference saying it should be a long, we
      ## get size as a string
      tibble::tibble(
        name = vcapply(dat$value, "[[", "Name"),
        size = as.numeric(vcapply(dat$value, "[[", "Length")),
        created = to_time(vcapply(dat$value, "[[", "TimeCreated")),
        modified = to_time(vcapply(dat$value, "[[", "TimeLastModified")))
    },

    #' @description List all folders within the folder
    folders = function() {
      url <- sprintf(
        "/sites/%s/_api/web/GetFolderByServerRelativeURL('%s')/folders",
        private$site, URLencode(private$path))
      r <- private$client$GET(url)
      httr::stop_for_status(r)
      dat <- response_from_json(r)
      tibble::tibble(
        name = vcapply(dat$value, "[[", "Name"),
        items = vnapply(dat$value, "[[", "ItemCount"),
        created = to_time(vcapply(dat$value, "[[", "TimeCreated")),
        modified = to_time(vcapply(dat$value, "[[", "TimeLastModified")))
    },

    #' @description List all folders and files within the folder; this is a
    #' convenience wrapper around the \code{files} and \code{folders} methods.
    list = function() {
      folders <- self$folders()
      files <- self$files()
      folders$size <- rep(NA_real_, nrow(folders))
      folders$is_folder <- TRUE
      files$items <- rep(NA_integer_, nrow(files))
      files$is_folder <- FALSE
      v <- c("name", "items", "size", "is_folder", "created", "modified")
      rbind(folders[v], files[v])
    },

    #' @description Create an object referring to the parent folder
    #' @param verify Verify that the folder exists (which it must really here)
    parent = function(verify = FALSE) {
      sharepoint_folder$new(private$client, private$site,
                            dirname(private$path), verify)
    },

    #' @description Create an object referring to a child folder
    #' @param path The name of the folder, relative to this folder
    #' @param verify Verify that the folder exists (which it must really here)
    folder = function(path, verify = FALSE) {
      sharepoint_folder$new(private$client, private$site,
                            file.path(private$path, path), verify)
    },

    #' @description Download a file from a folder
    #' @param path The name of the path to download, relative to this folder
    #' @param dest Path to save downloaded data to. If \code{NULL} then a
    #'   temporary file with the same file extension as \code{path} is used.
    #' @param progress Display httr's progress bar?
    download = function(path, dest = NULL, progress = FALSE) {
      url <- sprintf("%s/Files('%s')/$value",
                     private$api_root, URLencode(path))
      dest <- dest %||% tempfile_inherit_ext(path)
      path_show <- sprintf("%s:%s/%s", private$site, private$path, path)
      download(private$client, url, dest, path_show, progress)
    },

    #' @description Upload a file into a folder
    #' @param path The name of the path to upload, absolute, or relative to
    #' R's working directory.
    #' @param dest Remote path save downloaded data to, relative to this
    #' folder.  If \code{NULL} then the basename of the file is used.
    #' @param progress Display httr's progress bar?
    upload = function(path, dest = NULL, progress = FALSE) {
      opts <- if (progress) httr::progress("up") else NULL
      dest <- dest %||% basename(path)
      url <- sprintf("%s/Files/Add(url='%s',overwrite=true)",
                     private$api_root, URLencode(dest))
      digest <- private$client$digest(private$site)
      body <- httr::upload_file(path, "application/octet-stream")
      r <- private$client$POST(url, body = body, opts, digest)
      httr::stop_for_status(r)
      invisible()
    }
  ))
