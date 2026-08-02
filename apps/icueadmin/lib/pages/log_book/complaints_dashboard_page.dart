import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/complaints_dashboard.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/no_data_widget.dart';

class ComplaintsDashboardPage extends StatefulWidget {
  const ComplaintsDashboardPage({super.key});

  @override
  State<ComplaintsDashboardPage> createState() =>
      _ComplaintsDashboardPageState();
}

class _ComplaintsDashboardPageState extends State<ComplaintsDashboardPage> {
  String status = 'Status';
  int page = 1, totalPages = 1;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleProvider>(context, listen: false).getVehicles();
      Provider.of<VehicleProvider>(
        context,
        listen: false,
      ).getComplaintCategories();
      Provider.of<VehicleProvider>(
        context,
        listen: false,
      ).getComplaintsStats(countBy: status, page: page);
    });
  }

  void _loadMoreItems() {
    Provider.of<VehicleProvider>(
      context,
      listen: false,
    ).getComplaintsStats(page: ++page, countBy: status);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    totalPages = provider.metadata != null
        ? ((provider.metadata!.total + provider.metadata!.pagesize - 1) ~/
              provider.metadata!.pagesize)
        : 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints Dashboard'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Dropdown(
              width: 500,
              title: 'Count By',
              value: status,
              filled: true,
              onChanged: (val) {
                status = val!;
                page = 1;
                Provider.of<VehicleProvider>(
                  context,
                  listen: false,
                ).getComplaintsStats(countBy: val, page: page);
              },
              items: getDropDownMenuItems(['Status', 'Category', 'Vehicle']),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/layout.logbook/layout.complaints/add-complaint');
        },
        child: const Icon(Icons.add),
      ),
      body: provider.complainsLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.complaintsDashboard.isEmpty
          ? const NoDataWidget()
          : NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter == 0 &&
                    page < totalPages) {
                  _loadMoreItems();
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  if (index < provider.complaintsDashboard.length) {
                    final item = provider.complaintsDashboard[index];
                    return ExpansionTile(
                      childrenPadding: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.green),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.green),
                      ),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.status ?? item.category ?? item.vehicle ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            item.totalCount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0XFF16A087),
                            ),
                          ),
                        ],
                      ),
                      children: <Widget>[
                        for (Status stat in item.statuses ?? [])
                          ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  stat.status,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  stat.count.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0XFF16A087),
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              context.push(
                                '/layout.logbook/layout.complaints',
                                extra: {
                                  'status': stat.status,
                                  'categoryId': item.categoryId,
                                  'vehicleId': item.vehicleId,
                                },
                              );
                            },
                          ),
                        if (status == 'Status')
                          OutlinedButton(
                            onPressed: () {
                              context.push(
                                '/layout.logbook/layout.complaints',
                                extra: {'status': item.status},
                              );
                            },
                            child: const Text('Details'),
                          ),
                      ],
                    );
                  } else if (page < totalPages) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const SizedBox();
                  }
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemCount: provider.complaintsDashboard.length + 1,
              ),
            ),
    );
  }
}
