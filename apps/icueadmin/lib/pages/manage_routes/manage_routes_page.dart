import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final items = [
  {
    'icon': Icons.alt_route,
    'label': 'Student/Staff Route Change',
    'path': '/layout.routes/student-route-change',
  },
  {
    'icon': Icons.update,
    'label': 'Route Time Change',
    'path': '/layout.routes/route-time-change',
  },
];

class ManageRoutesPage extends StatelessWidget {
  const ManageRoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Routes')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item = items[i];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () => context.go(item['path'] as String),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: primary),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Icon(item['icon'] as IconData, color: primary),
                ),
              ),
              title: Text(
                item['label'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 24,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          );
        },
      ),
    );
  }
}
