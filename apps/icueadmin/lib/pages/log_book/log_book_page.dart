import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/role_actions.dart';
import '../../services/hive_service.dart';
import '../../widgets/cache_image.dart';

class LogBookPage extends StatefulWidget {
  const LogBookPage({super.key});

  @override
  State<LogBookPage> createState() => _LogBookPageState();
}

class _LogBookPageState extends State<LogBookPage> {
  List<RoleActions> _logBookItems = [];

  @override
  void initState() {
    super.initState();
    _loadLogBookItems();
  }

  void _loadLogBookItems() {
    try {
      final logBookAction = HiveService.getActionsByRoleBox.values
          .firstWhereOrNull((e) => e.routeState == 'layout.logbook');
      _logBookItems = logBookAction?.subActionItems ?? [];
    } catch (e) {
      debugPrint('Error loading logbook items: $e');
      _logBookItems = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Book')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _logBookItems.length,
        itemBuilder: (context, index) {
          final item = _logBookItems[index];

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () => context.go('/layout.logbook/${item.routeState}'),
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
      ),
    );
  }
}
