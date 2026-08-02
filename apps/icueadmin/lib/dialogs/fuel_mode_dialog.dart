import 'package:flutter/material.dart';

import '../models/expense_type.dart';
import '../pages/manage_expense/fuel/self_filling_page.dart';
import '../pages/vehicles_list_page.dart';

final iconMap = {
  'FuelStation': Icons.local_gas_station,
  'SelfFilling': Icons.gas_meter,
};

class FuelModeDialog extends StatelessWidget {
  const FuelModeDialog({super.key, required this.expenseType});

  final ExpenseType expenseType;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Select Mode',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      content: SizedBox(
        width: 500,
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final item = expenseType.modes![index];
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.green),
              ),
              dense: true,
              leading: Icon(iconMap[item.code], color: Colors.green),
              title: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.pop(context);
                if (item.code == 'SelfFilling') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelfFillingPage(
                        expenseType: expenseType,
                        mode: item.code,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehiclesListPage(
                        expenseType: expenseType,
                        mode: item.code,
                      ),
                    ),
                  );
                }
              },
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: expenseType.modes!.length,
        ),
      ),
    );
  }
}
