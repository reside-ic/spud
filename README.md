# spud <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->
[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![R build status](https://github.com/reside-ic/pointr/workflows/R-CMD-check/badge.svg)](https://github.com/reside-ic/pointr/actions)
[![Build status](https://badge.buildkite.com/2f80635022481989da55f4be29951a8f0902eedea92956761e.svg?branch=master)](https://buildkite.com/mrc-ide/spud)
[![codecov.io](https://codecov.io/github/reside-ic/spud/coverage.svg?branch=master)](https://codecov.io/github/reside-ic/spud?branch=master)
<!-- badges: end -->

This app uses [Microsoft365R](https://github.com/Azure/Microsoft365R) for programmatically accessing sharepoint. This is just a wrapper around Microsoft365R to expose an interface we want to use for interacting with sharepoint from orderly.


## Authentication

See [Microsoft365R docs](https://github.com/Azure/Microsoft365R#authentication).


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
