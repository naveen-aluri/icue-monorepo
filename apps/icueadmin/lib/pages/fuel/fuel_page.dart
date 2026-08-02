import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/expense_provider.dart';
import '../../services/hive_service.dart';
import '../manage_expense/fuel/self_filling_page.dart';
import '../vehicles_list_page.dart';

class FuelPage extends StatefulWidget {
  const FuelPage({super.key});

  @override
  State<FuelPage> createState() => _FuelPageState();
}

final iconMap = {
  'FuelStation': Icons.local_gas_station,
  'SelfFilling': Icons.gas_meter,
};

class _FuelPageState extends State<FuelPage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).getExpenseTypes();
      Provider.of<ExpenseProvider>(context, listen: false).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Fuel Filling')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: HiveService.expenseTypesBox.listenable(),
              builder: (context, box, _) {
                final items = box.values.toList();
                final fuelIndex = items.indexWhere((e) => e.code == 'fuel');
                final fuelExpense = fuelIndex == -1 ? null : items[fuelIndex];
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final item = fuelExpense?.modes?[index];
                    return item == null
                        ? const SizedBox()
                        : Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              onTap: () {
                                if (item.code == 'SelfFilling') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SelfFillingPage(
                                        expenseType: fuelExpense!,
                                        mode: item.code,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VehiclesListPage(
                                        expenseType: fuelExpense,
                                        mode: item.code,
                                      ),
                                    ),
                                  );
                                }
                              },
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Icon(
                                    iconMap[item.code],
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.name,
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemCount: (fuelExpense?.modes ?? []).length,
                );
              },
            ),
    );
  }
}
