# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-02

### Added

- Initial release of genui_catalog with full catalog scaffolding:
  - `DataCatalog` : KpiCard, DataTable, ChartCard, StatRow
  - `WorkflowCatalog`: TimelineCard, StatusBadge, StepperCard
  - `FormCatalog`: ActionForm, SearchBar, RatingInput
  - `MediaCatalog`: ProfileCard, MediaCard
- Utilities: `parseHexColor()`, `parseIconName()`
- Root helper: `GenUICatalog.all` and subcatalog `asCatalog()` extensions

### Fixed

- Updated `CatalogItem.widgetBuilder` API to use `CatalogItemContext` (genui 0.8.0 compatibility)
- Fixed `dispatchEvent` conversion for widgets requiring `void Function(String)`
- Added comprehensive unit tests for `StatusBadge` and `ActionForm`.

## [0.1.1] - 2026-04-03

### Added

- Unit tests: `test/genui_catalog_test.dart` (StatusBadge widget + ActionForm event dispatch)

### Fixed

- `genui_catalog` now passes `flutter test` and `flutter analyze` with no errors (only style/info warnings)
