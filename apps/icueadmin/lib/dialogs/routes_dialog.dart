import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../models/routes.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/inputfield.dart';

class RoutesDialog extends StatefulWidget {
  const RoutesDialog({
    super.key,
    required this.selectedRoutes,
    required this.mode,
  });

  final Mode mode;
  final List<int> selectedRoutes;

  @override
  State<RoutesDialog> createState() => _RoutesDialogState();
}

class _RoutesDialogState extends State<RoutesDialog> {
  List<int> filterRoutes = [];
  List<int> selectedRoutes = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedRoutes = widget.selectedRoutes;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleProvider>(
        context,
        listen: false,
      ).getRoutesAndPoints(widget.mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    final routes = provider.routes;
    if (filterRoutes.isEmpty) {
      filterRoutes = routes.map((e) => e.id).toList();
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: routes.isEmpty
          ? const SizedBox()
          : CheckboxListTile(
              title: const Text('Select Routes'),
              value: selectedRoutes.length == routes.length,
              onChanged: (val) {
                setState(() {
                  if (val == false) {
                    selectedRoutes = [];
                  } else {
                    selectedRoutes = routes.map((e) => e.id).toList();
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
                    showTitle: false,
                    controller: _searchController,
                    onChanged: (value) {
                      filterRoutes = routes
                          .where(
                            (e) => e.routeNo.toLowerCase().contains(
                              value.toLowerCase(),
                            ),
                          )
                          .toList()
                          .map((e) => e.id)
                          .toList();
                      setState(() {});
                    },
                    label: '',
                    filled: false,
                    hintText: 'Search Routes...',
                    // decoration: InputDecoration(
                    //   border: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(5),
                    //   ),
                    //   isDense: true,
                    //   hintText: 'Search Routes',
                    //   hintStyle: const TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.w300,
                    //   ),
                    // ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filterRoutes.length,
                      itemBuilder: (context, index) {
                        final id = filterRoutes[index];
                        final selected = selectedRoutes.contains(id);
                        final routeName = routes
                            .firstWhereOrNull((e) => e.id == id)
                            ?.routeNo;

                        return routeName == null
                            ? const SizedBox()
                            : CheckboxListTile(
                                title: Text(routeName),
                                value: selected,
                                onChanged: (val) {
                                  setState(() {
                                    if (selected) {
                                      selectedRoutes.remove(id);
                                    } else {
                                      selectedRoutes.add(filterRoutes[index]);
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
            minimumSize: const Size(150, 40),
          ),
          onPressed: () {
            final selectedRouteNames = [];
            for (final e in routes) {
              if (selectedRoutes.contains(e.id)) {
                selectedRouteNames.add(e.routeNo);
              }
            }
            Navigator.of(
              context,
              rootNavigator: true,
            ).pop([selectedRoutes, selectedRouteNames]);
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}
