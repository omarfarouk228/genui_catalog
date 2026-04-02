import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/color_utils.dart';

class ChartCardWidget extends StatelessWidget {
  final String title;
  final String chartType;
  final List<Map<String, dynamic>> datasets;
  final List<String>? xLabels;
  final bool showLegend;

  const ChartCardWidget({
    super.key,
    required this.title,
    required this.chartType,
    required this.datasets,
    this.xLabels,
    this.showLegend = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: _buildChart(context),
            ),
            if (showLegend && datasets.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildLegend(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    switch (chartType) {
      case 'line':
        return _buildLineChart(context);
      case 'bar':
        return _buildBarChart(context);
      case 'pie':
        return _buildPieChart(context);
      default:
        return Center(
          child: Text('Unknown chart type: $chartType'),
        );
    }
  }

  List<double> _getValues(Map<String, dynamic> dataset) {
    final rawValues = dataset['values'];
    if (rawValues is List) {
      return rawValues.map((v) => (v as num).toDouble()).toList();
    }
    return [];
  }

  Color _getDatasetColor(Map<String, dynamic> dataset, int index) {
    final colorStr = dataset['color'] as String?;
    if (colorStr != null && colorStr.isNotEmpty) {
      return parseHexColor(colorStr);
    }
    const defaultColors = [
      Color(0xFF2196F3),
      Color(0xFFE91E63),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFF00BCD4),
    ];
    return defaultColors[index % defaultColors.length];
  }

  Widget _buildLineChart(BuildContext context) {
    final lineBars = <LineChartBarData>[];

    for (var i = 0; i < datasets.length; i++) {
      final ds = datasets[i];
      final values = _getValues(ds);
      final color = _getDatasetColor(ds, i);

      final spots = List.generate(
        values.length,
        (j) => FlSpot(j.toDouble(), values[j]),
      );

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.08),
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        lineBarsData: lineBars,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (xLabels != null && idx >= 0 && idx < xLabels!.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      xLabels![idx],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    int maxLength = 0;
    for (final ds in datasets) {
      final len = _getValues(ds).length;
      if (len > maxLength) maxLength = len;
    }

    final groups = <BarChartGroupData>[];
    for (var j = 0; j < maxLength; j++) {
      final rods = <BarChartRodData>[];
      for (var i = 0; i < datasets.length; i++) {
        final ds = datasets[i];
        final values = _getValues(ds);
        final val = j < values.length ? values[j] : 0.0;
        rods.add(
          BarChartRodData(
            toY: val,
            color: _getDatasetColor(ds, i),
            width: datasets.length > 1 ? 8 : 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        );
      }
      groups.add(BarChartGroupData(x: j, barRods: rods));
    }

    return BarChart(
      BarChartData(
        barGroups: groups,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (xLabels != null && idx >= 0 && idx < xLabels!.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      xLabels![idx],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: true),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final sections = <PieChartSectionData>[];
    double total = 0;

    for (final ds in datasets) {
      final values = _getValues(ds);
      if (values.isNotEmpty) {
        total += values.first;
      }
    }

    for (var i = 0; i < datasets.length; i++) {
      final ds = datasets[i];
      final values = _getValues(ds);
      final val = values.isNotEmpty ? values.first : 0.0;
      final color = _getDatasetColor(ds, i);
      final pct = total > 0 ? (val / total * 100).toStringAsFixed(1) : '0';

      sections.add(
        PieChartSectionData(
          value: val,
          color: color,
          title: '$pct%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        pieTouchData: PieTouchData(enabled: true),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(datasets.length, (i) {
        final ds = datasets[i];
        final label = ds['label'] as String? ?? 'Series ${i + 1}';
        final color = _getDatasetColor(ds, i);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        );
      }),
    );
  }
}
