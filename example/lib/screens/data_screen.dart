import 'package:flutter/material.dart';
import 'package:genui_catalog_example/models/preset.dart';
import '../widgets/catalog_demo_screen.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CatalogDemoScreen(
      catalogName: 'DataCatalog',
      subtitle:
          'KPI metrics, charts, tables, stat rows, lists, and empty states — for data-rich dashboards.',
      componentCount: 6,
      accentColor: const Color(0xFF2196F3),
      icon: Icons.bar_chart_rounded,
      presets: const [
        Preset(
          label: 'Revenue Dashboard',
          icon: Icons.trending_up,
          prompt:
              'Generate a revenue dashboard with 3 KPI cards (Monthly Revenue '
              '\$142k +18%, Active Subscriptions 3 821 +5%, Churn Rate 2.1% -0.4%), '
              'a StatRow with 4 operational metrics, and a line ChartCard showing '
              'monthly revenue vs target for the last 6 months.',
        ),
        Preset(
          label: 'Sales Analytics',
          icon: Icons.insert_chart_outlined,
          prompt:
              'Show a sales analytics view with a bar ChartCard for weekly '
              'sales by region (North, South, East, West) over 4 weeks, and a '
              'DataTable listing the top 5 products by revenue with columns: '
              'Product, Category, Units Sold, Revenue, Growth.',
        ),
        Preset(
          label: 'E-commerce KPIs',
          icon: Icons.shopping_cart_outlined,
          prompt:
              'Create an e-commerce KPI dashboard: 4 KpiCards for Total Orders '
              '(12 480, up +22%), Avg Order Value (\$89, neutral), Cart Abandonment '
              '(34%, down -3%), and Return Rate (4.2%, down -0.8%). Also add a '
              'pie ChartCard showing traffic sources: Organic 45%, Paid 28%, '
              'Direct 15%, Social 12%.',
        ),
        Preset(
          label: 'User Analytics',
          icon: Icons.people_outline,
          prompt:
              'Display a user analytics report with a StatRow for DAU 8 420, '
              'MAU 62 100, Avg Session 4m 32s, and NPS 71. Include a line '
              'ChartCard for daily active users over the last 30 days (two '
              'datasets: Mobile and Web). Add a DataTable of top 5 countries '
              'by users with columns: Country, Users, Sessions, Conversion.',
        ),
        Preset(
          label: 'Quick Actions List',
          icon: Icons.list_alt_outlined,
          prompt:
              'Show a ListCard titled "Account" with 4 rows: '
              '"Edit profile" (icon: edit, event: edit_profile), '
              '"Notification settings" (icon: notifications, event: open_notifications), '
              '"Download data" (icon: download, event: download_data), '
              'and "Delete account" (icon: delete, destructive: true, event: delete_account). '
              'Enable dividers.',
        ),
        Preset(
          label: 'Empty State',
          icon: Icons.inbox_outlined,
          prompt:
              'Show an EmptyState for an empty inbox: '
              'icon "inbox", title "Your inbox is empty", '
              'description "Messages from your team will appear here.", '
              'actionLabel "Invite teammates", actionEvent "invite_team".',
        ),
      ],
    );
  }
}
