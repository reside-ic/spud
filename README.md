# spud <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->
[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![R build status](https://github.com/reside-ic/pointr/workflows/R-CMD-check/badge.svg)](https://github.com/reside-ic/pointr/actions)
[![Build status](https://badge.buildkite.com/2f80635022481989da55f4be29951a8f0902eedea92956761e.svg)](https://buildkite.com/mrc-ide/spud)
[![codecov.io](https://codecov.io/github/reside-ic/spud/coverage.svg?branch=master)](https://codecov.io/github/reside-ic/spud?branch=master)
<!-- badges: end -->

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

## Tests

Most of the tests make heavy use of mocks, so if the API changes we might not catch breaking changes. In order to hedge against this we run a small number of integration tests against sharepoint. To opt into running these tests you need to define some environment variables:

```
SPUD_TEST_SHAREPOINT_USERNAME=you@example.com
SPUD_TEST_SHAREPOINT_PASSWORD=s3cret!
SPUD_TEST_SHAREPOINT_HOST=https://example.sharepoint.com
SPUD_TEST_SHAREPOINT_SITE=yoursite
SPUD_TEST_SHAREPOINT_ROOT=path/on/your/site
```

This will create a new directory on your sharepoint site below the path given at `SPUD_TEST_SHAREPOINT_ROOT`, one per time the test suite is run, and it will add, list, remove files that are there.

## License

MIT © Imperial College of Science, Technology and Medicine
