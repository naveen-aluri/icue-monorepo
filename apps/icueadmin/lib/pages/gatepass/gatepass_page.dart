import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/hive_service.dart';

class GatePassPage extends StatefulWidget {
  const GatePassPage({super.key});

  @override
  State<GatePassPage> createState() => _GatePassPageState();
}

const mapper = {
  'layout.generategatepass': {'icon': 'assets/gatepass1.png'},
  'layout.approvegatepass': {'icon': 'assets/gatepass2.png'},
};

class _GatePassPageState extends State<GatePassPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFAFAFA),
      appBar: AppBar(title: const Text('Gate Pass')),
      body: ValueListenableBuilder(
        valueListenable: HiveService.getActionsByRoleBox.listenable(),
        builder: (context, box, _) {
          final items =
              box.values
                  .singleWhere((e) => e.routeState == 'layout.gatepass')
                  .subActionItems ??
              [];
          return ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            primary: false,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: EdgeInsets.zero,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0XFF12967E), width: 2),
                ),
                child: ListTile(
                  leading: Image.asset(
                    mapper[item.routeState]?['icon'] ?? 'assets/logo.png',
                    height: 35,
                  ),
                  title: Text(
                    item.displayName,
                    style: const TextStyle(
                      color: Color(0XFF12967E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0XFF12967E),
                  ),
                  onTap: () {
                    context.go('/layout.gatepass/${item.routeState}');
                  },
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
