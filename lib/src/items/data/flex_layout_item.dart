import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_builder/json_schema_builder.dart'
    hide ValidationResult;

import '../../utils/a2ui_helpers.dart';

Schema _flexSchema() => Schema.object(
  properties: {
    'children': CatalogSchemas.childList,
    'spacing': Schema.number(),
    'mainAxisAlignment': Schema.string(),
    'crossAxisAlignment': Schema.string(),
  },
  required: ['children'],
);

List<Widget> _children(ComponentProps props, ChildWidgetBuilder buildChild) => [
  for (final child in props.children('children'))
    KeyedSubtree(key: NodeKey(child.instanceId), child: buildChild(child)),
];

final columnItem = ComponentImplementation(
  name: 'Column',
  schema: _flexSchema(),
  builder: (_, _, props, buildChild) {
    final children = _children(props, buildChild);
    final double spacing = props.number('spacing') ?? 0;

    return Column(
      crossAxisAlignment: _crossAlignmentFromString(
        props.string('crossAxisAlignment'),
      ),
      mainAxisAlignment: _alignmentFromString(
        props.string('mainAxisAlignment'),
        Axis.vertical,
      ),
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0 && spacing > 0) SizedBox(height: spacing),
          children[i],
        ],
      ],
    );
  },
);

final rowItem = ComponentImplementation(
  name: 'Row',
  schema: _flexSchema(),
  builder: (_, _, props, buildChild) {
    final children = _children(props, buildChild);
    final double spacing = props.number('spacing') ?? 0;
    final mainAxisAlignment = _alignmentFromString(
      props.string('mainAxisAlignment'),
      Axis.horizontal,
    );
    final crossAxisAlignment = _crossAlignmentFromString(
      props.string('crossAxisAlignment'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth.isFinite) {
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
