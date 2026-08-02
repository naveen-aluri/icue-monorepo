import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../models/expense_type.dart';
import '../../services/analytics_service.dart';
import '../../services/injectable.dart';
import '../manage_expense/fuel/end_filling_page.dart';
import '../vehicles_list_page.dart';

class ExpenseConfirmationPage extends StatelessWidget {
  const ExpenseConfirmationPage({
    super.key,
    required this.expenseType,
    this.mode,
    required this.fuelType,
  });

  final ExpenseType expenseType;
  final String? mode, fuelType;

  @override
  Widget build(BuildContext context) {
    getIt<AnalyticsService>().logScreenView(
      screenName: 'expense-confirmation-page',
      parameters: {
        'expenseType': expenseType.expenseType,
        'mode': mode ?? 'N/A',
        'fuelType': fuelType ?? 'N/A',
      },
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Expense added successfully!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Lottie.asset('assets/animation/success.json'),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehiclesListPage(
                            expenseType: expenseType,
                            mode: mode,
                            fuelType: fuelType,
                          ),
                        ),
                      );
                    },
                    child: const Text('Add Another'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (mode != null && mode == 'SelfFilling') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EndFillingPage(fuelType: fuelType!),
                          ),
                        );
                      } else {
                        context.go('/');
                      }
                    },
                    child: Text(
                      (mode != null && mode == 'SelfFilling')
                          ? 'End Filling'
                          : 'Continue',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
