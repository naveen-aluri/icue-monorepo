import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/routes.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/inputfield.dart';

class PointsDialog extends StatefulWidget {
  const PointsDialog({
    super.key,
    required this.points,
    required this.selectedPoints,
  });
  final List<Point> points;
  final List<String> selectedPoints;

  @override
  State<PointsDialog> createState() => _PointsDialogState();
}

class _PointsDialogState extends State<PointsDialog> {
  List<Point> filterPoints = [];
  List<String> selectedPoints = [];
  List<int> studentIds = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedPoints = widget.selectedPoints;
    filterPoints = widget.points;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);

    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: CheckboxListTile(
        title: const Text('Select Points'),
        value: selectedPoints.length == widget.points.length,
        onChanged: (val) {
          setState(() {
            if (val == false) {
              selectedPoints = [];
            } else {
              selectedPoints = widget.points.map((e) => e.name).toList();
            }
          });
        },
      ),
      content: SizedBox(
        width: 500,
        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  InputField(
                    initialValue: '',
                    label: 'Search Points',
                    showTitle: false,
                    hintText: 'Search Points...',
                    controller: _searchController,
                    onChanged: (value) {
                      filterPoints = widget.points
                          .where(
                            (e) => e.name.toLowerCase().contains(
                              value.toLowerCase(),
                            ),
                          )
                          .toList();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filterPoints.length,
                      itemBuilder: (context, index) {
                        final name = filterPoints[index].name;
                        final selected = selectedPoints.contains(name);
                        return CheckboxListTile(
                          title: Text(
                            name,
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: selected,
                          onChanged: (val) {
                            setState(() {
                              if (selected) {
                                selectedPoints.remove(name);
                              } else {
                                selectedPoints.add(name);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        OverflowBar(
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(100, 40),
              ),
              onPressed: () {
                studentIds.clear();
                for (final e in widget.points) {
                  if (selectedPoints.contains(e.name)) {
                    studentIds.addAll(e.studentIds);
                  }
                }
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pop([selectedPoints, studentIds]);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ],
    );
  }
}
