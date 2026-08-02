import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../../models/overspeed_report.dart';
import '../../../models/vehicle.dart';
import '../../../providers/reports_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/injectable.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/constants.dart';
import '../../../widgets/no_data_widget.dart';

class OverSpeedReportPage extends StatefulWidget {
  const OverSpeedReportPage({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  State<OverSpeedReportPage> createState() => _OverSpeedReportPageState();
}

final speedLimits = ['51-60', '61-70', '71-80', '81-100', '100+'];

class _OverSpeedReportPageState extends State<OverSpeedReportPage> {
  String? month = months[DateTime.now().month - 1]['val'],
      year = DateTime.now().year.toString(),
      speedLimit = '51-60';

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'over-speed-report-page',
      parameters: {'vehicleNumber': widget.vehicle.number},
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsProvider>(context, listen: false).clearData();
      Provider.of<ReportsProvider>(context, listen: false).getOverSpeedReport(
        vehicleNumber: widget.vehicle.number,
        month: month!,
        year: year!,
        speedLimit: speedLimit!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReportsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vehicle.number} - Over Speed Report'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                Row(
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
                          if (year != null && speedLimit != null) {
                            provider.getOverSpeedReport(
                              vehicleNumber: widget.vehicle.number,
                              month: month!,
                              year: year!,
                              speedLimit: speedLimit!,
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
                          if (month != null && speedLimit != null) {
                            provider.getOverSpeedReport(
                              vehicleNumber: widget.vehicle.number,
                              month: month!,
                              year: year!,
                              speedLimit: speedLimit!,
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
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  hint: const Text(
                    'Speed Limit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                  initialValue: speedLimit,
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
                      speedLimit = newValue;
                    });
                    if (month != null && year != null) {
                      provider.getOverSpeedReport(
                        vehicleNumber: widget.vehicle.number,
                        month: month!,
                        year: year!,
                        speedLimit: speedLimit!,
                      );
                    }
                  },
                  items: speedLimits.map((data) {
                    return DropdownMenuItem(value: data, child: Text(data));
                  }).toList(),
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
              child: provider.overSpeedList.isEmpty
                  ? const NoDataWidget(msg: 'No Records Found!')
                  : SingleChildScrollView(
                      child: PaginatedDataTable(
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Date Time',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Route',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Speed',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          // DataColumn(
                          //   label: Text(
                          //     'Avg Speed',
                          //     style: TextStyle(fontWeight: FontWeight.bold),
                          //   ),
                          // ),
                          DataColumn(
                            label: Text(
                              'Mode',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        source: _DataSource(data: provider.overSpeedList),
                      ),
                    ),
            ),
    );
  }
}

class _DataSource extends DataTableSource {
  _DataSource({required this.data});

  final List<OverSpeed> data;

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }

    final item = data[index];

    return DataRow(
      cells: [
        DataCell(Text(item.gpsTime.formattedDateTime())),
        DataCell(Text(item.routeNo)),
        DataCell(Text('${item.speed}')),
        // DataCell(Text('${item.averageSpeed}')),
        DataCell(Text(item.mode)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
