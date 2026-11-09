import 'package:json_schema_builder/json_schema_builder.dart';

/// The `patternProperties` that declare a string `event` property.
///
/// `a2ui_core` 0.5.0 reads an object schema whose `properties` include
/// `event` as an action, and hands the builder an action callback instead of
/// the object. Components therefore declare `event` with this pattern. A
/// component with an `event` property of its own also sets
/// `additionalProperties: true`, because the catalog accepts only the
/// properties listed in `properties` otherwise.
final Map<String, Schema> eventPatternProperties = {r'^event$': S.string()};
