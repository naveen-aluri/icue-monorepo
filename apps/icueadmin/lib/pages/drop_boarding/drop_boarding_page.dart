import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../models/routes.dart';
import '../../providers/vehicle_provider.dart';
import 'boarding_page.dart';
import 'drop_vehicles_page.dart';

class DropBoardingPage extends StatefulWidget {
  const DropBoardingPage({super.key});

  @override
  State<DropBoardingPage> createState() => _DropBoardingPageState();
}

class _DropBoardingPageState extends State<DropBoardingPage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  Future<void> _fetchInitialData() async {
    final provider = context.read<VehicleProvider>();

    await Future.wait([
      provider.getVehicleArrivals(),
      provider.getRoutesAndPoints(Mode.DROP),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drop Boarding')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DropVehiclesPage(),
                    ),
                  );
                },
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.bus_alert,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                title: Text(
                  'Vehicles',
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
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BoardingPage(),
                    ),
                  );
                },
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.bus_alert,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                title: Text(
                  'Boarding',
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
            ),
          ],
        ),
      ),
    );
  }
}
