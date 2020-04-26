## Mocks

To effectively test units of pointr we mock out `httr` interactions. 

This is because we only have access to 1 sharepoint instance and we only have personal logins for this. We could setup vault so that the build system can authenticate as via the vault but I'd rather not put my own imperial login credentials into vault.

Mocks:
* security_token_response.rds - The response from `httr::POST` call sent during `get_security_token` with several unneeded fields removed (e.g. cookies, headers etc.) and the content updated manually so the token is a safe one we can use for testing `t=EXAMPLE_TOKEN==&amp;p=`
* cookies_response.rds - The response from `httr:POST` call sent during `get_access_cookies` with unneeded fields removed and cookies updated manually to be a save one we can use for testing. 

### Creating a new mock response

* insert a browser() call just before the call to a client method
* save the response to `mocks/<action>_response_raw.rds`
* strip the url, headers and cookies back to desensitise it (strip_response)
* modify the content as needed
