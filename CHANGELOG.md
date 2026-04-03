# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2026-04-03

### Changed

- Adding the link of demo app to the README.md file.

## [0.2.1] - 2026-04-03

### Changed

- **`AiService` JSON parsing** — replaced the multi-strategy extraction pipeline
  (5 fallback strategies, 7 helper methods) with a single `_extractJsonObjectsFromContent`
  call using brace-counting. Validation now also checks for `createSurface` or
  `updateComponents` keys so non-A2UI JSON objects are silently skipped without
  extra repair attempts.
- **`AiService` truncation repair** — added trailing-brace repair inside
  `_extractJsonObjectsFromContent` so LLM-truncated JSON (unclosed `}`) is
  recovered gracefully before being dispatched to the transport.

### Fixed

- **`CHANGELOG.md` formatting** — corrected list marker from `+` to `-` in the
  `RatingInputWidget` half-star detection entry.

---

## [0.2.0] - 2026-04-03

### Added

- **`ListCard`** (`DataCatalog`) — a card containing a list of tappable rows with optional
  icon, subtitle, trailing text, dividers, and destructive flag (`red` error color).
- **`EmptyState`** (`DataCatalog`) — a centered empty-state view with title, description,
  icon, and an optional call-to-action button that dispatches a configurable event.
- **`SelectInput`** (`FormCatalog`) — a labelled dropdown for single-value selection;
  dispatches `<event>:<value>` on change.
- **`CheckboxGroup`** (`FormCatalog`) — a labeled multi-select checkbox list; dispatches
  `<event>:<csv_values>` on every change.
- **`SwitchGroup`** (`FormCatalog`) — a labeled list of on/off toggles with optional
  subtitles; dispatches `<event>:<value>:<on|off>` per toggle.
- **`CatalogEvents` additions** — `listItemTapped`, `emptyStateAction`,
  `optionSelected`, `selectionChanged`, `switchChanged` constants.
- **30 new widget tests** across 5 focused files for all new components.

---

## [0.1.0] - 2026-04-03

### Added

- **`CatalogEvents`** — typed constants for all widget-dispatched event names
  (`formSubmit`, `ratingSubmitted`, `searchQuery`, `stepNext`, `stepPrev`).
- **`GenUICatalog.itemNames`** — dynamic list of all registered component names.
- **`GenUICatalog.findItem(String name)`** — null-safe lookup of a `CatalogItem` by name.
- **System prompt auto-generation** — each sub-catalog now generates its
  `systemPromptFragments` from the live item list; adding a component updates
  the prompt automatically.
- **Truncation indicators** — `DataTableWidget` shows "Showing X of Y rows"
  when the 100-row limit is exceeded; `ChartCardWidget` shows "Showing X of Y
  datasets" when the 6-dataset limit is exceeded.
- **`totalRowCount` / `totalDatasetCount`** optional parameters on
  `DataTableWidget` and `ChartCardWidget` to drive the truncation indicator.
- **Accessibility (`Semantics`)** — all 12 widgets now carry meaningful screen-reader
  labels: KpiCard (metric + trend), StatusBadge (status text), RatingInput
  (slider with increment/decrement), StepperCard (step X of N), TimelineCard
  (per-event label), DataTable (table region), StatRow (value + label per card),
  ProfileCard (name + role + details), MediaCard (title + content + tags).
- **`parseHexColor` `fallback` parameter** — callers can now pass a theme-aware
  color (e.g. `Theme.of(context).colorScheme.primary`) instead of falling back to
  the hardcoded `Colors.blue`.
- **`itemNames` getter** on each sub-catalog (`DataCatalog`, `WorkflowCatalog`,
  `FormCatalog`, `MediaCatalog`).
- **76 widget and utility tests** split across 15 focused files under
  `test/utils/`, `test/widgets/`, and `test/items/`, with shared helpers in
  `test/helpers.dart`.

### Changed

- **Dark/light mode** — replaced all hardcoded `Colors.grey[X]` and `Colors.white`
  usages with `ColorScheme` semantic tokens (`onSurfaceVariant`, `outlineVariant`,
  `onPrimary`, `surfaceContainerHighest`, `primaryContainer`, `onPrimaryContainer`).
- **`icon_utils.dart`** — expanded from ~25 to 200+ icon mappings across
  categories: trends, people, finance, commerce, analytics, communication,
  navigation, status, actions, files, location, time, tech, settings, health,
  and more. Unknown names now fall back to `Icons.label_outline` instead of
  `Icons.circle`.
- **`ChartCardWidget._defaultColors`** is now `static const` — allocated once
  instead of on every build.
- **`StatRowWidget._limit`** is now a named constant; the `.take(4)` truncation
  moved from the item into the widget and produces a debug `assert` with an
  explanatory message.
- **`RatingInputWidget` half-star detection** — rewrote using per-star `SizedBox`
  - `Stack` with two transparent `GestureDetector` halves, replacing the broken
    `findRenderObject()` approximation.
- **`RatingInputWidget` keyboard/accessibility** — added `Semantics(slider: true)`
  with `onIncrease` / `onDecrease` callbacks so assistive technologies can
  increment and decrement the rating.
- **Sub-catalog system prompts** now include constraint details (row limits,
  dataset limits, accepted enum values) and are generated from live metadata
  rather than hardcoded strings.
- `pubspec.yaml` version corrected from `0.0.1` to `0.1.0`.

### Fixed

- `RatingInputWidget`: half-star gesture used the parent widget's `RenderBox`
  instead of the individual star's, causing incorrect star selection.
- `color_utils.dart`: fallback was always `Colors.blue` regardless of the app
  theme; callers can now provide a context-appropriate fallback.

## [0.0.1] - 2026-04-02

### Added

- Initial release of `genui_catalog`:
  - `DataCatalog`: KpiCard, DataTable, ChartCard, StatRow, Column, Row
  - `WorkflowCatalog`: TimelineCard, StatusBadge, StepperCard
  - `FormCatalog`: ActionForm, SearchBar, RatingInput
  - `MediaCatalog`: ProfileCard, MediaCard
- Utilities: `parseHexColor()`, `parseIconName()`
- Root helper: `GenUICatalog.all` and sub-catalog `asCatalog()` methods
- `CatalogItemContext` API compatibility with `genui ^0.8.0`
- Initial unit tests for `StatusBadge` and `ActionForm`
