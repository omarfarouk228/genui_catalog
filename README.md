[![pub](https://img.shields.io/pub/v/genui_catalog?label=pub&logo=dart)](https://pub.dev/packages/genui_catalog/install)
[![stars](https://img.shields.io/github/stars/omarfarouk228/genui_catalog?logo=github)](https://github.com/omarfarouk228/genui_catalog)
[![issues](https://img.shields.io/github/issues/omarfarouk228/genui_catalog?logo=github)](https://github.com/omarfarouk228/genui_catalog/issues)
[![commit](https://img.shields.io/github/last-commit/omarfarouk228/genui_catalog?logo=github)](https://github.com/omarfarouk228/genui_catalog/commits)
<a href="https://github.com/omarfarouk228#sponsor-me"><img src="https://img.shields.io/github/sponsors/omarfarouk228" alt="Sponsoring"></a>
<a href="https://pub.dev/packages/genui_catalog/score"><img src="https://img.shields.io/pub/likes/genui_catalog" alt="likes"></a>
<a href="https://pub.dev/packages/genui_catalog/score"><img src="https://img.shields.io/pub/points/genui_catalog" alt="pub points"></a>

# GenUI Catalog

A catalog of **12 high-level UI components** built on top of the [`genui`](https://pub.dev/packages/genui) SDK. Each component comes with its JSON schema, widget binding, and event handling — ready to drop into any GenUI-powered app.

> **Requires** [`genui`](https://pub.dev/packages/genui) `^0.8.0`

---

## Installation

```yaml
dependencies:
  genui: ^0.8.0
  genui_catalog: ^0.1.0
```

---

## Getting started

Register the catalog with your `SurfaceController`, then reference it in your `PromptBuilder`. The LLM will automatically know which components are available and what data each one expects.

```dart
import 'package:genui_catalog/genui_catalog.dart';

// 1. Register components
final controller = SurfaceController(
  catalogs: [
    BasicCatalogItems.asCatalog(),
    GenUICatalog.all,
  ],
);

// 2. Build a prompt that knows about them
final prompt = PromptBuilder.chat(
  catalog: GenUICatalog.all,
  instructions: 'You are a dashboard assistant.',
);
```

You can also register only the sub-catalogs you need:

```dart
SurfaceController(
  catalogs: [
    BasicCatalogItems.asCatalog(),
    DataCatalog.asCatalog(),      // KpiCard, DataTable, ChartCard, StatRow
    WorkflowCatalog.asCatalog(),  // TimelineCard, StatusBadge, StepperCard
    FormCatalog.asCatalog(),      // ActionForm, SearchBar, RatingInput
    MediaCatalog.asCatalog(),     // ProfileCard, MediaCard
  ],
);
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

Renders tabular data with configurable columns. Recommended ≤ 50 rows, hard limit 100.

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

Renders a Line, Bar, or Pie chart. Supports up to 6 datasets.

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

Guides the user through a multi-step process. Dispatches `next_step` / `prev_step`.

```json
{
  "title": "Account setup",
  "currentStep": 1,
  "showNavigation": true,
  "steps": [
    {
      "title": "Profile",
      "description": "Fill in your details.",
      "completed": true
    },
    { "title": "Security", "description": "Set up 2FA.", "completed": false },
    {
      "title": "Finish",
      "description": "Review and confirm.",
      "completed": false
    }
  ]
}
```

---

### 📝 Forms

#### ActionForm

Renders a dynamic form and dispatches `form_submit` with the filled values.

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

`form_submit` payload → `{ "values": { "name": "...", "email": "...", "message": "..." } }`

---

#### SearchBar

A debounced search input that dispatches `search_query` once the user stops typing.

```json
{
  "placeholder": "Search products…",
  "debounceMs": 400,
  "minChars": 3
}
```

`search_query` payload → `{ "query": "flutter" }`

---

#### RatingInput

A tappable star rating. Dispatches `rating_submitted` on selection.

```json
{
  "title": "Rate your experience",
  "label": "Overall satisfaction",
  "maxStars": 5,
  "allowHalf": false
}
```

`rating_submitted` payload → `{ "rating": 4 }`

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
