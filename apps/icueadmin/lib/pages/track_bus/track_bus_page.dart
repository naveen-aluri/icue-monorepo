// ignore_for_file: unnecessary_lambdas

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../config/env.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/hive_service.dart';
import '../../widgets/no_data_widget.dart';

class TrackBusPage extends StatefulWidget {
  const TrackBusPage({super.key});

  @override
  State<TrackBusPage> createState() => _TrackBusPageState();
}

class _TrackBusPageState extends State<TrackBusPage> {
  late io.Socket socket;

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleProvider>(context, listen: false).getStatus();
    });

    final userInfo = HiveService.userInfoBox.values.first;

    final socketObj = {
      'ZoneId': userInfo.zoneId,
      'BranchId': userInfo.branchId,
      'OrganizationId': userInfo.organizationId,
    };

    socket = io.io(Env().config.baseUrl, <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
    });

    socket.connect();

    socket.onConnect((_) {
      socket.emitWithAck('routeStats', socketObj);
    });

    socket.onDisconnect((_) {
      if (kDebugMode) log('Connection Disconnection');
    });
    socket.onConnectError((err) {
      if (kDebugMode) log('Socket connect error: ${err.toString()}');
    });
    socket.onError((err) {
      if (kDebugMode) log('Socket error: ${err.toString()}');
    });
    socket.on('sendRouteStatsEvent', (data) {
      Provider.of<VehicleProvider>(
        context,
        listen: false,
      ).updateSocketData(data['routeStats']);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    final vehicles = [
      ...provider.vehicleSlots?.status.slot1.inprogress ?? [],
      ...provider.vehicleSlots?.status.slot2.inprogress ?? [],
      ...provider.vehicleSlots?.status.slot3.inprogress ?? [],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Bus'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.only(bottom: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.5, color: Colors.grey),
                ),
              ),
              child: const Text(
                'Innovative GPS-enabled system providing real-time monitoring and location tracking for efficient fleet management.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<VehicleProvider>(context, listen: false).getStatus();
        },
        child: const Icon(Icons.refresh),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
          ? const NoDataWidget(
              msg: 'No buses are currently running!',
              image: 'assets/tracking.png',
              size: 300,
            )
          : GridView.builder(
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: vehicles.length,
              itemBuilder: (BuildContext context, int index) {
                final item = vehicles[index];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        provider.getLiveTrackUrl(
                          context,
                          routeDetailsId: item.routeDetailsId,
                          routeNo: item.routeNo,
                          mode: item.mode,
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Image.asset('assets/bus.png', height: 60),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(item.routeNo, style: const TextStyle(fontSize: 13)),
                  ],
                );
              },
            ),
    );
  }
}
