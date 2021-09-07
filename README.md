# spud <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->
[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![R build status](https://github.com/reside-ic/pointr/workflows/R-CMD-check/badge.svg)](https://github.com/reside-ic/pointr/actions)
[![Build status](https://badge.buildkite.com/2f80635022481989da55f4be29951a8f0902eedea92956761e.svg?branch=master)](https://buildkite.com/mrc-ide/spud)
[![codecov.io](https://codecov.io/github/reside-ic/spud/coverage.svg?branch=master)](https://codecov.io/github/reside-ic/spud?branch=master)
<!-- badges: end -->

This app uses [Microsoft365R](https://github.com/Azure/Microsoft365R) for programmatically accessing sharepoint. This is just a wrapper around Microsoft365R to expose an interface we want to use for interacting with sharepoint from orderly.


## Authentication

Spud uses Microsoft365R for managing all authentication. This requires some info to be able to authenticate, you can pass this through args to the exported functions or by setting environment variables. See `?spud::sharepoint_download` for details of env vars used.

See [Microsoft365R docs](https://github.com/Azure/Microsoft365R#authentication) for details of how authentication args are used.

## Usage

### Download a file via function

Use `sharepoint_download` to download a file.

```
spud::sharepoint_download("path/to/source", "destination.txt",
                          site_url = "site_url")
```

### Download via object

Alternatively create a `sharepoint` object which you can use to download

```
sp <- spud::sharepoint$new(site_url = "site_url")
sp$download("path/to/source", "destination.txt")
```

### Using `sharepoint_folder` object

Create a handle on a sharepoint folder which you can use for creating subfolders, list files, uploading files, download files or deleting items.

```
sp <- spud::sharepoint$new(site_url = "site_url")
folder <- sp$folder("path/to/folder")
```

#### Create folder

```
sub_folder <- folder$create("folder_name")
```

#### List files

```
folder$list()    # List all
folder$files()   # List only files
folder$folders() # List only folders
```

#### Download file

```
folder$download("path/to/file", "destination.txt")
```

#### Upload file

```
folder$upload("path/to/file", "sharepoint/destination")
```

#### Delete items

```
folder$delete("path/to/file")
```

## Tests

Most of the tests make heavy use of mocks, so if the API changes we might not catch breaking changes. In order to hedge against this we run a small number of manual tests against sharepoint. To opt into running these tests you need to define some environment variables:

```
SHAREPOINT_SITE_URL=http://example.com
SHAREPOINT_TENANT=tenant
SHAREPOINT_APP_ID=123-345
```

Alternative to `SHAREPOINT_SITE_URL` you can set `SHAREPOINT_SITE_ID` or `SHAREPOINT_SITE_NAME`. One and only one of these values must be set. `SHAREPOINT_TENANT` should be the name of your Azure Active Directory (AAD) tenant. And `SHAREPOINT_APP_ID` should be set to the custom app registration ID for the Microsoft365R app. This will default to using Microsoft365R's own internal app ID.

This will create a new directory on your sharepoint site, one per time the test suite is run, and it will add, list, remove files that are there. The tests will cleanup if they run successfully.

## License

MIT © Imperial College of Science, Technology and Medicine
