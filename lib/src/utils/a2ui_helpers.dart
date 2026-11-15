import 'dart:async';
import 'dart:developer';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

/// Schemas shared by the catalog components (A2UI v1.0 shapes).
abstract final class CatalogSchemas {
  /// A string the agent gives as a literal or binds to the data model.
  static final Schema text = CommonSchemasV1.dynamicString;

  /// A number the agent gives as a literal or binds to the data model.
  static final Schema number = CommonSchemasV1.dynamicNumber;

  /// A list of strings the agent gives as a literal or binds.
  static final Schema stringList = CommonSchemasV1.dynamicStringList;

  /// A data model path (`{"@path": "/form"}`) the component writes to.
  static final Schema binding = CommonSchemasV1.dataBinding;

  /// An A2UI `Action`. When the agent declares one, it replaces the
  /// component's default catalog event.
  static final Schema action = Schema.fromMap({
    r'$ref': r'common_types.json#/$defs/Action',
  });

  /// The ids of child components.
  static final Schema childList = Schema.fromMap({
    r'$ref': r'common_types.json#/$defs/ChildList',
  });
}

/// Typed readers over [ComponentProps] for the shapes the catalog uses.
extension CatalogProps on ComponentProps {
  /// `key` as an integer, or `null`.
  int? integer(String key) => number(key)?.toInt();

  /// The objects in the list at `key`, as mutable maps.
  List<Map<String, dynamic>> objects(String key) => [
    for (final Object? item in list(key))
      if (item is Map) Map<String, dynamic>.from(item),
  ];

  /// The list at `key` as strings, skipping `null`s.
  List<String> strings(String key) => [
    for (final Object? item in list(key))
      if (item != null) item.toString(),
  ];

  /// Writes [value] to the data path `key` is bound to. Does nothing when
  /// `key` is a literal or absent.
  void writeBack(String key, Object? value) {
    try {
      writable(key)?.set(value);
    } on A2uiDataError catch (error) {
      log('${error.code}: ${error.message}', name: 'genui_catalog');
    }
  }
}

/// Sends a catalog event from [node]: the action the agent declared under
/// [actionKey] when there is one, otherwise the event [name] with
/// [context] (the event names in `CatalogEvents`).
///
/// Call it synchronously from a gesture handler: A2UI runs actions as user
/// activations.
void dispatchCatalogEvent(
  ComponentNode<ComponentImplementation> node,
  ComponentProps props,
  String name, {
  Map<String, Object?> context = const {},
  String? actionKey = 'action',
}) {
  final NodeAction? declared = actionKey == null
      ? null
      : props.action(actionKey);
  if (declared != null) {
    unawaited(declared());
    return;
  }
  final ComponentContext? componentContext = node.context;
  if (componentContext == null || name.isEmpty) return;
  unawaited(
    componentContext.dispatchAction({
      'event': {'name': name, if (context.isNotEmpty) 'context': context},
    }),
  );
}
