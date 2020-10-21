<!-- badges: start -->
[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Build status](https://badge.buildkite.com/2f80635022481989da55f4be29951a8f0902eedea92956761e.svg)](https://buildkite.com/mrc-ide/spud)
[![Travis build status](https://travis-ci.com/reside-ic/spud.svg?branch=master)](https://travis-ci.com/reside-ic/spud)
[![codecov.io](https://codecov.io/github/reside-ic/spud/coverage.svg?branch=master)](https://codecov.io/github/reside-ic/spud?branch=master)
<!-- badges: end -->

# spud

Package to enable programmatic downloading of data from sharepoint.

Authenticates using pattern detailed https://paulryan.com.au/2014/spo-remote-authentication-rest/

There is a package exists on github for managing lists - not clear whether this will work with downloading any data as package doesn't work with most basic example of retrieveing all available lists
https://github.com/LukasK13/sharepointr#list-all-available-lists

## Authentication

The authentication mechanism is subject to change.

`spud` will look for the environment variables `SHAREPOINT_USERNAME` and `SHAREPOINT_PASS` for your credentials and prompt interactively for any missing.

Once authenticated you can save your authentication data to disk for future sessions with:

```
p$client$get_auth_data(".auth")
```

(for a sharepoint object `p` saving to a file `.auth`).  You can then use this by constructing your object as:

```
p <- spud::sharepoint$new(..., auth = ".auth")
```

Be sure to add this file your `.gitignore` and treat it like a password.

### MFA

If using multi-factor authentication then the above approach won't work. You need to generate an app password and enter this when prompted for your password. See [microsoft docs](https://docs.microsoft.com/en-gb/azure/active-directory/user-help/multi-factor-authentication-end-user-app-passwords) for details on how to generate an app password.

## Testing

Note there is no end-to-end test in this package that we can authenticate with a real sharepoint server and download data. Can run this manually to download a dataset which should be available to everyone with an Imperial login. Note that when prompted for a username it is name as you use it to login to imperial account e.g. `jbloggs@ic.ac.uk` opposed to your email `j.bloggs@imperial.ac.uk`

```
sharepoint_download("https://imperiallondon.sharepoint.com", "Shared%20Documents/Document.docx", tempfile(fileext = ".docx"))
```

### TODO

* Caching for `sharepoint_download` function. Probably a kv store of sharepoint URL + user to `spud` or `sharepoint_client` object
* Allow more formats of the resource URL - at the moment users need to do some manual formatting to put this into the correct formatting hopefully we can support
   * Copy from url when previewing document
   * The "copy link" button for a resource
   * Manually building path from sites and the document list
* Error handling - do we want to do some better error handling here if any of the requests fail? e.g. particularly bad if downloading a resource which doesn't exist
* Testing - look at httptest & vcr which might provide some slightly nicer testing atm we are relying heavily on mocks.
* Vignette - write one!
