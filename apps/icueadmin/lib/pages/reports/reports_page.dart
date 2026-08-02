import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/hive_service.dart';
import '../../widgets/cache_image.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items =
        HiveService.getActionsByRoleBox.values
            .toList()
            .singleWhere((e) => e.routeState == 'layout.reports')
            .subActionItems ??
        [];

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () => context.go('/layout.reports/${item.routeState}'),
              leading: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: CacheImage(url: item.icon, size: 56),
                ),
              ),
              title: Text(
                item.displayName,
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
        separatorBuilder: (context, index) => const SizedBox(height: 0),
        itemCount: items.length,
      ),
    );
  }
}
