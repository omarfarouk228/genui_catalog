# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-02

### Added

#### DataCatalog
- **KpiCard** — Single metric card with title, value, subtitle, trend badge (up/down/neutral) and hex accent color
- **DataTable** — Scrollable tabular data with configurable columns, up to 100 rows, optional striped rows
- **ChartCard** — Line, Bar, and Pie charts powered by `fl_chart`, supports up to 6 datasets with legend
- **StatRow** — Horizontal row of 2–4 stat items with icon, value, and label

#### WorkflowCatalog
- **TimelineCard** — Vertical event timeline with done/active/pending status indicators
- **StatusBadge** — Colored chip for success/warning/error/info/neutral statuses
- **StepperCard** — Multi-step process navigator with optional Prev/Next navigation buttons dispatching `next_step` / `prev_step` events

#### FormCatalog
- **ActionForm** — Dynamic form renderer supporting text/email/number/textarea fields with submit action; dispatches `form_submit` event
- **SearchBar** — Debounced search input with configurable delay and minimum character threshold; dispatches `search_query` event
- **RatingInput** — Star rating widget with configurable max stars and optional half-star support; dispatches `rating_submitted` event

#### MediaCatalog
- **ProfileCard** — Avatar (or initials fallback), name, role, detail list, and custom action buttons
- **MediaCard** — Image, title, body text, tag chips, and custom action buttons

#### Infrastructure
- `GenUICatalog.all` — Single `Catalog` combining all 12 items, ready for `SurfaceController`
- Individual sub-catalog classes (`DataCatalog`, `WorkflowCatalog`, `FormCatalog`, `MediaCatalog`) each exposing `items` and `asCatalog()`
- `parseHexColor()` utility for `"#RRGGBB"` color strings
- `parseIconName()` utility mapping icon name strings to `IconData`
- Example Flutter application showcasing all 12 components with mock data
