# RGEEtools 0.2.0

## Package usability and validation

- Added package metadata, an MIT license, and explicit `rgee` dependency
  metadata.
- Removed the developer-only `start()` helper and experimental, undocumented
  code that attached packages or relied on local setup.
- Validated ROI coordinate strings without evaluating them as R code, and
  added checks for query arguments and feature collection structure.
- Made `geetodf()` handle empty collections and missing feature properties;
  made `thin()` return row indices without modifying its input.
- Updated installation/setup instructions and added credential-free tests and
  an R CMD check workflow.
