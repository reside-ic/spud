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
    path = NULL
  ),

  public = list(
    initialize = function(client, site, path, verify = FALSE) {
      ## TODO: no validation
      private$client <- client
      private$site <- site
      private$path <- path
      if (verify) {
        url <- sprintf("/sites/%s/_api/%s", private$name, private$site)
        httr::stop_fot_status(private$client$GET(url))
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
    }
  ))
