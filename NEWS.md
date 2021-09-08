# spud 0.2.0

* Use `Microsoft365R` to interact with sharepoint (mrc-2596)

# spud 0.1.7

* Folders now expose a public readonly field `site` and `path` (reside-200)

# spud 0.1.6

* Add a delete method to folders (reside-205)

# spud 0.1.5

* Rename package to spud (Sharepoint upload & download) (reside-191)

# pointr 0.1.4

* Support for listing subdirectories (reside-161)

# pointr 0.1.3

* Support for creating folders (reside-160)

# pointr 0.1.2

* Allow caching of authentication data between sessions by saving cookies to disk (reside-155)

# pointr 0.1.1

* Downloading files can overwrite existing files (`overwrite = TRUE`) and can return raw bytes rather than files (`dest = raw()`) (reside-159)

# pointr 0.1.0

* New `sharepoint_folder` class for simple operations with files (download, upload, list)

# pointr 0.0.4

* Added a `NEWS.md` file to track changes to the package.
* In `sharepoint_download()` the default tempfile for `save_path` inherits the 
  file extension from `sharepoint_path`.
* Add a default tempfile for `save_path` argument of `pointr$download()`.
  
