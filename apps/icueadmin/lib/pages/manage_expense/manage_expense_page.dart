import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../dialogs/fuel_mode_dialog.dart';
import '../../providers/expense_provider.dart';
import '../../services/hive_service.dart';
import '../vehicles_list_page.dart';

class ManageExpensePage extends StatefulWidget {
  const ManageExpensePage({super.key});

  @override
  State<ManageExpensePage> createState() => _ManageExpensePageState();
}

class _ManageExpensePageState extends State<ManageExpensePage> {
  final iconMap = {
    'fuel': Icons.local_gas_station,
    'tyres': Icons.attractions,
    'maintenance': Icons.engineering,
    'salary': Icons.payment,
    'battery': Icons.battery_charging_full,
  };

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).getExpenseTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Expense')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: HiveService.expenseTypesBox.listenable(),
              builder: (context, box, _) {
                final items = box.values.toList();
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return item.code == 'loosefuel'
                        ? const SizedBox()
                        : ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.green),
                            ),
                            dense: true,
                            leading: Icon(
                              iconMap[item.code],
                              color: Colors.green,
                            ),
                            title: Text(
                              item.expenseTypeDesc,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              switch (item.code) {
                                case 'fuel':
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        FuelModeDialog(expenseType: item),
                                  );
                                  break;
                                case 'tyres':
                                case 'maintenance':
                                case 'salary':
                                case 'battery':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VehiclesListPage(
                                        expenseType: item,
                                        fuelType: '',
                                        mode: '',
                                      ),
                                    ),
                                  );
                                  break;
                                default:
                              }
                            },
                          );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemCount: items.length,
                );
              },
            ),
    );
  }
}
