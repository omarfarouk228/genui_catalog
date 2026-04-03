/// Simple in-memory store for the Gemini API key.
///
/// The key is entered once by the user (home screen banner) and
/// reused across all demo screens.
class ApiKeyProvider {
  ApiKeyProvider._();

  static String _key = '';

  static String get key => _key;
  static bool get hasKey => _key.isNotEmpty;

  static void set(String key) => _key = key.trim();
  static void clear() => _key = '';
}
