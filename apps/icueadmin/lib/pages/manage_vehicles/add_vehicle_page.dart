import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/add_vehicle.dart';
import '../../models/drivers.dart';
import '../../models/vehicle_data.dart';
import '../../providers/driver_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/hive_service.dart';
import '../../utils/app_utils.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/inputfield.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key, this.id});

  final String? id;

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  String? number,
      fuelType,
      companyClaimedMileage,
      actualExpectedMileage,
      ac,
      chassisNumber,
      engineNumber,
      year,
      rta,
      model,
      make,
      capacity,
      color,
      fireExtName,
      dashCamId;

  DateTime? dateOfReg, serviceDate, fireExtInstallDate, fireExtExpiryDate;
  List<FirstAidKit> firstAidKit = [];
  bool loading = true;
  Driver? selectedDriver;

  final TextEditingController _dateOfRegController = TextEditingController();
  final TextEditingController _fireExtExpiryDateController =
      TextEditingController();

  final TextEditingController _fireExtInstallDateController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final List<DateTime> _medicineExpiryDate = [];
  final List<TextEditingController> _medicineExpiryDateController = [];
  final TextEditingController _serviceDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.id == null) {
      firstAidKit.add(FirstAidKit(medicineDetails: ''));
      _medicineExpiryDateController.add(TextEditingController());
      _medicineExpiryDate.add(DateTime.now());
      loading = false;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverProvider>(context, listen: false).getDrivers();
    });
  }

  void setInitialData(VehicleData? vehicle) {
    if (widget.id != null && vehicle != null) {
      if (vehicle.firstAidKit != null) {
        firstAidKit = vehicle.firstAidKit!;
        for (final element in firstAidKit) {
          _medicineExpiryDateController.add(
            TextEditingController(text: element.medicineExpiryDate),
          );
          if (element.medicineExpiryDate != null) {
            _medicineExpiryDate.add(element.medicineExpiryDate!.toDate()!);
          }
        }
      }

      number = vehicle.number;
      fuelType = vehicle.fuelType;
      companyClaimedMileage = '${vehicle.companyClaimedMileage ?? ''}';
      actualExpectedMileage = '${vehicle.actualExpectedMileage ?? ''}';
      ac = vehicle.airCondition;
      chassisNumber = vehicle.chasisNumber;
      engineNumber = vehicle.engineNumber;
      year = vehicle.year;
      rta = vehicle.rtaOfcName;
      model = vehicle.model;
      make = vehicle.make;
      capacity = vehicle.capacity;
      color = vehicle.colour;
      fireExtName = vehicle.fireExtName;
      dashCamId = vehicle.dashcamId;
      dateOfReg = vehicle.dateOfReg?.toDate();
      serviceDate = vehicle.serviceDate?.toDate();
      fireExtInstallDate = vehicle.fireExtInstallDate?.toDate();
      fireExtExpiryDate = vehicle.fireExtExpiryDate?.toDate();
      _dateOfRegController.text = dateOfReg?.formattedGatePassDate() ?? '';
      _serviceDateController.text = serviceDate?.formattedGatePassDate() ?? '';
      _fireExtInstallDateController.text =
          fireExtInstallDate?.formattedGatePassDate() ?? '';
      _fireExtExpiryDateController.text =
          fireExtExpiryDate?.formattedGatePassDate() ?? '';
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> _onSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<VehicleProvider>(context, listen: false);

      final userInfo = HiveService.userInfoBox.values.first;
      final data = AddVehicle(
        organizationId: userInfo.organizationId,
        zoneId: userInfo.zoneId,
        branchId: userInfo.branchId,
        number: number!,
        fuelType: fuelType!,
        companyClaimedMileage: int.tryParse(companyClaimedMileage!) ?? 0,
        actualExpectedMileage: int.tryParse(actualExpectedMileage!) ?? 0,
        airCondition: ac!,
        chasisNumber: chassisNumber!,
        engineNumber: engineNumber,
        year: year!,
        rtaOfcName: rta,
        dateOfReg: dateOfReg?.formattedGatePassDate() ?? '',
        model: model,
        make: make!,
        capacity: capacity!,
        serviceDate: serviceDate?.formattedGatePassDate(),
        colour: color,
        fireExtName: fireExtName,
        fireExtInstallDate: fireExtInstallDate?.formattedGatePassDate(),
        fireExtExpiryDate: fireExtExpiryDate?.formattedGatePassDate() ?? '',
        dashCamId: dashCamId,
        driverId: selectedDriver?.id,
        driverName:
            '${selectedDriver?.firstName} ${selectedDriver?.middleName ?? ''} ${selectedDriver?.lastName ?? ''}',
        driverNumber: selectedDriver?.mobile,
        firstAidKit: firstAidKit,
      );

      if (widget.id != null) {
        data.id = int.parse(widget.id!);
        provider.updateVehicle(context, data);
      } else {
        final isVehicleRegistered = await provider.checkVehicleNumber(number!);

        if (isVehicleRegistered) {
          AppUtils.showErrorMessage(
            context,
            'Vehicle Number already registered',
          );
          return;
        }

        provider.addVehicle(context, data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final vehicles = vehicleProvider.vehiclesData;
    final drivers = driverProvider.drivers;

    if (vehicles.isNotEmpty &&
        selectedDriver == null &&
        drivers.isNotEmpty &&
        widget.id != null) {
      final vehicle = vehicles.firstWhere(
        (element) => element.id == int.parse(widget.id!),
      );
      selectedDriver = drivers.firstWhere(
        (element) => element.id == vehicle.driverId,
      );
      setInitialData(vehicle);
    }

    final widgets = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              text: 'Driver',
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
          SizedBox(
            width: 500,
            child: Autocomplete(
              key: const ValueKey('Driver'),
              initialValue: TextEditingValue(
                text: selectedDriver != null
                    ? '${selectedDriver!.firstName} ${selectedDriver!.middleName} ${selectedDriver!.lastName}'
                    : '',
              ),
              displayStringForOption: (Driver option) =>
                  '${option.firstName} ${option.lastName}',
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<Driver>.empty();
                }
                return driverProvider.drivers.where((Driver option) {
                  return '${option.firstName} ${option.middleName} ${option.lastName}'
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
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
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                        hintText: 'Select Driver',
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
              onSelected: (Driver selection) {
                setState(() {
                  selectedDriver = selection;
                });
              },
            ),
          ),
        ],
      ),
      InputField(
        key: const ValueKey('Vehicle Number'),
        width: 500,
        label: 'Vehicle Number',
        initialValue: number,
        filled: false,
        isRequired: true,
        onSaved: (val) => number = val,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          LengthLimitingTextInputFormatter(10),
        ],
      ),
      Dropdown(
        key: const ValueKey('Fuel Type'),
        width: 500,
        showTitle: true,
        title: 'Fuel Type',
        value: fuelType,
        required: true,
        onChanged: (val) {
          setState(() => fuelType = val);
        },
        items: getDropDownMenuItems(['PETROL', 'DIESEL', 'LPG']),
      ),
      InputField(
        key: const ValueKey('Company Claimed Mileage'),
        width: 500,
        label: 'Company Claimed Mileage (CCM)',
        initialValue: companyClaimedMileage,
        filled: false,
        isRequired: true,
        onSaved: (val) => companyClaimedMileage = val,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
      ),
      InputField(
        key: const ValueKey('Actual Expected Mileage'),
        width: 500,
        label: 'Actual Expected Mileage(AEM)',
        initialValue: actualExpectedMileage,
        filled: false,
        isRequired: true,
        onSaved: (val) => actualExpectedMileage = val,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
      ),
      Dropdown(
        key: const ValueKey('Air Condition'),
        width: 500,
        showTitle: true,
        title: 'Air Condition',
        value: ac,
        required: true,
        onChanged: (val) {
          setState(() => ac = val);
        },
        items: getDropDownMenuItems(['AC', 'NON AC']),
      ),
      InputField(
        key: const ValueKey('Chassis Number'),
        width: 500,
        label: 'Chassis Number',
        initialValue: chassisNumber,
        filled: false,
        isRequired: true,
        onSaved: (val) => chassisNumber = val,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          LengthLimitingTextInputFormatter(17),
        ],
      ),
      InputField(
        key: const ValueKey('Engine Number'),
        width: 500,
        label: 'Engine Number',
        initialValue: engineNumber,
        filled: false,
        onSaved: (val) => engineNumber = val,
      ),
      InputField(
        key: const ValueKey('Manufactured Year'),
        width: 500,
        label: 'Manufactured Year',
        initialValue: year,
        filled: false,
        isRequired: true,
        onSaved: (val) => year = val,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
      ),
      InputField(
        key: const ValueKey('RTA Office Name'),
        width: 500,
        label: 'RTA Office Name',
        initialValue: rta,
        filled: false,
        onSaved: (val) => rta = val,
      ),
      InputField(
        key: const ValueKey('Date of Registration'),
        width: 500,
        label: 'Date of Registration',
        hintText: 'Select Date',
        filled: false,
        isRequired: true,
        initialValue: _dateOfRegController.text,
        controller: _dateOfRegController,
        type: TextFieldType.datePicker,
        onTap: () async {
          dateOfReg = await AppUtils.selectDate(
            context: context,
            initialDate: dateOfReg,
          );
          if (dateOfReg != null) {
            _dateOfRegController.text = dateOfReg.formattedGatePassDate() ?? '';
          }
        },
      ),
      InputField(
        key: const ValueKey('Model'),
        width: 500,
        label: 'Model',
        initialValue: model,
        filled: false,
        onSaved: (val) => model = val,
      ),
      InputField(
        key: const ValueKey('Make'),
        width: 500,
        label: 'Make',
        initialValue: make,
        filled: false,
        isRequired: true,
        onSaved: (val) => make = val,
      ),
      InputField(
        key: const ValueKey('Vehicle capacity'),
        width: 500,
        label: 'Vehicle capacity (Seats)',
        initialValue: capacity,
        filled: false,
        isRequired: true,
        keyboardType: TextInputType.number,
        onSaved: (val) => capacity = val,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
      ),
      InputField(
        key: const ValueKey('Service Due Date'),
        width: 500,
        label: 'Service Due Date',
        hintText: 'Select Date',
        filled: false,
        initialValue: _serviceDateController.text,
        controller: _serviceDateController,
        type: TextFieldType.datePicker,
        onTap: () async {
          serviceDate = await AppUtils.selectDate(
            context: context,
            initialDate: serviceDate,
            allowFutureDates: true,
          );
          if (serviceDate != null) {
            _serviceDateController.text =
                serviceDate.formattedGatePassDate() ?? '';
          }
        },
      ),
      InputField(
        key: const ValueKey('Color'),
        width: 500,
        label: 'Color',
        initialValue: color,
        filled: false,
        onSaved: (val) => color = val,
      ),
      InputField(
        key: const ValueKey('Fire Ext Name'),
        width: 500,
        label: 'Fire Ext Name',
        initialValue: fireExtName,
        filled: false,
        onSaved: (val) => fireExtName = val,
      ),
      InputField(
        key: const ValueKey('Fire Ext Install Date'),
        width: 500,
        label: 'Fire Ext Install Date',
        hintText: 'Select Date',
        filled: false,
        initialValue: _fireExtInstallDateController.text,
        controller: _fireExtInstallDateController,
        type: TextFieldType.datePicker,
        onTap: () async {
          fireExtInstallDate = await AppUtils.selectDate(
            context: context,
            initialDate: fireExtInstallDate,
          );
          if (fireExtInstallDate != null) {
            _fireExtInstallDateController.text =
                fireExtInstallDate.formattedGatePassDate() ?? '';
          }
        },
      ),
      InputField(
        key: const ValueKey('Fire Ext Expiry Date'),
        width: 500,
        label: 'Fire Ext Expiry Date',
        hintText: 'Select Date',
        filled: false,
        initialValue: _fireExtExpiryDateController.text,
        controller: _fireExtExpiryDateController,
        type: TextFieldType.datePicker,
        isRequired: true,
        onTap: () async {
          fireExtExpiryDate = await AppUtils.selectDate(
            context: context,
            initialDate: fireExtExpiryDate,
            allowFutureDates: true,
          );
          if (fireExtExpiryDate != null) {
            _fireExtExpiryDateController.text =
                fireExtExpiryDate.formattedGatePassDate() ?? '';
          }
        },
      ),
      InputField(
        key: const ValueKey('Dash Cam Id'),
        width: 500,
        label: 'Dash Cam Id',
        initialValue: dashCamId,
        filled: false,
        onSaved: (val) => dashCamId = val,
        keyboardType: TextInputType.emailAddress,
      ),
      SizedBox(
        width: 1065,
        child: Column(
          children: [
            const Text(
              'First Aid Kit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            ListView.separated(
              shrinkWrap: true,
              primary: false,
              itemBuilder: (context, index) => Row(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: InputField(
                      key: const ValueKey('Medicine Name'),
                      label: 'Medicine Name',
                      initialValue: firstAidKit[index].medicineDetails,
                      filled: false,
                      onSaved: (val) =>
                          firstAidKit[index].medicineDetails = val,
                    ),
                  ),
                  Expanded(
                    child: InputField(
                      key: const ValueKey('Expiry Date'),
                      label: 'Expiry Date',
                      hintText: 'Select Date',
                      filled: false,
                      initialValue: _medicineExpiryDateController[index].text,
                      controller: _medicineExpiryDateController[index],
                      type: TextFieldType.datePicker,
                      onTap: () async {
                        final date = await AppUtils.selectDate(
                          context: context,
                          firstDate: DateTime.now(),
                          initialDate: _medicineExpiryDate[index],
                          allowFutureDates: true,
                        );
                        if (date != null) {
                          _medicineExpiryDate[index] = date;
                          _medicineExpiryDateController[index].text =
                              date.formattedGatePassDate() ?? '';
                          firstAidKit[index].medicineExpiryDate =
                              date.formattedGatePassDate() ?? '';
                        }
                      },
                    ),
                  ),
                  if (firstAidKit.length - 1 == index)
                    IconButton(
                      key: const ValueKey('Add First Aid Kit'),
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          firstAidKit.add(FirstAidKit(medicineDetails: ''));
                          _medicineExpiryDateController.add(
                            TextEditingController(),
                          );
                          _medicineExpiryDate.add(DateTime.now());
                        });
                      },
                    )
                  else
                    IconButton(
                      key: const ValueKey('Remove First Aid Kit'),
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () {
                        setState(() {
                          firstAidKit.removeAt(index);
                          _medicineExpiryDateController.removeAt(index);
                          _medicineExpiryDate.removeAt(index);
                        });
                      },
                    ),
                ],
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemCount: firstAidKit.length,
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Add Vehicle' : 'Update Vehicle'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Center(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: widgets,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 500,
                      child: ElevatedButton(
                        key: const ValueKey('Submit'),
                        onPressed: _onSubmit,
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
