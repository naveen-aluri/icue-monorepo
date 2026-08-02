import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../config/env.dart';
import '../../models/vehicle_slots.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/hive_service.dart';

class FleetStatusPage extends StatefulWidget {
  const FleetStatusPage({super.key});

  @override
  State<FleetStatusPage> createState() => _FleetStatusPageState();
}

class _FleetStatusPageState extends State<FleetStatusPage> {
  io.Socket? socket;

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().getStatus();
    });

    final userInfo = HiveService.userInfoBox.values.first;

    final socketObj = {
      'ZoneId': userInfo.zoneId,
      'BranchId': userInfo.branchId,
      'OrganizationId': userInfo.organizationId,
    };

    socket = io.io('${Env().config.baseUrl}:3002', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket
      ?..connect()
      ..onConnect((_) {
        if (kDebugMode) log('Socket connected');
        socket?.emitWithAck('routeStats', socketObj);
      })
      ..onDisconnect((_) {
        if (kDebugMode) log('Socket disconnected');
      })
      ..onConnectError((err) {
        if (kDebugMode) log('Connect error: $err');
      })
      ..onError((err) {
        if (kDebugMode) log('Error: $err');
      })
      ..on('sendRouteStatsEvent', (data) {
        context.read<VehicleProvider>().updateSocketData(data['routeStats']);
      });
  }

  Widget _statusHeader() {
    return const Row(
      spacing: 10,
      children: [
        Expanded(child: SizedBox()),
        Expanded(
          child: Text(
            'Not Started',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0XFFE94C3D),
            ),
          ),
        ),
        Expanded(
          child: Text(
            'In Progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0XFFFFA500),
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Completed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0XFF1DBA9B),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = HiveService.userInfoBox.values.first;
    final zonalBranch = HiveService.zonalBranch.get('selected');
    final provider = context.watch<VehicleProvider>();
    final activeSlot = provider.vehicleSlots?.activeSlot;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fleet Status - ${zonalBranch?.schoolName ?? userInfo.schoolShortName}',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.5, color: Colors.grey),
              ),
            ),
            child: const Text(
              'Optimal operational capacity achieved, with all vehicles and assets fully functional and ready for deployment.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<VehicleProvider>().getStatus(),
        child: const Icon(Icons.refresh),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _statusHeader(),
                  const SizedBox(height: 10),
                  StatusItem(
                    title: 'Morning',
                    isActive: activeSlot == 'Slot1',
                    notStarted:
                        provider.vehicleSlots?.status.slot1.notStarted ?? [],
                    inProgress:
                        provider.vehicleSlots?.status.slot1.inprogress ?? [],
                    completed:
                        provider.vehicleSlots?.status.slot1.completed ?? [],
                  ),
                  StatusItem(
                    title: 'Afternoon',
                    isActive: activeSlot == 'Slot2',
                    notStarted:
                        provider.vehicleSlots?.status.slot2.notStarted ?? [],
                    inProgress:
                        provider.vehicleSlots?.status.slot2.inprogress ?? [],
                    completed:
                        provider.vehicleSlots?.status.slot2.completed ?? [],
                  ),
                  StatusItem(
                    title: 'Evening',
                    isActive: activeSlot == 'Slot3',
                    notStarted:
                        provider.vehicleSlots?.status.slot3.notStarted ?? [],
                    inProgress:
                        provider.vehicleSlots?.status.slot3.inprogress ?? [],
                    completed:
                        provider.vehicleSlots?.status.slot3.completed ?? [],
                  ),
                ],
              ),
            ),
    );
  }
}

class StatusItem extends StatelessWidget {
  const StatusItem({
    super.key,
    required this.title,
    required this.notStarted,
    required this.inProgress,
    required this.completed,
    required this.isActive,
  });

  final List<VehicleDetails> notStarted, inProgress, completed;
  final bool isActive;
  final String title;

  void _showVehicleDetails(
    BuildContext context,
    String time,
    List<VehicleDetails> vehicles,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: [
            Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Grabber(),
                  Padding(
                    padding: const EdgeInsets.all(16).copyWith(top: 0),
                    child: Text(
                      '$title Vehicles (${vehicles.length})  - $time',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: vehicles.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final vehicle = vehicles[index];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.2),
                      foregroundColor: Theme.of(context).colorScheme.error,
                      child: const Icon(Icons.directions_bus),
                    ),
                    title: Text(
                      vehicle.routeNo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(vehicle.vehicleNumber),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String label,
    List<VehicleDetails> list,
    Color color,
    Color border,
  ) {
    final bool disabled = list.isEmpty || !isActive;
    return Expanded(
      child: GestureDetector(
        onTap: list.isEmpty
            ? null
            : () => _showVehicleDetails(context, label, list),
        child: SizedBox(
          height: 50,
          child: Card(
            elevation: 0,
            color: disabled
                ? Colors.grey.shade200
                : color.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
              side: BorderSide(color: disabled ? Colors.grey.shade200 : border),
            ),
            child: Center(
              child: Text(
                '${list.length}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: disabled ? Colors.grey : border,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          _buildCard(
            context,
            'Not Started',
            notStarted,
            const Color(0XFFE94C3D),
            const Color(0XFFC33B2D),
          ),
          _buildCard(
            context,
            'In Progress',
            inProgress,
            const Color(0XFFFFA500),
            const Color(0XFF5F5F5F),
          ),
          _buildCard(
            context,
            'Completed',
            completed,
            const Color(0XFF16A087),
            const Color(0XFF28AF62),
          ),
        ],
      ),
    );
  }
}

/// A purely visual widget that indicates a draggable area.
class Grabber extends StatelessWidget {
  const Grabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Align(
        child: Container(
          width: 40.0,
          height: 5.0,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
