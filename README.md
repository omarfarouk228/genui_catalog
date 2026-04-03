[![pub](https://img.shields.io/pub/v/genui_catalog?label=pub&logo=dart)](https://pub.dev/packages/genui_catalog/install)
[![stars](https://img.shields.io/github/stars/omarfarouk228/genui_catalog?logo=github)](https://github.com/omarfarouk228/genui_catalog)
[![issues](https://img.shields.io/github/issues/omarfarouk228/genui_catalog?logo=github)](https://github.com/omarfarouk228/genui_catalog/issues)
[![commit](https://img.shields.io/github/last-commit/omarfarouk228/genui_catalog?logo=github)](https://github.com/omarfarouk228/genui_catalog/commits)
<a href="https://github.com/omarfarouk228#sponsor-me"><img src="https://img.shields.io/github/sponsors/omarfarouk228" alt="Sponsoring"></a>
<a href="https://pub.dev/packages/genui_catalog/score"><img src="https://img.shields.io/pub/likes/genui_catalog" alt="likes"></a>
<a href="https://pub.dev/packages/genui_catalog/score"><img src="https://img.shields.io/pub/points/genui_catalog" alt="pub points"></a>

# GenUI Catalog

A catalog of **17 high-level UI components** built on top of the [`genui`](https://pub.dev/packages/genui) SDK. Each component ships with its JSON schema, widget binding, event handling, dark/light mode support, and screen-reader semantics — ready to drop into any GenUI-powered app.

> **Requires** [`genui`](https://pub.dev/packages/genui) `^0.8.0`

---

## Installation

```yaml
dependencies:
  genui: ^0.8.0
  genui_catalog: ^0.2.1
```

---

## Demo

[<img src="doc/assets/genui.png" alt="GenUI Catalog" height="500">](https://www.youtube.com/watch?v=hDpVakPp4vc)

---

## Getting started

Register the catalog with your `SurfaceController`. The system prompt is generated automatically from the catalog metadata, so the LLM always knows which components are available and what data each one expects.

```dart
import 'package:genui_catalog/genui_catalog.dart';

// 1. Register all components
final controller = SurfaceController(
  catalogs: [GenUICatalog.all],
);

// 2. Build a prompt that references them
final prompt = PromptBuilder.chat(
  catalog: GenUICatalog.all,
  instructions: 'You are a dashboard assistant.',
);
```

You can also register only the sub-catalogs you need:

```dart
SurfaceController(
  catalogs: [
    DataCatalog.asCatalog(),      // KpiCard, DataTable, ChartCard, StatRow, ListCard, EmptyState
    WorkflowCatalog.asCatalog(),  // TimelineCard, StatusBadge, StepperCard
    FormCatalog.asCatalog(),      // ActionForm, SearchBar, RatingInput, SelectInput, CheckboxGroup, SwitchGroup
    MediaCatalog.asCatalog(),     // ProfileCard, MediaCard
  ],
);
```

### Listening to events

Use `CatalogEvents` constants instead of raw strings to avoid typos:

```dart
import 'package:genui_catalog/genui_catalog.dart';

controller.on<UserActionEvent>((event) {
  switch (event.name) {
    case CatalogEvents.formSubmit:      // 'form_submit'
    case CatalogEvents.ratingSubmitted: // 'rating_submitted'
    case CatalogEvents.searchQuery:     // 'search_query'
    case CatalogEvents.stepNext:        // 'next_step'
    case CatalogEvents.stepPrev:        // 'prev_step'
    // SelectInput dispatches '<event>:<value>'
    // CheckboxGroup dispatches '<event>:<csv_values>'
    // SwitchGroup dispatches '<event>:<value>:<on|off>'
  }
});
```

### Catalog introspection

```dart
// List all registered component names
print(GenUICatalog.itemNames);
// → [KpiCard, DataTable, ChartCard, StatRow, TimelineCard, ...]

// Look up a component by name
final item = GenUICatalog.findItem('KpiCard'); // null if not found
```

---

## Components

### 📊 Data

#### KpiCard

Displays a single metric with an optional trend indicator.

```json
{
  "title": "Total Revenue",
  "value": "$142,500",
  "subtitle": "This quarter",
  "trend": "up",
  "trendValue": "+12%",
  "color": "#4CAF50"
}
```

`trend` accepts `"up"` · `"down"` · `"neutral"`

---

#### DataTable

Renders tabular data with configurable columns. Recommended ≤ 50 rows, hard limit 100. Displays a "Showing X of Y rows" indicator when data is truncated.

```json
{
  "title": "Team Members",
  "columns": [
    { "key": "name", "label": "Name" },
    { "key": "role", "label": "Role" },
    { "key": "status", "label": "Status", "align": "center" }
  ],
  "rows": [{ "name": "Alice", "role": "Designer", "status": "Active" }],
  "striped": true
}
```

`align` accepts `"left"` · `"center"` · `"right"`

---

#### ChartCard

Renders a Line, Bar, or Pie chart. Supports up to 6 datasets. Displays an indicator when more datasets are provided.

```json
{
  "title": "Monthly Sales",
  "chartType": "bar",
  "xLabels": ["Jan", "Feb", "Mar", "Apr"],
  "showLegend": true,
  "datasets": [
    {
      "label": "Revenue",
      "color": "#2196F3",
      "values": [42000, 55000, 48000, 63000]
    },
    {
      "label": "Expenses",
      "color": "#E91E63",
      "values": [30000, 38000, 35000, 41000]
    }
  ]
}
```

`chartType` accepts `"line"` · `"bar"` · `"pie"`

---

#### StatRow

Displays 2–4 stats side by side.

```json
{
  "stats": [
    {
      "label": "Users",
      "value": "8,291",
      "icon": "people",
      "color": "#2196F3"
    },
    {
      "label": "Orders",
      "value": "1,432",
      "icon": "shopping_cart",
      "color": "#FF9800"
    }
  ]
}
```

Icons are resolved by name via `parseIconName()`. Over 200 names are supported, including aliases (`dollar`, `heart`, `clock`, `globe`, `ai`, `trophy`, …). Unknown names fall back to a neutral label icon.

---

#### Column

A layout container to stack children vertically by ID.

```json
{
  "id": "root",
  "component": "Column",
  "children": ["ratingInput", "reviewForm"],
  "spacing": 12,
  "mainAxisAlignment": "start",
  "crossAxisAlignment": "stretch"
}
```

- `children`: array of component IDs in the same `updateComponents` payload.
- `spacing`: optional vertical gap in logical pixels.
- `mainAxisAlignment`: `start` | `center` | `end` | `spaceBetween` | `spaceAround` | `spaceEvenly`
- `crossAxisAlignment`: `start` | `center` | `end` | `stretch`

---

#### Row

A layout container to stack children horizontally by ID. Wraps automatically on bounded-width containers.

```json
{
  "id": "root",
  "component": "Row",
  "children": ["label1", "label2"],
  "spacing": 8,
  "mainAxisAlignment": "start",
  "crossAxisAlignment": "center"
}
```

Same axis values as `Column`.

---

#### ListCard

A card containing a scrollable list of tappable rows, each with an optional icon, subtitle, trailing text, and destructive styling.

```json
{
  "title": "Quick Actions",
  "showDividers": true,
  "items": [
    { "title": "Edit profile", "icon": "edit", "event": "edit_profile" },
    { "title": "Share", "icon": "share", "event": "share" },
    {
      "title": "Delete account",
      "icon": "delete",
      "event": "delete_account",
      "destructive": true
    }
  ]
}
```

- `icon`: any name supported by `parseIconName()`.
- `trailingText`: replaces the chevron when set.
- `destructive`: renders the row in the error color.
- Items without an `event` are non-tappable.

---

#### EmptyState

A centered illustration with title, description text, and an optional call-to-action button. Use when a list or view has no content to show.

```json
{
  "title": "No results found",
  "description": "Try adjusting your search or filters.",
  "icon": "search",
  "actionLabel": "Clear filters",
  "actionEvent": "clear_filters"
}
```

Dispatches `actionEvent` when the button is tapped.

---

### 🔄 Workflow

#### TimelineCard

Shows a vertical sequence of events with status indicators.

```json
{
  "title": "Order #1042",
  "events": [
    {
      "time": "09:00",
      "title": "Order placed",
      "description": "Payment confirmed",
      "status": "done"
    },
    {
      "time": "11:30",
      "title": "Shipped",
      "description": "Tracking: XYZ123",
      "status": "done"
    },
    {
      "time": "14:00",
      "title": "Out for delivery",
      "description": "",
      "status": "active"
    },
    {
      "time": "17:00",
      "title": "Delivered",
      "description": "",
      "status": "pending"
    }
  ]
}
```

`status` accepts `"done"` · `"active"` · `"pending"`

---

#### StatusBadge

A colored chip conveying a status at a glance.

```json
{
  "label": "Operational",
  "status": "success",
  "description": "All systems running normally."
}
```

`status` accepts `"success"` · `"warning"` · `"error"` · `"info"` · `"neutral"`

---

#### StepperCard

Guides the user through a multi-step process. Dispatches `CatalogEvents.stepNext` / `CatalogEvents.stepPrev`.

```json
{
  "title": "Account setup",
  "initialStep": 0,
  "showNavigation": true,
  "steps": [
    { "title": "Profile", "description": "Fill in your details." },
    { "title": "Security", "description": "Set up 2FA." },
    { "title": "Finish", "description": "Review and confirm." }
  ]
}
```

---

### 📝 Forms

#### ActionForm

Renders a dynamic form and dispatches `CatalogEvents.formSubmit` when the user submits.

```json
{
  "title": "Contact us",
  "submitLabel": "Send message",
  "successMessage": "Thanks! We'll be in touch.",
  "fields": [
    { "key": "name", "label": "Full name", "type": "text", "required": true },
    { "key": "email", "label": "Email", "type": "email", "required": true },
    {
      "key": "message",
      "label": "Message",
      "type": "textarea",
      "required": false
    }
  ]
}
```

`type` accepts `"text"` · `"email"` · `"number"` · `"textarea"`

---

#### SearchBar

A debounced search input. Dispatches `CatalogEvents.searchQuery` once the user stops typing and the query meets `minChars`.

```json
{
  "placeholder": "Search products…",
  "debounceMs": 400,
  "minChars": 3
}
```

---

#### RatingInput

A tappable star rating with optional half-star support. Dispatches `CatalogEvents.ratingSubmitted` on selection. Also supports keyboard/accessibility increment and decrement.

```json
{
  "title": "Rate your experience",
  "label": "Overall satisfaction",
  "maxStars": 5,
  "allowHalf": false
}
```

---

#### SelectInput

A labelled dropdown that lets the user pick one value from a list of options. Dispatches `<event>:<value>` on selection.

```json
{
  "label": "Country",
  "placeholder": "Select a country",
  "event": "country_selected",
  "options": [
    { "value": "us", "label": "United States" },
    { "value": "fr", "label": "France" },
    { "value": "de", "label": "Germany" }
  ]
}
```

Use `initialValue` to pre-select an option.

---

#### CheckboxGroup

A labeled list of checkboxes where the user can select multiple options. Dispatches `<event>:<comma-separated values>` on every change.

```json
{
  "label": "Notification preferences",
  "event": "prefs_changed",
  "initialValues": ["email"],
  "options": [
    { "value": "email", "label": "Email notifications" },
    { "value": "sms", "label": "SMS notifications" },
    { "value": "push", "label": "Push notifications" }
  ]
}
```

---

#### SwitchGroup

A labeled list of on/off toggles. Dispatches `<event>:<value>:<on|off>` each time a switch is flipped.

```json
{
  "label": "Privacy settings",
  "event": "privacy_changed",
  "initialValues": ["analytics"],
  "options": [
    {
      "value": "analytics",
      "label": "Analytics",
      "subtitle": "Help improve the app"
    },
    {
      "value": "personalized",
      "label": "Personalised",
      "subtitle": "Tailored content"
    }
  ]
}
```

---

### 🖼️ Media

#### ProfileCard

Shows an avatar (or initials fallback), contact details, and action buttons.

```json
{
  "name": "Sarah Connor",
  "role": "Senior Engineer",
  "avatarUrl": "https://example.com/avatar.jpg",
  "details": [
    { "label": "Email", "value": "sarah@acme.com" },
    { "label": "Location", "value": "San Francisco" }
  ],
  "actions": [
    { "label": "Message", "event": "profile_message" },
    { "label": "Call", "event": "profile_call" }
  ]
}
```

Each action button dispatches its `event` string.

---

#### MediaCard

A content card with an optional image, body text, tags, and action buttons.

```json
{
  "title": "Introducing GenUI Catalog",
  "content": "A set of ready-to-use components for AI-generated UIs.",
  "imageUrl": "https://example.com/cover.jpg",
  "tags": ["flutter", "AI", "genui"],
  "actions": [
    { "label": "Read more", "event": "media_open" },
    { "label": "Share", "event": "media_share" }
  ]
}
```

Each action button dispatches its `event` string.

---

## Utilities

Both utilities are exported from `genui_catalog` and can be used directly when building custom components that sit alongside the catalog.

### `parseHexColor(String hex, {Color fallback})`

Parses a hex color string into a Flutter `Color`. Useful when your custom widget receives a color value from the LLM as a string.

```dart
import 'package:genui_catalog/genui_catalog.dart';

final color = parseHexColor(
  data['color'] as String? ?? '',
  fallback: Theme.of(context).colorScheme.primary, // theme-aware fallback
);
```

Accepts `"#2196F3"` or `"2196F3"` (6-char) and `"802196F3"` (8-char with alpha). Returns `fallback` on parse failure.

### `parseIconName(String name)`

Maps an icon name string to a Flutter `IconData`. Useful when your custom widget receives an icon name from the LLM.

```dart
import 'package:genui_catalog/genui_catalog.dart';

final icon = parseIconName(data['icon'] as String? ?? '');
// → IconData (or Icons.label_outline for unknown names)
```

Supports 200+ names in snake_case, kebab-case, and common aliases (`dollar`, `heart`, `clock`, `globe`, `ai`, `trophy`, …).

---

## Design system

All widgets are fully theme-aware:

- Colors use `ColorScheme` tokens (`onSurfaceVariant`, `surfaceContainerHighest`, `primary`, `error`, `onPrimary`, …) — no hardcoded greys.
- All widgets adapt automatically to light and dark mode.
- Screen-reader semantics (`Semantics`) are applied throughout: sliders, buttons, status labels, step indicators, table regions, and card summaries.

---

## Example

See the [`/example`](example/) folder for a full demo app showcasing all 12 components.

```bash
cd example
flutter pub get
flutter run
```

---

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/omarfarouk228/genui_catalog).

## License

MIT — see the [LICENSE](LICENSE) file for details.

## Author

[Omar Farouk](https://github.com/omarfarouk228)
