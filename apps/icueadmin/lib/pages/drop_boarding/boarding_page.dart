import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../config/env.dart';
import '../../models/vehicle_arrivals.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/hive_service.dart';

class _SocketConstants {
  static const String connectEvent = 'routeStats';
  static const String eventName = 'vehicleArrivalStatus';
  static const String listenEvent = 'vehicleArrivalStatus';

  static String roomName(int branchId) => 'vehicleArrivalStatus-$branchId';
}

class BoardingPage extends StatefulWidget {
  const BoardingPage({super.key});

  @override
  State<BoardingPage> createState() => _BoardingPageState();
}

class _BoardingPageState extends State<BoardingPage> {
  final Set<int> _selectedRouteIds = {};
  late final io.Socket _socket;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().getVehicleArrivals();
    });
    _initSocket();
  }

  void _initSocket() {
    final userInfo = HiveService.userInfoBox.values.first;
    final branchId = userInfo.branchId;

    final socketRoom = {
      'roomName': _SocketConstants.roomName(branchId),
      'eventName': _SocketConstants.eventName,
    };

    _socket = io.io(Env().config.baseUrl, <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
    });

    _socket.onConnect((_) {
      _socket.emitWithAck(_SocketConstants.connectEvent, socketRoom);
    });
    _socket.on(_SocketConstants.listenEvent, (data) {
      if (mounted) {
        if (data is List) {
          final vehicles = vehicleArrivalFromJson(jsonEncode(data));
          context.read<VehicleProvider>().updateArrivalsList(vehicles);
        }
      }
    });
    _socket.onDisconnect((_) {
      if (kDebugMode) log('Socket disconnected.');
    });
    _socket.onConnectError((err) {
      if (kDebugMode) log('Socket connect error: $err');
    });
    _socket.onError((err) {
      if (kDebugMode) log('Socket error: $err');
    });

    _socket.connect();
  }

  Future<void> _handleSubmit() async {
    if (_selectedRouteIds.isEmpty) return;

    final provider = context.read<VehicleProvider>();

    final result = await provider.updateVehicleArrivalStatus(
      context,
      _selectedRouteIds.toList(),
      'LEFT',
      null,
    );

    if (mounted && result) {
      setState(() {
        _selectedRouteIds.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Boarding')),
        bottomNavigationBar: ElevatedButton.icon(
          onPressed: _selectedRouteIds.isEmpty ? null : _handleSubmit,
          icon: const Icon(Icons.exit_to_app),
          label: Text('Mark as Left (${_selectedRouteIds.length})'),
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        body: Consumer<VehicleProvider>(
          builder: (context, provider, child) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final vehicles = provider.vehicleArrivals
                .where((e) => e.status == 'ARRIVED')
                .toList();
            if (vehicles.isEmpty) {
              return const Center(child: Text('No vehicles found.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final route = vehicles[index];
                final isSelected = _selectedRouteIds.contains(route.id);
                return _RouteCard(
                  route: route,
                  isSelected: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedRouteIds.add(route.id);
                      } else {
                        _selectedRouteIds.remove(route.id);
                      }
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.isSelected,
    required this.onChanged,
  });

  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  final VehicleArrival route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 2 : 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.primaryColor : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: onChanged,
        title: Row(
          spacing: 12,
          children: [
            Icon(Icons.directions_bus, color: theme.primaryColor, size: 34),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                Text(
                  route.routeNo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (route.boardingType != null)
                  Text(
                    route.boardingType ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
        activeColor: theme.primaryColor,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
