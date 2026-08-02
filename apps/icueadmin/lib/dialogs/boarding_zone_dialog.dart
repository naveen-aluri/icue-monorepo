import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/vehicle_provider.dart';

class BoardingZoneDialog extends StatefulWidget {
  const BoardingZoneDialog({super.key});

  @override
  State<BoardingZoneDialog> createState() => _BoardingZoneDialogState();
}

class _BoardingZoneDialogState extends State<BoardingZoneDialog> {
  String? selectedZone;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text('Select Boarding Zone'),
      content: SizedBox(
        width: 500,
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          shrinkWrap: true,
          itemCount: provider.boardingTypes.length,
          itemBuilder: (context, index) {
            final item = provider.boardingTypes[index];
            final selected = item.name == selectedZone;
            return ListTile(
              title: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: selected ? Colors.green : Colors.grey,
                  width: 2,
                ),
              ),
              dense: true,
              selected: selected,
              onTap: () {
                setState(() {
                  selectedZone = item.name;
                });
              },
            );
          },
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
          onPressed: selectedZone == null
              ? null
              : () {
                  Navigator.of(context, rootNavigator: true).pop(selectedZone);
                },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
