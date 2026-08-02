import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/drivers.dart';
import '../../providers/common_provider.dart';
import '../../providers/driver_provider.dart';
import '../../services/hive_service.dart';
import '../../utils/app_utils.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/inputfield.dart';

class AddDriverPage extends StatefulWidget {
  const AddDriverPage({super.key, this.driver});

  final Driver? driver;

  @override
  State<AddDriverPage> createState() => _AddDriverPageState();
}

class _AddDriverPageState extends State<AddDriverPage> {
  DateTime? dob, doj, licenceIssueDate, licenceExpiryDate;
  String? firstName,
      middleName,
      lastName,
      aadhar,
      experience,
      licenceNumber,
      email,
      mobile,
      alternateMobile,
      addressLine1,
      addressLine2,
      city,
      state,
      country,
      pincode;

  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _dojController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _licenceExpiryDateController =
      TextEditingController();

  final TextEditingController _licenceIssueDateController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.driver != null) {
      final driver = widget.driver!;
      firstName = driver.firstName;
      middleName = driver.middleName;
      lastName = driver.lastName;
      dob = driver.dateOfBirth?.toDate();
      doj = driver.dateOfJoining?.toDate();
      aadhar = driver.idType;
      experience = '${driver.drivingExperience ?? ''}';
      licenceNumber = driver.licenceNumber;
      licenceIssueDate = driver.licenceIssuedDate?.toDate();
      licenceExpiryDate = driver.licenceExpiryDate?.toDate();
      email = driver.email;
      mobile = driver.mobile.toString();
      alternateMobile = '${driver.alternateNumber ?? ''}';
      addressLine1 = driver.address.line1;
      addressLine2 = driver.address.line2;
      city = driver.city;
      state = driver.state;
      country = driver.country;
      pincode = '${driver.pincode}';

      _dobController.text = driver.dateOfBirth ?? '';
      _dojController.text = driver.dateOfJoining ?? '';
      _licenceIssueDateController.text = driver.licenceIssuedDate ?? '';
      _licenceExpiryDateController.text = driver.licenceExpiryDate ?? '';
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommonProvider>(context, listen: false).getCountries();
    });
  }

  void _onSubmit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final userInfo = HiveService.userInfoBox.values.first;
      final data = AddDriver(
        zoneId: userInfo.zoneId,
        organizationId: userInfo.organizationId,
        branchId: userInfo.branchId,
        id: widget.driver?.id,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        dateOfBirth: dob?.formattedGatePassDate(),
        dateOfJoining: doj?.formattedGatePassDate(),
        idType: aadhar,
        drivingExperience: experience,
        licenceNumber: licenceNumber,
        licenceIssuedDate: licenceIssueDate?.formattedGatePassDate(),
        licenceExpiryDate: licenceExpiryDate?.formattedGatePassDate(),
        email: email,
        mobile: int.parse(mobile!),
        alternateNumber: alternateMobile,
        address: Address(line1: addressLine1!, line2: addressLine2),
        city: city,
        state: state,
        country: country,
        pincode: pincode,
      );
      if (widget.driver == null) {
        Provider.of<DriverProvider>(
          context,
          listen: false,
        ).addDriver(context, data);
      } else {
        Provider.of<DriverProvider>(
          context,
          listen: false,
        ).updateDriver(context, data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commonProvider = Provider.of<CommonProvider>(context);
    final countries = commonProvider.countries;
    final places = commonProvider.places;
    final widgets = [
      InputField(
        key: const ValueKey('First Name'),
        width: 500,
        label: 'First Name',
        initialValue: firstName,
        filled: false,
        isRequired: true,
        onSaved: (val) => firstName = val,
      ),
      InputField(
        key: const ValueKey('Middle Name'),
        width: 500,
        label: 'Middle Name',
        initialValue: middleName,
        filled: false,
        onSaved: (val) => middleName = val,
      ),
      InputField(
        key: const ValueKey('Last Name'),
        width: 500,
        label: 'Last Name',
        initialValue: lastName,
        filled: false,
        onSaved: (val) => lastName = val,
      ),
      InputField(
        key: const ValueKey('Date of Birth'),
        width: 500,
        label: 'Date of Birth',
        hintText: 'Select Date',
        filled: false,
        initialValue: _dobController.text,
        controller: _dobController,
        type: TextFieldType.datePicker,
        onTap: () async {
          dob = await AppUtils.selectDate(context: context, initialDate: dob);
          if (dob != null) {
            _dobController.text = dob.formattedGatePassDate() ?? '';
          }
        },
      ),
      InputField(
        key: const ValueKey('Date of Joining'),
        width: 500,
        label: 'Date of Joining',
        hintText: 'Select Date',
        filled: false,
        initialValue: _dojController.text,
        controller: _dojController,
        type: TextFieldType.datePicker,
        onTap: () async {
          doj = await AppUtils.selectDate(context: context, initialDate: doj);
          if (doj != null) {
            _dojController.text = doj.formattedGatePassDate() ?? '';
          }
        },
      ),
      InputField(
        key: const ValueKey('Aadhar Number'),
        width: 500,
        label: 'Aadhar Number',
        initialValue: aadhar,
        filled: false,
        onSaved: (val) => aadhar = val,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(12),
        ],
      ),
      InputField(
        key: const ValueKey('Driving Experience'),
        width: 500,
        label: 'Driving Experience (In Years)',
        initialValue: experience,
        filled: false,
        onSaved: (val) => experience = val,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
      ),
      InputField(
        key: const ValueKey('Licence Number'),
        width: 500,
        label: 'Licence Number',
        initialValue: licenceNumber,
        filled: false,
        onSaved: (val) => licenceNumber = val,
        inputFormatters: [
          // FilteringTextInputFormatter.allow(
          //   RegExp(r'^[A-Z]{2}[0-9]{2}[0-9]{11}$'),
          // ),
          LengthLimitingTextInputFormatter(20),
        ],
      ),
      InputField(
        key: const ValueKey('Licence Issue Date'),
        width: 500,
        label: 'Licence Issue Date',
        hintText: 'Select Date',
        filled: false,
        initialValue: _licenceIssueDateController.text,
        controller: _licenceIssueDateController,
        type: TextFieldType.datePicker,
        onTap: () async {
          licenceIssueDate = await AppUtils.selectDate(
            context: context,
            initialDate: licenceIssueDate,
          );
          if (licenceIssueDate != null) {
            _licenceIssueDateController.text =
                licenceIssueDate.formattedGatePassDate() ?? '';
          }
        },
      ),
      InputField(
        key: const ValueKey('Licence Expiry Date'),
        width: 500,
        label: 'Licence Expiry Date',
        hintText: 'Select Date',
        filled: false,
        initialValue: _licenceExpiryDateController.text,
        controller: _licenceExpiryDateController,
        type: TextFieldType.datePicker,
        onTap: () async {
          licenceExpiryDate = await AppUtils.selectDate(
            context: context,
            initialDate: licenceExpiryDate,
            allowFutureDates: true,
          );
          if (licenceExpiryDate != null) {
            _licenceExpiryDateController.text =
                licenceExpiryDate.formattedGatePassDate() ?? '';
          }
        },
      ),
      InputField(
        key: const ValueKey('Email'),
        width: 500,
        label: 'Email',
        initialValue: email,
        filled: false,
        onSaved: (val) => email = val,
        keyboardType: TextInputType.emailAddress,
      ),
      InputField(
        key: const ValueKey('Mobile Number'),
        width: 500,
        label: 'Mobile Number',
        initialValue: mobile,
        filled: false,
        isRequired: true,
        onSaved: (val) => mobile = val,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
      ),
      InputField(
        key: const ValueKey('Alternate Mobile Number'),
        width: 500,
        label: 'Alternate Mobile Number',
        initialValue: alternateMobile,
        filled: false,
        onSaved: (val) => alternateMobile = val,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
      ),
      InputField(
        key: const ValueKey('Address Line 1'),
        width: 500,
        label: 'Address Line 1',
        initialValue: addressLine1,
        filled: false,
        isRequired: true,
        onSaved: (val) => addressLine1 = val,
        keyboardType: TextInputType.streetAddress,
      ),
      InputField(
        key: const ValueKey('Address Line 2'),
        width: 500,
        label: 'Address Line 2',
        initialValue: addressLine2,
        filled: false,
        onSaved: (val) => addressLine2 = val,
        keyboardType: TextInputType.streetAddress,
      ),
      InputField(
        key: const ValueKey('City'),
        width: 500,
        label: 'City',
        initialValue: city,
        filled: false,
        onSaved: (val) => city = val,
      ),
      Dropdown(
        key: const ValueKey('Country'),
        width: 500,
        showTitle: true,
        title: 'Country',
        value: country,
        onChanged: (val) {
          commonProvider.getPlaces(
            countries.firstWhere((element) => element.name == val).countryId,
          );
          setState(() => country = val);
        },
        items: getDropDownMenuItems(countries.map((e) => e.name).toList()),
      ),
      Dropdown(
        key: const ValueKey('State'),
        width: 500,
        showTitle: true,
        title: 'State',
        value: state,
        onChanged: (val) {
          setState(() => state = val);
        },
        items: getDropDownMenuItems(places.map((e) => e.name).toList()),
      ),
      // InputField(
      //   key: const ValueKey('State'),
      //   width: 500,
      //   label: 'State',
      //   initialValue: state,
      //   filled: false,
      //   onSaved: (val) => state = val,
      // ),
      InputField(
        key: const ValueKey('Pincode'),
        width: 500,
        label: 'Pincode',
        initialValue: pincode,
        filled: false,
        onSaved: (val) => pincode = val,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
      ),
    ];

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (widget.driver != null) {
          context.go(
            '/layout.drivers/driver-info?driverId=${widget.driver?.id}',
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.driver == null ? 'Add Driver' : 'Update Driver'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Wrap(spacing: 16, runSpacing: 16, children: widgets),
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
      ),
    );
  }
}
