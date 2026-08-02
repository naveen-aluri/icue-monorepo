import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/complaint_categories.dart';
import '../../models/complaint_data.dart';
import '../../models/vehicle.dart';
import '../../providers/common_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/hive_service.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/file_upload_widget.dart';
import '../../widgets/inputfield.dart';

class AddComplaintPage extends StatefulWidget {
  const AddComplaintPage({super.key, this.complaint});

  final Complaint? complaint;

  @override
  State<AddComplaintPage> createState() => _AddComplaintPageState();
}

class _AddComplaintPageState extends State<AddComplaintPage> {
  List<XFile?> files = [];
  Vehicle? selectedVehicle;
  String? description, action, status, categoryName;
  int? categoryId;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    action = widget.complaint?.currAction;
    status = widget.complaint?.currStatus;
  }

  Future<void> onSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      if (widget.complaint == null) {
        Provider.of<VehicleProvider>(context, listen: false).addComplaint(
          context: context,
          vehicleNumber: selectedVehicle!.number,
          vehicleId: selectedVehicle!.id,
          categoryId: categoryId!,
          categoryName: categoryName!,
          description: description,
          action: action!,
          status: status!,
          files: files.whereType<XFile>().toList(),
        );
      } else {
        Provider.of<VehicleProvider>(context, listen: false).updateComplaint(
          context: context,
          id: widget.complaint!.id,
          description: description,
          action: action!,
          status: status!,
          files: files.whereType<XFile>().toList(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    final commonProvider = Provider.of<CommonProvider>(context);
    final vehicles = HiveService.vehicleBox.values.toList();
    final fileLimit =
        commonProvider.appSettings?.vhCnfg?.complaintImageLimit ?? 1;
    if (files.isEmpty) {
      files = List<XFile?>.filled(fileLimit, null, growable: true);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.complaint == null ? 'Add Complaint' : 'Update Complaint',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 16,
            children: [
              if (widget.complaint == null)
                SizedBox(
                  width: 500,
                  child: Column(
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
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Autocomplete(
                        key: const ValueKey('Vehicle Number'),
                        initialValue: TextEditingValue(
                          text: selectedVehicle != null
                              ? selectedVehicle!.number
                              : '',
                        ),
                        displayStringForOption: (option) => option.number,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          // if (textEditingValue.text == '') {
                          //   return const Iterable<Vehicle>.empty();
                          // }
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
                                  if (value == null || value.isEmpty) {
                                    return 'This is required';
                                  } else if (!vehicles.any(
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
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
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
                          });
                        },
                      ),
                    ],
                  ),
                ),
              if (widget.complaint == null)
                Dropdown(
                  key: const ValueKey('Category'),
                  width: 500,
                  showTitle: true,
                  title: 'Category',
                  required: true,
                  value: categoryId,
                  onChanged: (val) {
                    final cat = provider.complaintCategories.firstWhere(
                      (e) => e.id == val,
                      orElse: () => ComplaintCategory(id: 0, name: 'Others'),
                    );
                    setState(() {
                      categoryId = val;
                      if (val != 0) categoryName = cat.name;
                      if (val == 0) categoryName = null;
                    });
                  },
                  items: getDropDownMenuItems(null, [
                    ...provider.complaintCategories.map(
                      (e) => MenuItem(id: e.id, name: e.name),
                    ),
                    MenuItem(id: 0, name: 'Others'),
                  ]),
                ),
              if (categoryId == 0)
                InputField(
                  key: const ValueKey('Category Name'),
                  width: 500,
                  label: 'Category Name',
                  initialValue: categoryName,
                  filled: false,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This is required';
                    } else if (provider.complaintCategories.any(
                      (e) => e.name.toLowerCase() == value.toLowerCase(),
                    )) {
                      return 'Category already exists';
                    }
                    return null;
                  },
                  onSaved: (val) => categoryName = val,
                ),
              Dropdown(
                key: const ValueKey('Action'),
                width: 500,
                showTitle: true,
                title: 'Action',
                required: true,
                value: action,
                onChanged: (val) {
                  status = provider.complaintActions
                      .singleWhere((e) => e.action == val)
                      .status;
                  setState(() => action = val);
                },
                items: getDropDownMenuItems(
                  null,
                  widget.complaint == null
                      ? provider.complaintActions
                            .where((e) => e.status == 'Open')
                            .map((e) => MenuItem(id: e.action, name: e.action))
                            .toList()
                      : provider.complaintActions
                            .map((e) => MenuItem(id: e.action, name: e.action))
                            .toList(),
                ),
              ),
              InputField(
                key: const ValueKey('Description'),
                width: 500,
                label: 'Description',
                initialValue: description,
                filled: false,
                onSaved: (val) => description = val,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
              for (var i = 0; i < fileLimit; i++)
                FileUploadWidget(
                  title: 'Upload Photo',
                  file: files.length <= i ? null : files[i],
                  onDelete: () {
                    setState(() => files[i] = null);
                  },
                  onFilePick: (xfile, _) {
                    setState(() => files[i] = xfile);
                  },
                ),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: onSubmit, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
