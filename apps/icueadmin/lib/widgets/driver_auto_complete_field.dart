import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/drivers.dart';
import '../providers/driver_provider.dart';
import 'keyboard_visibility_detector.dart';

class DriverAutoCompleteField extends StatelessWidget {
  const DriverAutoCompleteField({
    super.key,
    required this.selectedDriver,
    required this.onDriverSelected,
    required this.onDriverCleared,
    required this.fullName,
  });

  final String Function(Driver) fullName;
  final VoidCallback onDriverCleared;
  final ValueChanged<Driver> onDriverSelected;
  final Driver? selectedDriver;

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
    return Consumer<DriverProvider>(
      builder: (context, driverProvider, child) {
        if (driverProvider.loading) {
          return const SizedBox.shrink();
        }
        return KeyboardVisibilityDetector(
          onVisibilityChange: (visibility) {
            if (!visibility) FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Autocomplete<Driver>(
            displayStringForOption: fullName,
            initialValue: TextEditingValue(
              text: selectedDriver != null ? fullName(selectedDriver!) : '',
            ),
            optionsBuilder: (txt) {
              final query = txt.text.toLowerCase();
              return driverProvider.drivers.where((d) {
                return fullName(d).toLowerCase().contains(query);
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
                                fullName(option),
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
                focusNode: focusNode,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'This is required';
                  }
                  if (!driverProvider.drivers.any(
                    (d) => fullName(d).toLowerCase() == val.toLowerCase(),
                  )) {
                    return 'Invalid Driver';
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
                  hintText: 'Select Driver',
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                  suffixIcon: ctl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            ctl.clear();
                            onDriverCleared();
                          },
                        )
                      : null,
                ),
                onFieldSubmitted: (val) {
                  onSubmit();
                  if (val.isEmpty && selectedDriver != null) {
                    onDriverCleared();
                  }
                },
              );
            },
            onSelected: (drv) {
              FocusManager.instance.primaryFocus?.unfocus();
              onDriverSelected(drv);
            },
          ),
        );
      },
    );
  }
}
