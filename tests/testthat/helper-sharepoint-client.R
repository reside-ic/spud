mock_get_sharepoint_site <- function(...) {
  list_items <- readRDS("mocks/list_items_response.rds")
  create_folder <- invisible(TRUE)
  upload <- invisible(TRUE)
  item <- list(
    delete = mockery::mock(NULL, cycle = TRUE),
    download = mockery::mock(NULL, cycle = TRUE)
  )
  root_drive_item <- list(
    list_items = mockery::mock(list_items, cycle = TRUE),
    get_item = mockery::mock(item, cycle = TRUE),
    create_folder = mockery::mock(create_folder, cycle = TRUE),
    upload = mockery::mock(upload, cycle = TRUE)
  )
  list(
    get_drive = function() {
      list(
        get_item = function(...) {
          root_drive_item
        }
      )
    }
  )
}

test_folder <- function() {
  with_mock("Microsoft365R::get_sharepoint_site" = mock_get_sharepoint_site, {
    sharepoint_folder$new("url", "tenant", "app", "scopes", NULL)
  })
}

mock_sharepoint <- function(sharepoint_url) {
  security_token_res <- readRDS("mocks/security_token_response.rds")
  cookies_res <- readRDS("mocks/cookies_response.rds")
  mock_post <- mockery::mock(security_token_res, cookies_res)
  t <- tempfile()
  withr::with_envvar(
    c("SHAREPOINT_USERNAME" = "user", "SHAREPOINT_PASS" = "pass"),
    with_mock("httr::POST" = mock_post, {
      sharepoint$new("https://httpbin.org")
    })
  )
}


mock_response <- function(status_code = 200L) {
  structure(
    list(status_code = status_code),
    class = "response")
}


mock_download_client <- function() {
  list(GET = function(url, ...)
    httr::GET(paste0("https://httpbin.org", url), ...))
}


strip_url <- function(x) {
  gsub("https://[^/]+/sites/[^/]+/", "https://example.com/sites/mysite/", x)
}


strip_site <- function(x) {
  gsub("/sites/[^/]+/", "/sites/mysite/", x)
}

strip_response <- function(r) {
  r$url <- sub("https://.*?/sites/.*?/",
               "https://example.com/sites/mysite/", r$url)
  r$headers <- NULL
  r$all_headers <- NULL
  r$cookies <- NULL
  r$request <- NULL
  r$handle <- NULL
  r
}


r6_private <- function(x) {
  environment(x$initialize)$private
}


## This is super difficult to because curl does not have a way of
## setting cookies on a handle.  So we fudge it:
set_cookies <- function(handle, data) {
  cookies <- setNames(as.list(data$cookies$value), data$cookies$name)
  httr::GET("https://httpbin.org/cookies/set", query = cookies,
            handle = handle)
}

integration_test_client <- function() {
  v <- c("username", "password", "host", "site", "root")
  dat <- Sys.getenv(paste0("SPUD_TEST_SHAREPOINT_", toupper(v)), NA_character_)

  if (any(is.na(dat))) {
    testthat::skip(c(
      "Environment variables not defined for integration tests:",
      paste0(" - ", names(dat)[is.na(dat)])))
  }
  names(dat) <- v

  ## This needs tidying up: RESIDE-162
  client <- withr::with_envvar(c(
    SHAREPOINT_USERNAME = dat[["username"]],
    SHAREPOINT_PASS = dat[["password"]]),
    sharepoint$new(dat[["host"]]))
  root <- client$folder(dat[["site"]], dat[["root"]], verify = TRUE)
  tmp <- basename(tempfile("test_"))
  folder <- root$create(tmp)

  list(folder = folder, client = client)
}
