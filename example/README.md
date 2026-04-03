# GenUI Catalog — Example App

An interactive demo app for the [`genui_catalog`](https://pub.dev/packages/genui_catalog) package. It showcases all 17 components across 5 catalog screens, with AI-powered live generation using the Gemini API.

---

## What's inside

The app has 6 navigation screens:

| Screen | Description |
|---|---|
| **Home** | Component index — tap any card to jump to its catalog screen |
| **AI Demo** | Free-form and preset prompts combining components from any catalog |
| **Data** | `KpiCard`, `DataTable`, `ChartCard`, `StatRow`, `ListCard`, `EmptyState` |
| **Workflow** | `TimelineCard`, `StatusBadge`, `StepperCard` |
| **Forms** | `ActionForm`, `SearchBar`, `RatingInput`, `SelectInput`, `CheckboxGroup`, `SwitchGroup` |
| **Media** | `ProfileCard`, `MediaCard` |

Each catalog screen includes ready-made prompts so you can trigger realistic outputs without writing anything.

---

## Running the app

```bash
cd example
flutter pub get
flutter run
```

Runs on Android, iOS, web, macOS, Windows, and Linux.

---

## Enabling the AI demos

The interactive screens require a **Gemini API key** (free tier available at [aistudio.google.com](https://aistudio.google.com)).

Once you have a key, paste it into the banner on the Home screen. The key is stored in memory for the session — it is never written to disk.

Without a key, all preset prompts and the free-form input are disabled. The static component pages are fully accessible without a key.

---

## Project structure

```
lib/
├── main.dart                     # App entry point, shell, navigation
├── models/
│   └── preset.dart               # Preset prompt model
├── screens/
│   ├── home_screen.dart          # Component grid + API key banner
│   ├── ai_demo_screen.dart       # Free-form AI generation screen
│   ├── data_screen.dart          # DataCatalog presets
│   ├── workflow_screen.dart      # WorkflowCatalog presets
│   ├── forms_screen.dart         # FormCatalog presets
│   └── media_screen.dart         # MediaCatalog presets
├── services/
│   ├── ai_service.dart           # Gemini API integration
│   └── api_key_provider.dart     # In-memory key store
├── utils/
│   └── constants.dart            # Shared URLs and string constants
└── widgets/
    ├── catalog_demo_screen.dart  # Reusable demo screen shell
    └── component_header.dart     # Screen header widget
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `genui` | Core SDK — `SurfaceController`, `CatalogItem`, event dispatch |
| `genui_catalog` | The component catalog being demonstrated |
| `google_generative_ai` | Gemini API client |
| `url_launcher` | pub.dev and GitHub links |
