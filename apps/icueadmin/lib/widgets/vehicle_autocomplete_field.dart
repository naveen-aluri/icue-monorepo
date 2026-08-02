import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/vehicle.dart';
import '../services/hive_service.dart';
import 'keyboard_visibility_detector.dart';

class VehicleAutocompleteField extends StatelessWidget {
  const VehicleAutocompleteField({
    super.key,
    required this.selectedVehicle,
    required this.onVehicleSelected,
    required this.onVehicleCleared,
  });

  final VoidCallback onVehicleCleared;
  final ValueChanged<Vehicle> onVehicleSelected;
  final Vehicle? selectedVehicle;

  static final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );

  static final _errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.red),
    borderRadius: BorderRadius.circular(5),
  );

  static const _fieldPadding = EdgeInsets.all(10);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Vehicle>>(
      valueListenable: HiveService.vehicleBox.listenable(),
      builder: (context, box, _) {
        final vehicles = box.values.toList();
        return KeyboardVisibilityDetector(
          onVisibilityChange: (visibility) {
            if (!visibility) FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Autocomplete<Vehicle>(
            key: const ValueKey('Enter Vehicle Number'),
            displayStringForOption: (option) => option.number,
            optionsBuilder: (txt) {
              final query = txt.text.toLowerCase();
              return vehicles.where((d) {
                return d.number.toLowerCase().contains(query);
              });
            },
            optionsViewBuilder: (context, onSelected, options) {
              final optionList = options.toList();
              if (optionList.isEmpty) return const SizedBox.shrink();
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 240,
                      minWidth: 200,
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: optionList.length,
                        itemBuilder: (context, index) {
                          final option = optionList[index];
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Text(
                                option.number,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
            fieldViewBuilder: (ctx, ctl, focusNode, onSubmit) {
              return TextFormField(
                controller: ctl,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !vehicles.any(
                        (e) => e.number.toLowerCase() == value.toLowerCase(),
                      )) {
                    return 'Invalid Vehicle Number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  isDense: true,
                  enabledBorder: _border,
                  focusedBorder: _border,
                  errorBorder: _errorBorder,
                  focusedErrorBorder: _errorBorder,
                  contentPadding: _fieldPadding,
                  hintText: 'Enter Vehicle Number',
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                  suffixIcon: (ctl.text.isNotEmpty || selectedVehicle != null)
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            ctl.clear();
                            onVehicleCleared();
                          },
                        )
                      : null,
                ),
                focusNode: focusNode,
                onFieldSubmitted: (String value) {
                  onSubmit();
                  if (value.isEmpty && selectedVehicle != null) {
                    onVehicleCleared();
                  }
                },
              );
            },
            onSelected: (selection) {
              FocusManager.instance.primaryFocus?.unfocus();
              onVehicleSelected(selection);
            },
          ),
        );
      },
    );
  }
}
