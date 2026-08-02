import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../dialogs/delete_dialog.dart';
import '../../providers/vehicle_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/file_upload_widget.dart';
import '../../widgets/inputfield.dart';
import '../vehicle_management/reports/image_view.dart';
import '../webview_page.dart';

class VehicleDocsPage extends StatefulWidget {
  const VehicleDocsPage({super.key, required this.id});

  final String id;

  @override
  State<VehicleDocsPage> createState() => _VehicleDocsPageState();
}

class _VehicleDocsPageState extends State<VehicleDocsPage> {
  final docsList = [
    'Insurance',
    'RC',
    'Fitness',
    'RoadTax',
    'Pollution',
    'Permit',
  ];

  final Map<String, bool> editMap = {
    'Insurance': false,
    'RC': false,
    'Fitness': false,
    'RoadTax': false,
    'Pollution': false,
    'Permit': false,
  };

  final Map<String, TextEditingController> expiryDateControllers = {};
  final Map<String, DateTime> expiryDates = {};
  final Map<String, XFile> fileMap = {};
  bool loading = true;
  final Map<String, TextEditingController> numberControllers = {};
  final Map<String, TextEditingController> startDateControllers = {};
  final Map<String, DateTime> startDates = {};

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<VehicleProvider>(context, listen: false);
      for (final doc in docsList) {
        final data = await provider.getVehicleDocs(
          id: int.parse(widget.id),
          type: doc,
        );
        if (data != null) {
          if (doc == 'Insurance') {
            numberControllers[doc] = TextEditingController(
              text: data.insuranceNumber,
            );
            final sDate = data.insuredDate;
            final eDate = data.insuranceExpiryDate;
            startDateControllers[doc] = TextEditingController(text: sDate);
            expiryDateControllers[doc] = TextEditingController(text: eDate);
            startDates[doc] = sDate.toDate() ?? DateTime.now();
            expiryDates[doc] = eDate.toDate() ?? DateTime.now();
          }
          if (doc == 'RC') {
            numberControllers[doc] = TextEditingController(text: data.rcNumber);
            final sDate = data.rcStartDate;
            final eDate = data.rcExpiryDate;
            startDateControllers[doc] = TextEditingController(text: sDate);
            expiryDateControllers[doc] = TextEditingController(text: eDate);
            startDates[doc] = sDate.toDate() ?? DateTime.now();
            expiryDates[doc] = eDate.toDate() ?? DateTime.now();
          }
          if (doc == 'Fitness') {
            numberControllers[doc] = TextEditingController(
              text: data.fitnessNumber,
            );
            final sDate = data.fitnessStartDate;
            final eDate = data.fitnessExpiryDate;
            startDateControllers[doc] = TextEditingController(text: sDate);
            expiryDateControllers[doc] = TextEditingController(text: eDate);
            startDates[doc] = sDate.toDate() ?? DateTime.now();
            expiryDates[doc] = eDate.toDate() ?? DateTime.now();
          }
          if (doc == 'RoadTax') {
            numberControllers[doc] = TextEditingController(
              text: data.roadTaxNumber,
            );
            final sDate = data.roadTaxStartDate;
            final eDate = data.roadTaxExpiryDate;
            startDateControllers[doc] = TextEditingController(text: sDate);
            expiryDateControllers[doc] = TextEditingController(text: eDate);
            startDates[doc] = sDate.toDate() ?? DateTime.now();
            expiryDates[doc] = eDate.toDate() ?? DateTime.now();
          }
          if (doc == 'Pollution') {
            numberControllers[doc] = TextEditingController(
              text: data.pollutionNumber,
            );
            final sDate = data.pollutionStartDate;
            final eDate = data.pollutionExpiryDate;
            startDateControllers[doc] = TextEditingController(text: sDate);
            expiryDateControllers[doc] = TextEditingController(text: eDate);
            startDates[doc] = sDate.toDate() ?? DateTime.now();
            expiryDates[doc] = eDate.toDate() ?? DateTime.now();
          }
          if (doc == 'Permit') {
            numberControllers[doc] = TextEditingController(
              text: data.permitNumber,
            );
            final sDate = data.permitStartDate;
            final eDate = data.permitExpiryDate;
            startDateControllers[doc] = TextEditingController(text: sDate);
            expiryDateControllers[doc] = TextEditingController(text: eDate);
            startDates[doc] = sDate.toDate() ?? DateTime.now();
            expiryDates[doc] = eDate.toDate() ?? DateTime.now();
          }
        } else {
          numberControllers[doc] = TextEditingController();
          startDateControllers[doc] = TextEditingController();
          expiryDateControllers[doc] = TextEditingController();
          startDates[doc] = DateTime.now();
          expiryDates[doc] = DateTime.now();
        }
      }
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  void _showError(String message) {
    AppUtils.showErrorMessage(context, message);
  }

  bool _validateInputs(String doc) {
    if (numberControllers[doc]!.text.isEmpty) {
      _showError('$doc Number is required!');
      return false;
    }
    if (startDateControllers[doc]!.text.isEmpty) {
      _showError('$doc Start Date is required!');
      return false;
    }
    if (expiryDateControllers[doc]!.text.isEmpty) {
      _showError('$doc Expiry Date is required!');
      return false;
    }
    if (fileMap[doc] == null) {
      _showError('$doc Document is required!');
      return false;
    }
    return true;
  }

  Map<String, String> _buildUploadPayload(String doc) {
    return {
      '${doc}Number': numberControllers[doc]!.text,
      doc == 'Insurance' ? 'InsuredDate' : '${doc}StartDate':
          startDateControllers[doc]!.text,
      '${doc}ExpiryDate': expiryDateControllers[doc]!.text,
    };
  }

  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
    required DateTime selectedDate,
    required void Function(DateTime) onDateSelected,
    required bool readOnly,
    required bool allowFutureDates,
  }) {
    return Expanded(
      child: InputField(
        label: label,
        hintText: 'Select Date',
        initialValue: controller.text,
        controller: controller,
        filled: false,
        type: TextFieldType.datePicker,
        readOnly: readOnly,
        enabled: !readOnly,
        onTap: readOnly
            ? null
            : () async {
                final date = await AppUtils.selectDate(
                  context: context,
                  initialDate: selectedDate,
                  allowFutureDates: allowFutureDates,
                );
                if (date != null) {
                  onDateSelected(date);
                }
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    final vehicle = provider.vehiclesData.firstWhere(
      (element) => element.id == int.parse(widget.id),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Documents - ${vehicle.number}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: 1080,
                  child: Column(
                    spacing: 20,
                    children: docsList.map((doc) {
                      return ExpansionTile(
                        initiallyExpanded: true,
                        title: Text(
                          doc,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.green),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.green),
                        ),
                        childrenPadding: const EdgeInsets.all(10),
                        children: [
                          InputField(
                            initialValue: numberControllers[doc]?.text ?? '',
                            label: '$doc Number',
                            controller: numberControllers[doc],
                            filled: false,
                            readOnly: !editMap[doc]!,
                            enabled: editMap[doc]!,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildDatePickerField(
                                label: 'Start Date',
                                controller: startDateControllers[doc]!,
                                selectedDate: startDates[doc]!,
                                readOnly: !editMap[doc]!,
                                allowFutureDates: false,
                                onDateSelected: (date) {
                                  setState(() {
                                    startDates[doc] = date;
                                    startDateControllers[doc]!.text =
                                        date.formattedGatePassDate() ?? '';
                                  });
                                },
                              ),
                              const SizedBox(width: 16),
                              _buildDatePickerField(
                                label: 'Expiry Date',
                                controller: expiryDateControllers[doc]!,
                                selectedDate: expiryDates[doc]!,
                                readOnly: !editMap[doc]!,
                                allowFutureDates: true,
                                onDateSelected: (date) {
                                  setState(() {
                                    expiryDates[doc] = date;
                                    expiryDateControllers[doc]!.text =
                                        date.formattedGatePassDate() ?? '';
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          FileFromUrl(
                            fileUrl: provider.vehicleDocs[doc]?.docUrl ?? '',
                            contentType:
                                provider.vehicleDocs[doc]?.contentType ?? '',
                            type: doc,
                            vehicleId: int.parse(widget.id),
                            selectedFile: fileMap[doc],
                            onFilePick: !editMap[doc]!
                                ? null
                                : (xFile) {
                                    setState(() {
                                      fileMap[doc] = xFile;
                                    });
                                  },
                          ),
                          const SizedBox(height: 10),
                          !editMap[doc]!
                              ? OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      editMap[doc] = true;
                                    });
                                  },
                                  child: const Text('Edit'),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    if (_validateInputs(doc)) {
                                      provider.uploadVehicleDocs(
                                        context,
                                        int.parse(widget.id),
                                        doc,
                                        fileMap[doc]!,
                                        _buildUploadPayload(doc),
                                      );
                                      setState(() {
                                        editMap[doc] = false;
                                      });
                                    }
                                  },
                                  child: const Text('Update'),
                                ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ),
    );
  }
}

class FileFromUrl extends StatelessWidget {
  const FileFromUrl({
    super.key,
    this.fileUrl,
    required this.contentType,
    required this.type,
    required this.vehicleId,
    this.onFilePick,
    this.selectedFile,
  });

  final Function(XFile xFile)? onFilePick;
  final String contentType;
  final String? fileUrl;
  final XFile? selectedFile;
  final String type;
  final int vehicleId;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.grey),
      //   borderRadius: BorderRadius.circular(8),
      // ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: selectedFile != null
            ? [
                kIsWeb
                    ? Image.network(selectedFile!.path)
                    : Image.file(File(selectedFile!.path)),
              ]
            : [
                ...(fileUrl == null || fileUrl!.isEmpty
                    ? [
                        onFilePick == null
                            ? const SizedBox()
                            : FileUploadWidget(
                                title: 'Upload',
                                isPickImage: false,
                                allowedExtensions: [
                                  'jpg',
                                  'jpeg',
                                  'png',
                                  'pdf',
                                ],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                hint:
                                    'Only allow file types: jpg, jpeg, png, pdf\nMax file size: 300kb',
                                onDelete: () {},
                                onFilePick: (xFile, platformFile) {
                                  if (xFile == null && platformFile == null) {
                                    AppUtils.showErrorMessage(
                                      context,
                                      'File not selected',
                                    );
                                    return;
                                  }
                                  if (xFile != null) {
                                    onFilePick!(xFile);
                                  } else if (platformFile != null) {
                                    if (platformFile.size > 300000) {
                                      AppUtils.showErrorMessage(
                                        context,
                                        'File size should be less than 300kb',
                                      );
                                    } else {
                                      final file1 = kIsWeb
                                          ? XFile.fromData(
                                              platformFile.bytes!,
                                              name: platformFile.name,
                                              mimeType: platformFile.extension,
                                            )
                                          : XFile(
                                              platformFile.path!,
                                              name: platformFile.name,
                                              mimeType: platformFile.extension,
                                            );
                                      onFilePick!(file1);
                                    }
                                  }
                                },
                              ),
                      ]
                    : [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Image.network(
                            fileUrl ?? '',
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/document_placeholder.png'),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (contentType.contains('image')) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageView(
                                        url: fileUrl!,
                                        isBase64: false,
                                      ),
                                    ),
                                  );
                                } else if (contentType.contains(
                                  'application',
                                )) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebviewPage(
                                        url:
                                            'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(fileUrl!)}',
                                        title: 'Document',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.visibility),
                              iconSize: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => DeleteDialog(
                                    onDelete: () {
                                      provider.deleteVehicleDoc(
                                        context,
                                        vehicleId,
                                        type,
                                      );
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete_forever),
                              iconSize: 40,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ]),
              ],
      ),
    );
  }
}
