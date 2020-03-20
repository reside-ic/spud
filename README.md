<!-- badges: start -->
[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Travis build status](https://travis-ci.org/reside-ic/pointr.svg?branch=master)](https://travis-ci.org/reside-ic/pointr)
[![codecov.io](https://codecov.io/github/reside-ic/pointr/coverage.svg?branch=master)](https://codecov.io/github/reside-ic/pointr?branch=master)
<!-- badges: end -->

# pointr

Package to enable programmatic downloading of data from sharepoint.

Authenticates using pattern detailed https://paulryan.com.au/2014/spo-remote-authentication-rest/

There is a package exists on github for managing lists - not clear whether this will work with downloading any data as package doesn't work with most basic example of retrieveing all available lists
https://github.com/LukasK13/sharepointr#list-all-available-lists

## Testing

Note there is no end-to-end test in this package that we can authenticate with a real sharepoint server and download data. Can run this manually to download a dataset which should be available to everyone with an Imperial login. Note that when prompted for a username it is name as you use it to login to imperial account e.g. `jbloggs@ic.ac.uk` opposed to your email `j.boggs@imperial.ac.uk`

```
sharepoint_download("https://imperiallondon.sharepoint.com", "Shared%20Documents/Document.docx", tempfile(fileext = ".docx"))
```

### TODO

* Allow more formats of the resource URL - at the moment users need to do some manual formatting to put this into the correct formatting hopefully we can support
   * Copy from url when previewing document
   * The "copy link" button for a resource
   * Manually building path from sites and the document list
* Error handling - do we want to do some better error handling here if any of the requests fail? e.g. particularly bad if downloading a resource which doesn't exist
* Testing - look at httptest & vcr which might provide some slightly nicer testing atm we are relying heavily on mocks
* Vignette - write one!
* Upload to sharepoint
