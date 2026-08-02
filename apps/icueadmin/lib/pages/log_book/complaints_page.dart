import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/hive_service.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/inputfield.dart';
import '../../widgets/no_data_widget.dart';
import 'complaint_details_page.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({
    super.key,
    this.status,
    this.categoryId,
    this.vehicleId,
  });
  final String? status;
  final int? categoryId;
  final int? vehicleId;

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  String? status, action, complaintNo;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Vehicle? selectedVehicle;
  int page = 1, totalPages = 1;
  int? categoryId, vehicleId;

  @override
  void initState() {
    super.initState();
    status = widget.status;
    categoryId = widget.categoryId;
    vehicleId = widget.vehicleId;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<VehicleProvider>(context, listen: false);
      provider.getVehicles();
      provider.getComplaintCategories();
      provider.getComplaints(
        category: widget.categoryId,
        status: widget.status,
        vehicleId: widget.vehicleId,
      );
    });
  }

  void _loadMoreItems() {
    Provider.of<VehicleProvider>(context, listen: false).getComplaints(
      page: ++page,
      status: status,
      vehicleId: vehicleId,
      category: categoryId,
      action: action,
      complaintNo: complaintNo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    final vehicles = HiveService.vehicleBox.values.toList();
    totalPages = provider.metadata != null
        ? ((provider.metadata!.total + provider.metadata!.pagesize - 1) ~/
              provider.metadata!.pagesize)
        : 1;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Complaints'),
        actions: [
          TextButton.icon(
            onPressed: () {
              scaffoldKey.currentState!.openEndDrawer();
            },
            label: const Text(
              'Filter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            icon: const Icon(
              Icons.filter_alt_outlined,
              size: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 50),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'Vehicle Number',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Autocomplete(
                  key: const ValueKey('Enter Vehicle Number'),
                  initialValue: TextEditingValue(
                    text: selectedVehicle != null
                        ? selectedVehicle!.number
                        : '',
                  ),
                  displayStringForOption: (option) => option.number,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<Vehicle>.empty();
                    }
                    return vehicles.where((option) {
                      return option.number.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        return TextFormField(
                          controller: textEditingController,
                          validator: (value) {
                            if (value != null &&
                                !vehicles.any(
                                  (e) =>
                                      e.number.toLowerCase() ==
                                      value.toLowerCase(),
                                )) {
                              return 'Invalid Vehicle Number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            contentPadding: const EdgeInsets.all(10),
                            hintText: 'Enter Vehicle Number',
                            hintStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          focusNode: focusNode,
                          onFieldSubmitted: (String value) {
                            onFieldSubmitted();
                          },
                        );
                      },
                  onSelected: (selection) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      selectedVehicle = selection;
                      vehicleId = selection.id;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            InputField(
              key: const ValueKey('Complaint Number'),
              width: 500,
              label: 'Complaint Number',
              initialValue: complaintNo,
              filled: false,
              onChanged: (val) => setState(() {
                complaintNo = val;
              }),
            ),
            const SizedBox(height: 16),
            Dropdown(
              key: const ValueKey('Category'),
              width: 500,
              showTitle: true,
              title: 'Category',
              value: categoryId,
              onChanged: (val) {
                setState(() => categoryId = val);
              },
              items: getDropDownMenuItems(
                null,
                provider.complaintCategories
                    .map((e) => MenuItem(id: e.id, name: e.name))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Dropdown(
              key: const ValueKey('Action'),
              width: 500,
              showTitle: true,
              title: 'Action',
              value: action,
              onChanged: (val) {
                status = provider.complaintActions
                    .singleWhere((e) => e.action == val)
                    .status;
                setState(() => action = val);
              },
              items: getDropDownMenuItems(
                null,
                provider.complaintActions
                    .map((e) => MenuItem(id: e.action, name: e.action))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Dropdown(
              key: const ValueKey('Status'),
              width: 500,
              showTitle: true,
              title: 'Status',
              value: status,
              onChanged: (val) {
                setState(() => status = val);
              },
              items: getDropDownMenuItems(['Open', 'Closed']),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.getComplaints(
                        vehicleId: selectedVehicle?.id,
                        status: status,
                        action: action,
                        category: categoryId,
                        complaintNo: complaintNo,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedVehicle = null;
                        status = null;
                        complaintNo = null;
                        categoryId = null;
                        action = null;
                      });
                      provider.getComplaints();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ],
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
          : provider.complaints.isEmpty
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
                  if (index < provider.complaints.length) {
                    final complaint = provider.complaints[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  complaint.vehicleNo,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0XFF16A087),
                                  ),
                                ),
                                Text(
                                  '#${complaint.complaintNo}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0XFF16A087),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              complaint.categoryName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Action: ${complaint.currAction}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: complaint.currStatus == 'Open'
                                        ? Colors.orange
                                        : Colors.green,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    'Status: ${complaint.currStatus}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ComplaintDetailsPage(
                                      complaint: complaint,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('View Details'),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (page < totalPages) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const SizedBox();
                  }
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemCount: provider.complaints.length + 1,
              ),
            ),
    );
  }
}
