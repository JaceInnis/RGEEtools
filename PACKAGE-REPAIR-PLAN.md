# RGEEtools package repair plan

## Purpose

Bring RGEEtools from its current early-development state to a package that can
be installed, loaded, understood, tested, and used by someone other than its
author. Preserve its intended role—sampling ocean data from Google Earth
Engine, especially HYCOM, and converting results into R-friendly data—while
making its behavior and requirements explicit.

This is a work plan, not a claim that the current code has been fully audited.
The observations below are based on the repository as it stands; runtime
behavior, upstream dataset details, and intended API decisions still need to
be verified during implementation.

## Baseline state observed when this plan was written

- The repository has the basic R package layout (`DESCRIPTION`, `NAMESPACE`,
  `R/`, and `man/`) and a README with an installation example and plotting
  workflow.
- `DESCRIPTION` has a placeholder license, an incomplete/rough package
  description, and no declared `Imports` or `Suggests`.
- The source calls packages including `rgee`, `lubridate`, `stringr`,
  `dplyr`, and `magrittr`/`%>%`, but the package metadata does not declare
  dependencies.
- There is no `tests/`, `.github/`, or `vignettes/` directory in the
  repository.
- Several help topics have empty `\value{}` sections, sparse parameter
  descriptions, and examples which appear inconsistent with function
  signatures. For example, the README calls `wvtolist()` without `depth`,
  while its current signature requires it.
- The exported API includes `ROI()`, `geetodf()`, the four `*tolist()`
  functions, `start()`, and `thin()`. `vis()` is defined in the source but is
  not exported or documented in `NAMESPACE`.
- `ROI()` builds and evaluates R code from a coordinate string with
  `eval(parse(...))`; malformed input is not validated before it is used.
- `geetodf()` and `thin()` rely on assumptions about non-empty, regularly
  shaped input and columns that are not yet described as a public contract.
- `start()` is documented as a developer tool to remove, uses a machine-
  specific default Python environment path, attaches many packages, and
  initializes Earth Engine as a side effect.
- `hycom.R` and `Playscape.R` contain commented-out code rather than active
  exported features.
- The working tree was clean when this plan was prepared.

## Implementation update

The main repair work has now been applied: package metadata and the MIT
license are in place; developer-only setup and experimental files were
removed; public helpers validate inputs and have complete help topics; the
README, tests, and GitHub Actions check workflow were added. The local test
suite passes without Earth Engine credentials.

Remaining release work is to run the workflow in GitHub, test the Earth Engine
requests against a configured `rgee` account and current HYCOM datasets, and
resolve any upstream band/date or service-limit behavior that cannot be
verified offline. These checks are intentionally not represented as completed
by the local tests.

## Guiding principles

1. Confirm intended behavior before changing data semantics or removing
   functions that users may already call.
2. Keep optional Earth Engine setup separate from package loading; installing
   or attaching RGEEtools should not initialize external services.
3. Make all runtime dependencies explicit and minimize the required dependency
   set.
4. Validate inputs at public function boundaries and return predictable,
   documented output shapes.
5. Keep generated help and namespace files synchronized with their roxygen
   source.
6. Use deterministic local tests for core logic and isolate tests that require
   Earth Engine credentials/network access.
7. Never choose a license on the maintainer's behalf. Confirm the rights
   holder's intent before publishing a license.

## Work plan

### 1. Establish the intended API and user workflow

- Inventory each exported and unexported function and decide which functions
  are supported user-facing API, internal helpers, or obsolete development
  experiments.
- Decide whether `vis()` is intended to be public. If it is, document and
  export it; otherwise keep it internal or remove it after checking for
  existing usage.
- Decide the supported inputs and outputs for `ROI()`, `geetodf()`,
  `wvtolist()`, `wttolist()`, `wstolist()`, `ssetolist()`, and `thin()`.
- Confirm date-window semantics, including whether `interval` counts the
  calendar days before `date`, and verify Earth Engine's end-date behavior.
- Confirm supported HYCOM datasets, bands/depths, sampling limits, treatment
  of missing values, coordinate ordering, and whether combining variable
  collections is supported.
- Decide how Earth Engine initialization should be performed and documented;
  initialization should be an explicit user action, not an implicit package
  load side effect.
- Record compatibility expectations for R and relevant versions of `rgee`.

**Done when:** the public API, supported argument forms, expected return
values, external setup requirements, and unresolved behavior decisions are
written down and agreed with the maintainer.

### 2. Make package metadata installable and complete

- Replace the placeholder `License` only after the rights holder has selected
  a license; add the corresponding license file or standard R license
  expression and files required by that choice.
- Complete `Title`, `Description`, and author/creator/maintainer metadata
  using valid DESCRIPTION conventions; correct spelling and clarify the
  package's purpose without promising unsupported data sources.
- Declare packages used at runtime in `Imports`; place packages needed only
  for examples, tests, or optional workflows in `Suggests`.
- Use qualified calls where practical to avoid broad imports and namespace
  surprises. Declare any required imported functions in roxygen and regenerate
  `NAMESPACE`.
- Set and test the minimum supported R version and document important
  external requirements, especially Earth Engine account/authentication and
  Python configuration where applicable.
- Review `.Rbuildignore` and repository-only files so source archives contain
  the intended package materials and omit local artifacts.

**Done when:** `R CMD build` succeeds and the package metadata passes package
metadata checks without placeholder fields or undeclared runtime dependencies.

### 3. Remove machine-specific setup and clean the package surface

- Remove `start()` from the user-facing package API, as its own documentation
  identifies it as a developer tool. Before removal, check repository
  history/usage and decide whether a deprecation period is warranted.
- Do not replace `start()` with another function that silently attaches
  unrelated packages. Document the supported `rgee`/Earth Engine setup as
  explicit prerequisites and user steps instead.
- Remove or archive commented-out experimental code in `hycom.R` and
  `Playscape.R` after confirming it is not a promised feature.
- Resolve `vis()` consistently with the API decision in step 1.
- Review exports so `NAMESPACE` exposes only supported, documented functions.

**Done when:** package loading has no external initialization or broad package
attachment side effects, no machine-specific paths remain in shipped code, and
the export list matches the supported API.

### 4. Harden and clarify input handling

- Replace `eval(parse())` in `ROI()` with a parser for the documented
  coordinate-string format. Validate numeric longitude/latitude pairs,
  coordinate count/order, empty input, and malformed strings before creating
  an Earth Engine geometry.
- Validate dates, positive `interval`, positive `scale`, supported `depth`,
  and the ROI object's type before issuing Earth Engine requests.
- Return clear errors for invalid inputs and surface Earth Engine failures
  rather than silently returning incomplete or success-shaped results.
- Handle empty feature collections, missing geometries/properties, and
  inconsistent feature columns explicitly in `geetodf()`.
- Make `thin()` validate that the required coordinate columns exist and that
  its thinning factor is a valid positive value; avoid mutating the caller's
  data frame.
- Confirm and document the sampling point limit and what users should do when
  a region/scale combination exceeds it.

**Done when:** invalid and edge-case inputs fail predictably with actionable
messages, valid inputs preserve the agreed output contract, and no caller-
provided input is unexpectedly modified.

### 5. Refactor core behavior into testable units

- Separate date/band construction, feature-list conversion, and validation
  from the Earth Engine request chain where doing so improves isolation.
- Remove reliance on objects expected to exist in the global environment
  (for example, use explicitly namespaced `rgee` access consistently).
- Avoid unnecessary intermediate copies and row-by-row growth in
  `geetodf()`; preserve feature/column correspondence and handle missing values
  without relying on implicit positional assumptions.
- Consolidate repeated HYCOM query logic only if the resulting helper keeps
  dataset and band differences explicit and easy to review.
- Keep output column names stable and define coordinate/value column types.

**Done when:** core transformations can be exercised without contacting
Earth Engine and output shape, column names, and missing-value behavior are
documented and consistent.

### 6. Add documentation that supports a first-time user

- Rewrite the README so the installation route, prerequisites, Earth Engine
  authentication/setup, and working examples match the actual API.
- Fix the stale `wvtolist()` example and avoid relying on unqualified packages
  that the README does not install or load.
- Provide complete help topics for every exported function: argument
  constraints, return values, errors/limitations, and practical examples.
- Ensure examples are lightweight and do not require credentials or network
  access during ordinary documentation checks; use `\donttest{}` or another
  suitable documented convention for live Earth Engine examples.
- Add a vignette only if a longer end-to-end workflow cannot be explained
  clearly in the README and function help.
- Regenerate `README.md`, `NAMESPACE`, and `man/` from their source files using
  the project's selected roxygen workflow; do not hand-edit generated files
  independently.

**Done when:** a new user can install the package, configure required external
services, run a documented example, and understand the returned data without
guessing missing arguments or relying on obsolete instructions.

### 7. Introduce automated tests and checks

- Add `testthat` infrastructure and a test runner configuration.
- Add credential-free unit tests for coordinate parsing/validation,
  date/band argument validation, feature-list conversion, empty/malformed
  feature collections, and thinning behavior.
- Mock or otherwise isolate the Earth Engine call boundary so tests can verify
  constructed request parameters without contacting Google Earth Engine.
- Keep any live integration checks opt-in; do not require credentials for a
  normal local test run or hosted CI.
- Add CI on supported R versions to install dependencies, run tests, and run
  `R CMD check` on the built package.
- Run `R CMD check --as-cran` (or the current equivalent) before release and
  address errors, warnings, and actionable notes.

**Done when:** tests pass from a clean package installation without Earth
Engine credentials, and CI checks the package on the declared supported R
version range.

### 8. Prepare a maintainable release

- Add a concise `NEWS.md` entry describing user-visible API and behavior
  changes, especially any removal/deprecation of `start()`.
- Review versioning and dependency compatibility before publishing a release.
- Confirm the selected license and package ownership, check that no local
  paths or credentials are shipped, and verify the built source archive.
- Install the built archive into a clean R library and smoke-test package
  loading, help lookup, and credential-free examples.
- Publish only after the complete checks above pass and the maintainer has
  reviewed the final API and release notes.

**Done when:** a clean source archive installs and passes its checks, release
notes and license are accurate, and installation/use instructions are
reproducible on a supported setup.

## Suggested order and release gates

1. Complete step 1 decisions before any breaking API changes.
2. Resolve license ownership and package metadata in step 2 before public
   distribution.
3. Clean up setup and exports (step 3), then make inputs and transformations
   reliable (steps 4–5).
4. Build tests alongside the behavioral changes, not only after them (step 7).
5. Update user documentation (step 6) to describe the implemented behavior.
6. Complete release checks (step 8) only after all earlier gates are met.

Do not claim the package is ready for general use until the license is
confirmed, the source archive builds, the normal tests run without external
credentials, and the package check has no unresolved errors or warnings.
