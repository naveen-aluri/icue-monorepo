import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../dialogs/points_dialog.dart';
import '../../dialogs/preview_announcement_dialog.dart';
import '../../dialogs/routes_dialog.dart';
import '../../models/announcement_titles.dart';
import '../../models/routes.dart';
import '../../providers/announcements_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/inputfield.dart';

class PostAnnouncementsPage extends StatefulWidget {
  const PostAnnouncementsPage({super.key});

  @override
  State<PostAnnouncementsPage> createState() => _PostAnnouncementsPageState();
}

const List<String> announcementType = [
  'Entire Fleet',
  'Selected Routes',
  'Effected parents for single route',
];

class _PostAnnouncementsPageState extends State<PostAnnouncementsPage> {
  AnnouncementTitle? announcementTitle;
  List<String> selectedPoints = [];
  List<int> selectedRoutes = [];
  List<int> studentIds = [];
  String? announcementFor, title, mode;

  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _selectedPointsController =
      TextEditingController();

  final TextEditingController _selectedRoutesController =
      TextEditingController();

  List<TextEditingController> _varControllers = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnnouncementsProvider>(
        context,
        listen: false,
      ).getAnnouncementTitles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnnouncementsProvider>(context);
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    if (_varControllers.isEmpty && announcementTitle != null) {
      _varControllers = List.generate(
        announcementTitle?.vars.length ?? 0,
        (index) => TextEditingController(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Announcement'),
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
                'Timely and informative messages enhancing communication and ensuring important updates reach the intended effectively.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/layout.fleetannouncement/layout.annoucements');
        },
        label: const Text('History'),
        icon: const Icon(Icons.history),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Dropdown(
                    title: 'Announcement For',
                    value: announcementFor,
                    required: true,
                    onChanged: (val) => setState(() => announcementFor = val),
                    items: getDropDownMenuItems(announcementType),
                  ),
                  if (announcementFor == 'Entire Fleet')
                    Text(
                      '⚠️warning: This message goes to all parents!',
                      style: TextStyle(color: Colors.amber.shade700),
                    ),
                  const SizedBox(height: 16),
                  Dropdown(
                    title: 'Select Mode',
                    value: mode,
                    required: true,
                    onChanged: (val) {
                      vehicleProvider.clearData();
                      vehicleProvider.getRoutesAndPoints(
                        val == 'Pickup' ? Mode.PICKUP : Mode.DROP,
                      );
                      setState(() => mode = val);
                    },
                    items: getDropDownMenuItems(['Pickup', 'Drop']),
                  ),
                  ...(announcementFor == 'Selected Routes'
                      ? [
                          const SizedBox(height: 16),
                          InputField(
                            initialValue: '',
                            controller: _selectedRoutesController,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select routes'
                                : null,
                            readOnly: true,
                            type: TextFieldType.dropdown,
                            onTap: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => RoutesDialog(
                                  selectedRoutes: selectedRoutes,
                                  mode: mode == 'Drop'
                                      ? Mode.DROP
                                      : Mode.PICKUP,
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  selectedRoutes = result[0];
                                  _selectedRoutesController.text = result[1]
                                      .join(', ');
                                });
                              }
                            },
                            label: 'Select Routes',
                            showTitle: false,
                            filled: false,
                            hintText: 'Select Routes',
                          ),
                        ]
                      : []),
                  ...(announcementFor == 'Effected parents for single route'
                      ? [
                          const SizedBox(height: 16),
                          Dropdown<int>(
                            title: 'Select Route',
                            value: selectedRoutes.isEmpty
                                ? null
                                : selectedRoutes[0],
                            required: true,
                            onChanged: (newValue) {
                              setState(() {
                                selectedRoutes.clear();
                                selectedRoutes.add(newValue!);
                                _selectedPointsController.clear();
                              });
                            },
                            items: getDropDownMenuItems(
                              null,
                              vehicleProvider.routes
                                  .map(
                                    (e) => MenuItem(id: e.id, name: e.routeNo),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InputField(
                            initialValue: '',
                            controller: _selectedPointsController,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select points'
                                : null,
                            readOnly: true,
                            onTap: selectedRoutes.isEmpty
                                ? null
                                : () async {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (context) => PointsDialog(
                                        selectedPoints: selectedPoints,
                                        points:
                                            vehicleProvider.routes
                                                .firstWhereOrNull(
                                                  (e) =>
                                                      e.id == selectedRoutes[0],
                                                )
                                                ?.points ??
                                            [],
                                      ),
                                    );
                                    if (result != null) {
                                      setState(() {
                                        selectedPoints = result[0];
                                        studentIds = result[1];
                                        _selectedPointsController.text =
                                            selectedPoints.join(', ');
                                      });
                                    }
                                  },
                            label: 'Select Points',
                            hintText: 'Select Points',
                            showTitle: false,
                            filled: false,
                            type: TextFieldType.dropdown,
                          ),
                        ]
                      : []),
                  const SizedBox(height: 16),
                  Dropdown<String>(
                    title: 'Select title',
                    value: title,
                    required: true,
                    onChanged: (newValue) {
                      setState(() {
                        _varControllers.clear();
                        title = newValue;
                        announcementTitle = provider.announcementTitles
                            .singleWhere((e) => e.title == newValue);
                        _descriptionController.text =
                            '${announcementTitle?.descHeader} ${announcementTitle?.descBody} ${announcementTitle?.descFooter}';
                      });
                    },
                    items: getDropDownMenuItems(
                      null,
                      provider.announcementTitles
                          .map((e) => MenuItem(id: e.title, name: e.title))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...((announcementTitle != null &&
                          announcementTitle?.title != 'Custom')
                      ? [Text(_descriptionController.text)]
                      : []),
                  ...((announcementTitle != null &&
                          announcementTitle?.title == 'Custom')
                      ? [
                          InputField(
                            key: const Key('Title'),
                            label: 'Title',
                            initialValue: '',
                            isRequired: true,
                            showTitle: false,
                            filled: false,
                            onSaved: (val) => title = val,
                            hintText: 'Please enter the title',
                          ),
                          const SizedBox(height: 16),
                          InputField(
                            key: const Key('Announcement'),
                            label: 'Announcement',
                            initialValue: '',
                            isRequired: true,
                            showTitle: false,
                            filled: false,
                            textInputAction: TextInputAction.newline,
                            onChanged: (val) =>
                                _descriptionController.text = val,
                            maxLines: 7,
                            hintText: 'Please enter your announcement',
                          ),
                        ]
                      : []),
                  const SizedBox(height: 16),
                  if (announcementTitle?.vars != null &&
                      announcementTitle!.vars.isNotEmpty &&
                      _varControllers.isNotEmpty)
                    ListView.separated(
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (context, index) {
                        final item = announcementTitle?.vars[index];
                        return InputField(
                          initialValue: '',
                          controller: _varControllers[index],
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter $item'
                              : null,
                          onSaved: (newValue) => _descriptionController.text =
                              _descriptionController.text.replaceFirst(
                                '[$item]',
                                newValue ?? '',
                              ),
                          label: item ?? '',
                          showTitle: false,
                          hintText: 'Please enter $item',
                          filled: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9\s!@#\$&*;,:/-]'),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemCount: announcementTitle?.vars.length ?? 0,
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final res = await showDialog<bool>(
                          context: context,
                          builder: (context) => PreviewAnnouncementDialog(
                            title: title!,
                            mode: mode!,
                            description: _descriptionController.text,
                            routes: selectedRoutes,
                            points: selectedPoints,
                            studentId: studentIds,
                          ),
                        );
                        if (res == true) {
                          setState(() {
                            title = null;
                            _descriptionController.clear();
                            announcementFor = null;
                            selectedRoutes = [];
                            announcementTitle = null;
                            _selectedRoutesController.clear();
                          });
                        }
                      }
                    },
                    child: const Text(
                      'Preview & Send',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
