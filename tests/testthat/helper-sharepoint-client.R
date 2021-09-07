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
    auth <- sharepoint_auth()
    sharepoint_folder$new(auth, NULL)
  })
}

with_emptyenv <- function(code) {
  withr::with_envvar(list(
    "SHAREPOINT_SITE_NAME" = NULL,
    "SHAREPOINT_SITE_URL" = NULL,
    "SHAREPOINT_SITE_ID" = NULL,
    "SHAREPOINT_TENANT" = NULL,
    "SHAREPOINT_APP_ID" = NULL
  ), code)
}
