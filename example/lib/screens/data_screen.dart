import 'package:flutter/material.dart';
import 'package:genui_catalog/src/widgets/data/kpi_card.dart';
import 'package:genui_catalog/src/widgets/data/stat_row.dart';
import 'package:genui_catalog/src/widgets/data/chart_card.dart';
import 'package:genui_catalog/src/widgets/data/data_table_widget.dart';
import '../widgets/component_header.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatalogHeader(
                  catalog: 'DataCatalog',
                  subtitle:
                      'Metrics, charts, tables, and stat rows for dashboards and analytics views.',
                  componentCount: 4,
                ),
                SizedBox(height: 32),

                // ── KpiCard ──────────────────────────────────────────────
                ComponentHeader(
                  name: 'KpiCardWidget',
                  description:
                      'Displays a single KPI metric with an optional trend badge and accent color strip.',
                ),
                KpiCardWidget(
                  title: 'Monthly Recurring Revenue',
                  value: r'$84,200',
                  subtitle: r'↗ Up from $71k last month',
                  trend: 'up',
                  trendValue: '+18.6%',
                  accentColor: Color(0xFF4CAF50),
                ),
                SizedBox(height: 32),

                // ── StatRow ──────────────────────────────────────────────
                ComponentHeader(
                  name: 'StatRowWidget',
                  description:
                      '2–4 side-by-side stat cards with icon, value, and label.',
                ),
                StatRowWidget(
                  stats: [
                    {
                      'label': 'Total Users',
                      'value': '24,310',
                      'icon': 'people',
                      'color': '#2196F3',
                    },
                    {
                      'label': 'Churn Rate',
                      'value': '2.1%',
                      'icon': 'trending_down',
                      'color': '#F44336',
                    },
                    {
                      'label': 'Avg Session',
                      'value': '4m 32s',
                      'icon': 'timer',
                      'color': '#FF9800',
                    },
                    {
                      'label': 'NPS Score',
                      'value': '72',
                      'icon': 'thumb_up',
                      'color': '#9C27B0',
                    },
                  ],
                ),
                SizedBox(height: 32),

                // ── ChartCard Bar ────────────────────────────────────────
                ComponentHeader(
                  name: 'ChartCardWidget (bar)',
                  description:
                      'A grouped bar chart comparing multiple datasets over time.',
                ),
                ChartCardWidget(
                  title: 'Revenue vs Expenses',
                  chartType: 'bar',
                  xLabels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                  showLegend: true,
                  datasets: [
                    {
                      'label': 'Revenue',
                      'color': '#5C35CC',
                      'values': [52000, 61000, 58000, 71000, 79000, 84200],
                    },
                    {
                      'label': 'Expenses',
                      'color': '#E91E63',
                      'values': [38000, 42000, 40000, 47000, 52000, 55000],
                    },
                  ],
                ),
                SizedBox(height: 32),

                // ── ChartCard Line ───────────────────────────────────────
                ComponentHeader(
                  name: 'ChartCardWidget (line)',
                  description:
                      'A smooth line chart with area fill for trending data.',
                ),
                ChartCardWidget(
                  title: 'Active Users — Last 6 Months',
                  chartType: 'line',
                  xLabels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                  showLegend: false,
                  datasets: [
                    {
                      'label': 'Active Users',
                      'color': '#5C35CC',
                      'values': [14200, 16800, 18100, 20500, 22300, 24310],
                    },
                  ],
                ),
                SizedBox(height: 32),

                // ── ChartCard Pie ────────────────────────────────────────
                ComponentHeader(
                  name: 'ChartCardWidget (pie)',
                  description:
                      'A donut/pie chart for proportional breakdowns.',
                ),
                ChartCardWidget(
                  title: 'Revenue by Plan',
                  chartType: 'pie',
                  showLegend: true,
                  datasets: [
                    {
                      'label': 'Starter (22%)',
                      'color': '#2196F3',
                      'values': [22],
                    },
                    {
                      'label': 'Pro (45%)',
                      'color': '#5C35CC',
                      'values': [45],
                    },
                    {
                      'label': 'Enterprise (33%)',
                      'color': '#4CAF50',
                      'values': [33],
                    },
                  ],
                ),
                SizedBox(height: 32),

                // ── DataTable ────────────────────────────────────────────
                ComponentHeader(
                  name: 'DataTableWidget',
                  description:
                      'A scrollable, optionally striped table with bold column headers.',
                ),
                DataTableWidget(
                  title: 'Top Customers',
                  striped: true,
                  columns: [
                    {'key': 'company', 'label': 'Company'},
                    {'key': 'plan', 'label': 'Plan'},
                    {'key': 'mrr', 'label': 'MRR'},
                    {'key': 'status', 'label': 'Status'},
                  ],
                  rows: [
                    {
                      'company': 'Acme Corp',
                      'plan': 'Enterprise',
                      'mrr': r'$9,200',
                      'status': 'Active',
                    },
                    {
                      'company': 'Globex Industries',
                      'plan': 'Pro',
                      'mrr': r'$4,800',
                      'status': 'Active',
                    },
                    {
                      'company': 'Initech Solutions',
                      'plan': 'Pro',
                      'mrr': r'$3,600',
                      'status': 'Active',
                    },
                    {
                      'company': 'Umbrella Ltd',
                      'plan': 'Enterprise',
                      'mrr': r'$12,100',
                      'status': 'Active',
                    },
                    {
                      'company': 'Stark Ventures',
                      'plan': 'Starter',
                      'mrr': r'$890',
                      'status': 'Trial',
                    },
                    {
                      'company': 'Wayne Enterprises',
                      'plan': 'Enterprise',
                      'mrr': r'$15,400',
                      'status': 'Active',
                    },
                    {
                      'company': 'Oscorp Digital',
                      'plan': 'Pro',
                      'mrr': r'$2,750',
                      'status': 'At Risk',
                    },
                    {
                      'company': 'Hooli Labs',
                      'plan': 'Starter',
                      'mrr': r'$1,200',
                      'status': 'Active',
                    },
                  ],
                ),
                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
