[![pub](https://img.shields.io/pub/v/genui_catalog?label=pub&logo=dart)](https://pub.dev/packages/genui_catalog/install)
[![stars](https://img.shields.io/github/stars/omarfarouk228/genui_catalog?logo=github)](https://github.com/omarfarouk228/genui_catalog)
[![issues](https://img.shields.io/github/issues/omarfarouk228/genui_catalog?logo=github)](https://github.com/omarfarouk228/genui_catalog/issues)
[![commit](https://img.shields.io/github/last-commit/omarfarouk228/genui_catalog?logo=github)](https://github.com/omarfarouk228/genui_catalog/commits)
<a href="https://github.com/omarfarouk228#sponsor-me"><img src="https://img.shields.io/github/sponsors/omarfarouk228" alt="Sponsoring"></a>
<a href="https://pub.dev/packages/genui_catalog/score"><img src="https://img.shields.io/pub/likes/genui_catalog" alt="likes"></a>
<a href="https://pub.dev/packages/genui_catalog/score"><img src="https://img.shields.io/pub/points/genui_catalog" alt="pub points"></a>

# GenUI Catalog

A catalog of **17 high-level UI components** (plus `Column` / `Row` layout containers) for [A2UI](https://a2ui.org/), rendered with [`a2ui_flutter`](https://pub.dev/packages/a2ui_flutter). Each component ships with its JSON schema, widget binding, event handling, data model bindings, dark/light mode support, and screen-reader semantics — ready to drop into any A2UI-powered Flutter app.

> **Requires** [`a2ui_flutter`](https://pub.dev/packages/a2ui_flutter) `^0.3.0` and [`a2ui_core`](https://pub.dev/packages/a2ui_core) `^0.7.0` (A2UI protocol v1.0).
>
> The [`genui`](https://pub.dev/packages/genui) package is discontinued and replaced by `a2ui_core` + `a2ui_flutter` + `a2ui_agent`. Versions `0.5.x` of this package are the last ones for `genui`; see [Migrating from 0.5 (genui)](#migrating-from-05-genui).

---

## Installation

```yaml
dependencies:
  a2ui_core: ^0.7.0
  a2ui_flutter: ^0.3.0
  genui_catalog: ^0.6.0
  # To prompt a model and parse its replies in the app:
  a2ui_agent: ^0.3.0
```

---

## Demo

[<img src="doc/assets/genui.png" alt="GenUI Catalog" height="500">](https://www.youtube.com/watch?v=hDpVakPp4vc)

### <a href="https://genui-catalog.ofaroukk.com" target="_blank"> Test the demo app</a>

## Getting started

Register the catalog next to the A2UI basic catalog in a `MessageProcessor`, and render each surface with `A2uiSurface`:

```dart
import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:a2ui_flutter/basic_catalog.dart';
import 'package:genui_catalog/genui_catalog.dart';

// 1. Register all components (A2UI v1.0)
final processor = MessageProcessor<ComponentImplementation>(
  catalogs: [basicCatalog(), GenUICatalog.all],
);
processor.model.onSurfaceCreated.subscribe((surface) { /* show it */ });

// 2. Apply the agent's messages
processor.processMessages(messagesFromTheAgent);

// 3. Render a surface
A2uiSurface(surface: surface);
```

The agent names the catalog in `createSurface.catalogId` (or in each component's `catalogId`) with `GenUICatalog.catalogId`.

To prompt a model from the app, `a2ui_agent` builds the system prompt from the catalogs (the JSON Schema of every component plus `GenUICatalog.instructions`) and parses the streamed reply into A2UI messages:

```dart
import 'package:a2ui_agent/a2ui_agent.dart';

final catalogs = [basicCatalog(), GenUICatalog.all];
final agent = A2uiGenerator(
  catalogs: [for (final c in catalogs) CatalogConfig(c)],
  inferenceFormatFactory: const DirectJsonFormatFactory(),
).createProcessor(
  A2uiRendererCapabilities.forCatalogIds(
    [for (final c in catalogs) c.id],
    version: A2uiProtocolVersion.v1_0,
  ),
);

final systemPrompt = '$yourInstructions\n${agent.promptSnippet}'; // send to your LLM

final stream = agent.openStream();
await for (final chunk in llmReply) {
  for (final part in stream.feed(chunk)) {
    if (part case A2uiPart(:final a2ui)) {
      for (final message in a2ui) {
        processor.processMessages(AgentToRendererMessagePayload.of(message));
      }
    }
  }
}
stream.close();
```

The [`/example`](example/) app shows a complete Gemini integration, with user actions sent back to the model, in [`ai_service.dart`](example/lib/services/ai_service.dart).

You can also register only the sub-catalogs you need (each has its own `catalogId`):

```dart
MessageProcessor<ComponentImplementation>(
  catalogs: [
    basicCatalog(),
    DataCatalog.asCatalog(),      // KpiCard, DataTable, ChartCard, StatRow, ListCard, EmptyState, Column, Row
    WorkflowCatalog.asCatalog(),  // TimelineCard, StatusBadge, StepperCard
    FormCatalog.asCatalog(),      // ActionForm, SearchBar, RatingInput, SelectInput, CheckboxGroup, SwitchGroup
    MediaCatalog.asCatalog(),     // ProfileCard, MediaCard
  ],
);
```

### Listening to events

Every interaction is emitted as an `A2uiRendererAction` on `processor.model.onAction` (and sent to the agent through the processor's `outboundListener`). Compare its `name` with the `CatalogEvents` constants:

```dart
processor.model.onAction.subscribe((action) {
  switch (action.name) {
    case CatalogEvents.formSubmit:      // 'form_submit', field values in action.context
    case CatalogEvents.ratingSubmitted: // 'rating_submitted', {rating, maxStars} in action.context
    case CatalogEvents.searchQuery:     // 'search_query', {query} in action.context
    case CatalogEvents.stepNext:        // 'next_step'
    case CatalogEvents.stepPrev:        // 'prev_step'
    // SelectInput sends '<event>:<value>'
    // CheckboxGroup sends '<event>:<csv_values>'
    // SwitchGroup sends '<event>:<value>:<on|off>'
    //   (with submitLabel, both send '<event>:<csv_values>' once)
    // ListCard, MediaCard, ProfileCard send each item's / button's `event`
  }
});
```

`ActionForm`, `SearchBar`, `RatingInput` and `EmptyState` also take an A2UI `action`. When the agent declares one, it runs **instead of** the default event, so the agent picks the event name and builds its context from the data model:

```json
{
  "id": "stars",
  "component": "RatingInput",
  "value": { "@path": "/review/stars" },
  "action": {
    "event": {
      "name": "review_rated",
      "context": { "stars": { "@path": "/review/stars" } }
    }
  }
}
```

### Data model bindings

Text properties (titles, labels, values…) accept a literal or a binding such as `{"@path": "/kpi/mrr"}`, so the agent can update a surface with `updateDataModel` instead of resending its components.

Inputs write what the user enters to the path their value is bound to:

| Component | Property | Written value |
| --- | --- | --- |
| `RatingInput` | `value` | the rating (number); also shows the rating found there |
| `SearchBar` | `value` | the query, once it meets `minChars` |
| `SelectInput` | `value` | the selected value; also pre-selects it |
| `CheckboxGroup` | `values` | the checked values; also pre-checks them |
| `SwitchGroup` | `values` | the switched-on values, in the options' order |
| `ActionForm` | `values` | `{key: value}` of every field, on valid submit |

Combined with the basic catalog's `Button`, this lets the agent build forms in the A2UI style: inputs bound to paths, and one button whose action context reads them.

### Catalog introspection

```dart
// List all registered component names
print(GenUICatalog.itemNames);
// → [KpiCard, DataTable, ChartCard, StatRow, TimelineCard, ...]

// Look up a component by name
final item = GenUICatalog.findItem('KpiCard'); // null if not found

// The catalog document, for an agent that does not use a2ui_core
jsonEncode(GenUICatalog.all.toJson());
```

### Migrating from 0.5 (genui)

| 0.5 (genui) | 0.6 (A2UI) |
| --- | --- |
| `genui: ^0.10.3` | `a2ui_core: ^0.7.0`, `a2ui_flutter: ^0.3.0` (+ `a2ui_agent: ^0.3.0`) |
| `SurfaceController(catalogs: [GenUICatalog.all])` | `MessageProcessor(catalogs: [basicCatalog(), GenUICatalog.all])` |
| `Surface(surfaceContext: controller.contextFor(id))` | `A2uiSurface(surface: processor.model.getSurface(id)!)` |
| `PromptBuilder.chat(catalog: ...)` | `A2uiGenerator(...).createProcessor(...).promptSnippet` |
| `controller.onSubmit` + `UiInteractionPart` decoding | `processor.model.onAction` → `action.name`, `action.context` |
| `CatalogItem` | `ComponentImplementation` |
| `Catalog` | `CatalogImplementation` |
| `catalogId: 'genui_catalog'` (and `genui_catalog/data`, …) | `GenUICatalog.catalogId` (and `DataCatalog.catalogId`, …), now URIs |
| `systemPromptFragments` | `instructions` (strings on each catalog) |
| messages `"version": "v0.9"` | `"version": "1.0"`, bindings written `{"@path": ...}` |

Event names and contexts are unchanged, so code matching `CatalogEvents` keeps working. `search_query` now also carries `{query}`.

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

- `children`: array of component IDs from the same surface (they may come from another catalog, such as the basic one).
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

Guides the user through a multi-step process. Dispatches `CatalogEvents.stepNext` / `CatalogEvents.stepPrev` from the navigation buttons. Tapping a step indicator shows that step without dispatching anything.

```json
{
  "title": "Account setup",
  "currentStep": 0,
  "showNavigation": true,
  "previousLabel": "Previous",
  "nextLabel": "Next",
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

Renders a dynamic form and dispatches `CatalogEvents.formSubmit` with the submitted field values when the user submits.

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

`requiredErrorText` (optional) is shown under an empty required field; `{label}` is replaced by the field label. Default: `"{label} is required"`.

`values` (optional, a binding such as `{"@path": "/contact"}`) receives `{key: value}` of every field on submit. `action` (optional) runs instead of `form_submit`.

---

#### SearchBar

A debounced search input. Dispatches `CatalogEvents.searchQuery` with `{"query": "..."}` once the user stops typing and the query meets `minChars`. Bind `value` to receive the query in the data model; `action` (optional) runs instead of `search_query`.

```json
{
  "placeholder": "Search products…",
  "debounceMs": 400,
  "minChars": 3
}
```

---

#### RatingInput

A tappable star rating with optional half-star support. Dispatches `CatalogEvents.ratingSubmitted` on selection, with `{"rating": 4, "maxStars": 5}` in the event context. Also supports keyboard/accessibility increment and decrement.

```json
{
  "title": "Rate your experience",
  "label": "Overall satisfaction",
  "maxStars": 5,
  "allowHalf": false
}
```

`noRatingLabel` and `outOfLabel` (optional) translate what screen readers announce (defaults: `"No rating"`, `"3 out of 5"`).

`value` (optional) is two-way when bound (`{"@path": "/rating"}`): the stars show the rating found there, and each tap writes the new one. `action` (optional) runs instead of `rating_submitted`.

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

Use `initialValue` to pre-select an option, or bind `value` (`{"@path": "/country"}`) to pre-select from and write the selection to the data model.

---

#### CheckboxGroup

A labeled list of checkboxes where the user can select multiple options. Dispatches `<event>:<comma-separated values>` on every change, or once from a button when `submitLabel` is set. Bind `values` (`{"@path": "/prefs"}`) to pre-check from and write the checked values to the data model.

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

A labeled list of on/off toggles. Dispatches `<event>:<value>:<on|off>` each time a switch is flipped. With `submitLabel`, switches change locally and a button dispatches `<event>:<comma-separated values that are on>` once. Bind `values` to pre-select from and write the switched-on values to the data model.

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

See the [`/example`](example/) folder for a full demo app showcasing all 17 components with live Gemini generation through `a2ui_agent`.

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
