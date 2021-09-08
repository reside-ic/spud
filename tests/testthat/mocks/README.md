## Mocks

To effectively test units of spud we mock out `Microsoft365R` interactions. 

This is because we only have access to 1 sharepoint instance and we only have personal logins for this. We could setup vault so that the build system can authenticate as via the vault but I'd rather not put my own imperial login credentials into vault.

Mocks:
* list_items_response.rds - list of files and folders within a drive with full metadata returned from a call to `drive$list_items(path, info = "all")` and manually changed some of the identifying information
