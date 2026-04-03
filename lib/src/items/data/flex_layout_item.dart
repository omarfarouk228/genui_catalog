import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final columnItem = CatalogItem(
  name: 'Column',
  dataSchema: S.object(
    properties: {
      'children': S.list(items: S.string()),
      'spacing': S.number(),
      'mainAxisAlignment': S.string(),
      'crossAxisAlignment': S.string(),
    },
    required: ['children'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final rawChildren = data['children'] as List<dynamic>? ?? [];
    final children = rawChildren.whereType<String>().map((id) {
      try {
        return itemContext.buildChild(id);
      } catch (_) {
        return const SizedBox.shrink();
      }
    }).toList();

    final double spacing = (data['spacing'] as num?)?.toDouble() ?? 0;
    final mainAxisAlignment = _alignmentFromString(
      data['mainAxisAlignment'] as String?,
      Axis.vertical,
    );
    final crossAxisAlignment = _crossAlignmentFromString(
      data['crossAxisAlignment'] as String?,
    );

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children:
          spacing <= 0
                ? children
                : children
                      .expand((child) => [child, SizedBox(height: spacing)])
                      .toList()
            ..removeLast(),
    );
  },
);

final rowItem = CatalogItem(
  name: 'Row',
  dataSchema: S.object(
    properties: {
      'children': S.list(items: S.string()),
      'spacing': S.number(),
      'mainAxisAlignment': S.string(),
      'crossAxisAlignment': S.string(),
    },
    required: ['children'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    final rawChildren = data['children'] as List<dynamic>? ?? [];
    final children = rawChildren.whereType<String>().map((id) {
      try {
        return itemContext.buildChild(id);
      } catch (_) {
        return const SizedBox.shrink();
      }
    }).toList();

    final double spacing = (data['spacing'] as num?)?.toDouble() ?? 0;
    final mainAxisAlignment = _alignmentFromString(
      data['mainAxisAlignment'] as String?,
      Axis.horizontal,
    );
    final crossAxisAlignment = _crossAlignmentFromString(
      data['crossAxisAlignment'] as String?,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final useWrap = constraints.maxWidth.isFinite;

        if (useWrap) {
          return Wrap(
            direction: Axis.horizontal,
            spacing: spacing,
            runSpacing: spacing,
            alignment: _wrapAlignmentFromMainAxis(mainAxisAlignment),
            crossAxisAlignment: _wrapCrossAxisFromCrossAxis(crossAxisAlignment),
            children: children,
          );
        }

        return Row(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    );
  },
);

MainAxisAlignment _alignmentFromString(String? value, Axis axis) {
  switch (value) {
    case 'start':
      return MainAxisAlignment.start;
    case 'end':
      return MainAxisAlignment.end;
    case 'center':
      return MainAxisAlignment.center;
    case 'spaceBetween':
    case 'space_between':
      return MainAxisAlignment.spaceBetween;
    case 'spaceAround':
    case 'space_around':
      return MainAxisAlignment.spaceAround;
    case 'spaceEvenly':
    case 'space_evenly':
      return MainAxisAlignment.spaceEvenly;
    default:
      return MainAxisAlignment.start;
  }
}

CrossAxisAlignment _crossAlignmentFromString(String? value) {
  switch (value) {
    case 'start':
      return CrossAxisAlignment.start;
    case 'end':
      return CrossAxisAlignment.end;
    case 'center':
      return CrossAxisAlignment.center;
    case 'stretch':
      return CrossAxisAlignment.stretch;
    case 'baseline':
      return CrossAxisAlignment.baseline;
    default:
      return CrossAxisAlignment.start;
  }
}

WrapAlignment _wrapAlignmentFromMainAxis(MainAxisAlignment mainAxis) {
  switch (mainAxis) {
    case MainAxisAlignment.start:
      return WrapAlignment.start;
    case MainAxisAlignment.end:
      return WrapAlignment.end;
    case MainAxisAlignment.center:
      return WrapAlignment.center;
    case MainAxisAlignment.spaceBetween:
      return WrapAlignment.spaceBetween;
    case MainAxisAlignment.spaceAround:
      return WrapAlignment.spaceAround;
    case MainAxisAlignment.spaceEvenly:
      return WrapAlignment.spaceEvenly;
  }
}

WrapCrossAlignment _wrapCrossAxisFromCrossAxis(CrossAxisAlignment crossAxis) {
  switch (crossAxis) {
    case CrossAxisAlignment.start:
      return WrapCrossAlignment.start;
    case CrossAxisAlignment.end:
      return WrapCrossAlignment.end;
    case CrossAxisAlignment.center:
      return WrapCrossAlignment.center;
    case CrossAxisAlignment.stretch:
      return WrapCrossAlignment.start;
    case CrossAxisAlignment.baseline:
      return WrapCrossAlignment.start;
  }
}
