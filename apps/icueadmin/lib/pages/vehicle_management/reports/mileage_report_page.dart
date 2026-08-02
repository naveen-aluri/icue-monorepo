import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../../models/vehicle.dart';
import '../../../providers/reports_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/injectable.dart';
import '../../../utils/constants.dart';
import '../../../widgets/no_data_widget.dart';

class MileageReportPage extends StatefulWidget {
  const MileageReportPage({super.key, required this.vehicle});
  final Vehicle vehicle;

  @override
  State<MileageReportPage> createState() => _MileageReportPageState();
}

class _MileageReportPageState extends State<MileageReportPage> {
  String? month = months[DateTime.now().month - 1]['val'],
      year = DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'mileage-report-page',
      parameters: {'vehicleNumber': widget.vehicle.number},
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsProvider>(context, listen: false).clearData();
      Provider.of<ReportsProvider>(context, listen: false).getMileageReport(
        vehicleNumber: widget.vehicle.number,
        month: month!,
        year: year!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReportsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.vehicle.number} - Mileage Report',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    hint: const Text(
                      'Month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    initialValue: month,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        month = newValue;
                      });
                      if (year != null) {
                        provider.getMileageReport(
                          vehicleNumber: widget.vehicle.number,
                          month: month!,
                          year: year!,
                        );
                      }
                    },
                    items: months.map<DropdownMenuItem<String>>((data) {
                      return DropdownMenuItem<String>(
                        value: data['val'],
                        child: Text(data['name']!),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField(
                    hint: const Text(
                      'Year',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    initialValue: year,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        year = newValue;
                      });
                      if (month != null) {
                        provider.getMileageReport(
                          vehicleNumber: widget.vehicle.number,
                          month: month!,
                          year: year!,
                        );
                      }
                    },
                    items: generateYears().map((data) {
                      return DropdownMenuItem(
                        value: data.toString(),
                        child: Text(data.toString()),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: provider.mileageReports.isEmpty
                  ? const NoDataWidget(msg: 'No Records Found!')
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Route',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Total KMS',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'KM Readings',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Speedometer Diff',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: [
                            for (final data in provider.mileageReports)
                              DataRow(
                                cells: [
                                  DataCell(Text(data.routeNo)),
                                  DataCell(
                                    Text('${data.actualTotalKmsDriven}'),
                                  ),
                                  DataCell(
                                    Text('${data.totalNoOfKmReadingsTaken}'),
                                  ),
                                  DataCell(Text(data.speedometerdiff)),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
    );
  }
}
