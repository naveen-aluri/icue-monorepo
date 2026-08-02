import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/vehicle_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/hive_service.dart';
import '../../services/injectable.dart';

class VehicleDetailsPage extends StatefulWidget {
  const VehicleDetailsPage({super.key, required this.vehicleNumber});

  final String vehicleNumber;

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  Widget info(String title, String? value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0XFF16A087),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value ?? '-',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0XFF1F1D31),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'vehicle-details-page',
      parameters: {'vehicleNumber': widget.vehicleNumber},
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleProvider>(
        context,
        listen: false,
      ).getVehicleDetails(widget.vehicleNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Details')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: HiveService.vehicleDetailsBox.listenable(),
              builder: (context, box, _) {
                final item = box.get(widget.vehicleNumber);
                return item == null
                    ? const SizedBox()
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text(
                            item.number,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          // info('Vehicle Number:', item.number),
                          // const SizedBox(height: 10),
                          info('Make:', item.make),
                          const SizedBox(height: 10),
                          info('Model:', item.model),
                          const SizedBox(height: 10),
                          info('Colour:', item.colour ?? ''),
                          const SizedBox(height: 10),
                          info('Year:', item.year),
                          const SizedBox(height: 10),
                          info('Chassis Number:', item.chasisNumber),
                          const SizedBox(height: 30),
                          const Text(
                            'Driver Details:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          info('Driver Name:', item.driverName),
                          const SizedBox(height: 10),
                          info('Driver Number:', '${item.driverNumber}'),
                          const SizedBox(height: 30),
                          const Text(
                            'Insurance Details:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          info('Insurance Number:', item.insuranceNumber),
                          const SizedBox(height: 10),
                          info('Insured Date:', item.insuredDate),
                          const SizedBox(height: 10),
                          info(
                            'Insurance Expiry Date:',
                            item.insuranceExpiryDate,
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Other Details:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          info('RC Expiry Date:', item.rcExpiryDate),
                          const SizedBox(height: 10),
                          info('Service Date:', item.serviceDate ?? '-'),
                          const SizedBox(height: 10),
                          info('Capacity:', '${item.capacity}'),
                          const SizedBox(height: 10),
                          info('Status:', item.status),
                        ],
                      );
              },
            ),
    );
  }
}
