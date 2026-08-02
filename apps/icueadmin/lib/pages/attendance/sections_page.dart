import 'package:flutter/material.dart';

import '../../dialogs/attendance_mode_dialog.dart';
import '../../models/assigned_entities.dart';
import '../../services/analytics_service.dart';
import '../../services/injectable.dart';
import '../../widgets/no_data_widget.dart';
import 'create_attendance_page.dart';
import 'sdk_attendance_page.dart';

class SectionsPage extends StatefulWidget {
  const SectionsPage({super.key, required this.standard});

  final AssignedEntityClass standard;

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  String? section;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'sections-page',
      parameters: {'standard': widget.standard.standard},
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: section == null
              ? null
              : () async {
                  final mode = await showDialog<AttendanceModeOption>(
                    context: context,
                    builder: (context) => const AttendanceModeDialog(),
                  );

                  if (mode == null || !context.mounted) return;

                  if (mode == AttendanceModeOption.manual) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAttendancePage(
                          standard: widget.standard,
                          section: section!,
                        ),
                      ),
                    );
                  } else if (mode == AttendanceModeOption.sdk) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SdkAttendancePage(
                          standard: widget.standard,
                          section: section!,
                        ),
                      ),
                    );
                  }
                },
          child: const Text('Start Attendance'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: Text(widget.standard.standard)),
      bottomNavigationBar: _buildBottomButton(context),
      body: widget.standard.sections.isEmpty
          ? const Center(child: NoDataWidget())
          : RadioGroup(
              groupValue: section,
              onChanged: (val) {
                setState(() => section = val);
              },
              child: ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                padding: const EdgeInsets.all(16),
                itemCount: widget.standard.sections.length,
                itemBuilder: (context, index) {
                  final item = widget.standard.sections[index];

                  return Card(
                    elevation: 1,
                    child: RadioListTile(
                      secondary: Image.asset('assets/bookmark.png', height: 20),
                      title: Text(
                        item,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      value: item,
                      activeColor: theme.primaryColor,
                      selected: section == item,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
