import 'dart:convert';

// Simulate the problematic JSON content from the logs
const problematicContent =
    '''{"version": "v0{"version": "v0.9", "createSurface": {"surfaceId": "user_directory_123", "catalogId": "genui_catalog", "sendDataModel": true}}
{"version": "v0.9", "updateComponents.9", "createSurface": {"surfaceId": "user_directory_123", "catalogId": "genui_catalog", "sendDataModel": true}}
{"version": "v0.9", "updateComponents": {"surfaceId": "user_directory_123", "components": [{"id": "root", "component": "Column", "spacing": 16, "children": ["profileCard1", "profileCard2", "profile": {"surfaceId": "user_directory_123", "components": [{"id": "root", "component": "Column", "spacing": 16, "children": ["profileCard1", "profileCard2", "profileCard3"]}, {"id": "profileCard1", "component": "ProfileCard", "name": "Alice Smith", "role": "Senior Developer", "avatarUrl": "https://i.pravatar.cc/150?imgCard3"]}, {"id": "profileCard1", "component": "ProfileCard", "name": "Alice Smith", "role": "Senior Developer", "avatarUrl": "https://i.pravatar.cc/150?img=1", "details": [{"label": "Email", "value": "alice.s@example.com"}, {"label": "Department", "value": "Engineering"}], "actions": [{"label": "Message", "event":=1", "details": [{"label": "Email", "value": "alice.s@example.com"}, {"label": "Department", "value": "Engineering"}], "actions": [{"label": "Message", "event": "message_alice"}, {"label": "View Profile", "event": "view_profile_alice"}]}, {"id": "profileCard2", "component": "ProfileCard", "name": "Bob Johnson", "role": "message_alice"}, {"label": "View Profile", "event": "view_profile_alice"}]}, {"id": "profileCard2", "component": "ProfileCard", "name": "Bob Johnson", "role": "UX Designer", "avatarUrl": "https://i.pravatar.cc/150?img=2", "details": [{"label": "Email", "value": "bob.j@example.com"}, {" "UX Designer", "avatarUrl": "https://i.pravatar.cc/150?img=2", "details": [{"label": "Email", "value": "bob.j@example.com"}, {"label": "Department", "value": "Design"}], "actions": [{"label": "Message", "event": "message_bob"}, {"label": "View Profile", "event": "view_profile_bob"}]}, {"label": "Department", "value": "Design"}], "actions": [{"label": "Message", "event": "message_bob"}, {"label": "View Profile", "event": "view_profile_bob"}]}, {"id": "profileCard3", "component": "ProfileCard", "name": "Carol White", "role": "Project Manager", "avatarUrl": "https://i.pravatar.cc/150?img=id": "profileCard3", "component": "ProfileCard", "name": "Carol White", "role": "Project Manager", "avatarUrl": "https://i.pravatar.cc/150?img=3", "details": [{"label": "Email", "value": "carol.w@example.com"}, {"label": "Department", "value": "Management"}], "actions": [{"label": "Message", "event": "message3", "details": [{"label": "Email", "value": "carol.w@example.com"}, {"label": "Department", "value": "Management"}], "actions": [{"label": "Message", "event": "message_carol"}, {"label": "View Profile", "event": "view_profile_carol"}]}]}}_carol"}, {"label": "View Profile", "event": "view_profile_carol"}]}]}}''';

List<String> extractJsonByVersionPattern(String content) {
  final objects = <String>[];
  final versionPattern = RegExp(r'\{"version":\s*"[^"]*"');
  final matches = versionPattern.allMatches(content);

  for (final match in matches) {
    final startIndex = match.start;
    // Try to extract a complete JSON object starting from this version
    final jsonObject = extractCompleteJsonFromPosition(content, startIndex);
    if (jsonObject != null) {
      // Validate it's a proper A2UI object
      try {
        final decoded = json.decode(jsonObject);
        if (decoded is Map &&
            decoded.containsKey('version') &&
            (decoded.containsKey('createSurface') ||
                decoded.containsKey('updateComponents'))) {
          objects.add(jsonObject);
        }
      } catch (_) {
        // Skip invalid JSON
      }
    }
  }

  return objects;
}

String? extractCompleteJsonFromPosition(String content, int startIndex) {
  int braceCount = 0;
  bool inString = false;
  bool escaped = false;
  int objectStart = -1;

  for (int i = startIndex; i < content.length; i++) {
    final char = content[i];

    if (escaped) {
      escaped = false;
    } else if (char == '\\') {
      escaped = true;
    } else if (char == '"') {
      inString = !inString;
    } else if (!inString) {
      if (char == '{') {
        if (braceCount == 0) objectStart = i;
        braceCount++;
      } else if (char == '}') {
        braceCount--;
        if (braceCount == 0 && objectStart != -1) {
          final candidate = content.substring(objectStart, i + 1);
          // Additional validation: ensure it ends with } and has balanced braces
          if (isValidJsonStructure(candidate)) {
            return candidate;
          }
        }
      }
    }
  }

  return null;
}

bool isValidJsonStructure(String jsonStr) {
  try {
    json.decode(jsonStr);
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  print('Testing JSON extraction from problematic content...');
  final objects = extractJsonByVersionPattern(problematicContent);
  print('Found ${objects.length} valid A2UI objects:');

  for (int i = 0; i < objects.length; i++) {
    print('\n--- Object ${i + 1} ---');
    print(objects[i]);
    try {
      final decoded = json.decode(objects[i]);
      print('✓ Valid JSON with keys: ${decoded.keys.join(', ')}');
    } catch (e) {
      print('✗ Invalid JSON: $e');
    }
  }
}
