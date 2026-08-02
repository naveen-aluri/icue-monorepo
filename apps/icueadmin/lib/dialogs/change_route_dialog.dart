import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../models/routes.dart';
import '../models/student.dart';
import '../providers/vehicle_provider.dart';
import '../utils/app_utils.dart';
import '../widgets/no_data_widget.dart';

class ChangeRouteDialog extends StatefulWidget {
  const ChangeRouteDialog({
    super.key,
    required this.mode,
    required this.student,
    this.both = false,
  });

  final bool both;
  final Mode mode;
  final StudentData student;

  @override
  State<ChangeRouteDialog> createState() => _ChangeRouteDialogState();
}

class _ChangeRouteDialogState extends State<ChangeRouteDialog> {
  List<Point> dropPoints = [];
  int? selectedPickupRoute,
      existingPickupRouteId,
      selectedDropRoute,
      existingDropRouteId;

  String? selectedPickupPoint, selectedDropPoint, existingPickupPoint;
  List<Point> pickupPoints = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleProvider>(
        context,
        listen: false,
      ).getRoutesAndPoints(widget.both ? null : widget.mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    final routes = provider.routes;
    if (routes.isNotEmpty && (widget.both || routes[0].mode == widget.mode)) {
      final routesData = AppUtils.mapModesToRoutes({
        'mode': widget.student.mode,
        'routes': widget.student.routes,
        'routeIds': widget.student.routeIds,
      });
      final hasPickupPoints = routes
          .where((e) => e.mode == Mode.PICKUP)
          .isNotEmpty;
      final hasDropPoints = routes.where((e) => e.mode == Mode.DROP).isNotEmpty;

      final both = hasPickupPoints && hasDropPoints;

      if ((both || hasPickupPoints) &&
          selectedPickupRoute == null &&
          selectedPickupPoint == null) {
        selectedPickupRoute = int.tryParse(
          '${routesData[Mode.PICKUP]?['routeId']}',
        );
        existingPickupRouteId = selectedPickupRoute;
        selectedPickupPoint = widget.student.pickPoint;
        existingPickupPoint = selectedPickupPoint;
        try {
          pickupPoints = existingPickupRouteId == null
              ? []
              : routes
                    .firstWhere((e) => e.id == existingPickupRouteId)
                    .points
                    .toList();
        } catch (e) {
          if (kDebugMode) log('pickupPoints Error => $e');
        }

        if (!pickupPoints.any((e) => e.name == selectedPickupPoint)) {
          selectedPickupPoint = null;
        }
      }

      if ((both || hasDropPoints) &&
          selectedDropRoute == null &&
          selectedDropPoint == null) {
        selectedDropRoute = int.tryParse(
          '${routesData[Mode.DROP]?['routeId']}',
        );
        existingDropRouteId = selectedDropRoute;
        selectedDropPoint = widget.student.dropPoint;
        try {
          dropPoints = existingDropRouteId == null
              ? []
              : routes
                    .firstWhere((e) => e.id == existingDropRouteId)
                    .points
                    .toList();
        } catch (e) {
          if (kDebugMode) log('dropPoints Error => $e');
        }
        if (!dropPoints.any((e) => e.name == selectedDropPoint)) {
          selectedDropPoint = null;
        }
      }
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: SizedBox(
        width: 500,
        child: provider.loading
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : routes.isEmpty
            ? const NoDataWidget()
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...(widget.both || widget.mode == Mode.PICKUP
                        ? [
                            const Text(
                              'Change Pick up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SelectRoutePoint(
                              selectedRoute: selectedPickupRoute,
                              selectedPoint: selectedPickupPoint,
                              routes: routes
                                  .where((e) => e.mode == Mode.PICKUP)
                                  .toList(),
                              points: pickupPoints,
                              onRouteChanged: (newValue) {
                                setState(() {
                                  pickupPoints = routes
                                      .where((e) => e.mode == Mode.PICKUP)
                                      .toList()
                                      .firstWhere((e) => e.id == newValue)
                                      .points
                                      .toList();
                                  selectedPickupPoint = null;
                                  selectedPickupRoute = newValue;
                                });
                              },
                              onPointChanged: (newValue) {
                                setState(() {
                                  selectedPickupPoint = newValue;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                          ]
                        : []),
                    ...(widget.both || widget.mode == Mode.DROP
                        ? [
                            const Text(
                              'Change Drop',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SelectRoutePoint(
                              selectedRoute: selectedDropRoute,
                              selectedPoint: selectedDropPoint,
                              routes: routes
                                  .where((e) => e.mode == Mode.DROP)
                                  .toList(),
                              points: dropPoints,
                              onRouteChanged: (newValue) {
                                setState(() {
                                  dropPoints = routes
                                      .where((e) => e.mode == Mode.DROP)
                                      .toList()
                                      .firstWhere((e) => e.id == newValue)
                                      .points
                                      .toList();
                                  selectedDropPoint = null;
                                  selectedDropRoute = newValue;
                                });
                              },
                              onPointChanged: (newValue) {
                                setState(() {
                                  selectedDropPoint = newValue;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                          ]
                        : []),
                  ],
                ),
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
            minimumSize: const Size(100, 40),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              if (widget.both) {
                final result = await provider.changeBothRoutes(
                  context,
                  existingPickupRouteId: existingPickupRouteId,
                  existingDropRouteId: existingDropRouteId,
                  existingPickupPoint: existingPickupPoint,
                  studentId: widget.student.id,
                  classId: widget.student.classId,
                  sections: [widget.student.section],
                  pickupRoute: selectedPickupRoute!,
                  pickupPoint: selectedPickupPoint!,
                  dropRoute: selectedDropRoute!,
                  dropPoint: selectedDropPoint!,
                );
                if (result) {
                  Navigator.pop(context);
                }
              } else {
                final existingRouteId = widget.mode == Mode.PICKUP
                    ? existingPickupRouteId
                    : existingDropRouteId;
                final selectedRoute = widget.mode == Mode.PICKUP
                    ? selectedPickupRoute
                    : selectedDropRoute;
                final selectedPoint = widget.mode == Mode.PICKUP
                    ? selectedPickupPoint
                    : selectedDropPoint;

                // if (existingRouteId == null) {
                //   AppUtils.showErrorMessage(
                //     context,
                //     'There is no existing route!',
                //   );
                //   return;
                // }

                final result = await provider.changeRoute(
                  context,
                  mode: widget.mode,
                  existingRouteId: existingRouteId,
                  studentId: widget.student.id,
                  route: selectedRoute,
                  point: selectedPoint,
                  classId: widget.student.classId,
                  sections: [widget.student.section],
                );
                if (result) {
                  Navigator.pop(context);
                }
              }
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class SelectRoutePoint extends StatelessWidget {
  const SelectRoutePoint({
    super.key,
    this.selectedRoute,
    this.selectedPoint,
    required this.routes,
    this.onRouteChanged,
    this.onPointChanged,
    required this.points,
  });

  final void Function(int?)? onRouteChanged;
  final void Function(String?)? onPointChanged;
  final List<Point> points;
  final List<Routee> routes;
  final String? selectedPoint;
  final int? selectedRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField(
          hint: const Text(
            'Route',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          ),
          initialValue: selectedRoute,
          validator: (value) => value == null ? 'Please select Route' : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            isDense: true,
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0XFF2D7FBB), width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0XFF2D7FBB), width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0XFF2D7FBB), width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onChanged: onRouteChanged,
          items: routes.map((data) {
            return DropdownMenuItem(value: data.id, child: Text(data.routeNo));
          }).toList(),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField(
          validator: (value) => value == null ? 'Please select Point' : null,
          hint: const Text(
            'Point',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          ),
          initialValue: selectedPoint,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            isDense: true,
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0XFF2D7FBB), width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0XFF2D7FBB), width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0XFF2D7FBB), width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onChanged: onPointChanged,
          items: points.map((data) {
            return DropdownMenuItem(value: data.name, child: Text(data.name));
          }).toList(),
        ),
      ],
    );
  }
}
