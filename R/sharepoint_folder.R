## There are lots of details that are not exposed here yet, in
## particular, see
##
## https://docs.microsoft.com/en-us/previous-versions/office/sharepoint-csom/ee542189(v=office.15)
##
## which seems to be the documentation for the underlying code that
## the API is built on top of

sharepoint_folder <- R6::R6Class(
  "sharepoint_folder",

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

    ## Helper function
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

    parent = function() {
      sharepoint_folder$new(private$client, private$site,
                            dirname(private$path))
    },

    folder = function(path) {
      sharepoint_folder$new(private$client, private$site,
                            file.path(private$path, path))
    },

    download = function(path, dest = NULL, progress = FALSE) {
      url <- sprintf("%s/Files('%s')/$value",
                     private$api_root, URLencode(path))
      dest <- dest %||% tempfile_inherit_ext(path)
      download(private$client, url, dest, progress)
    },

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
