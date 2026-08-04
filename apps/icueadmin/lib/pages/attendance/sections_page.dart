import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dialogs/attendance_mode_dialog.dart';
import '../../models/assigned_entities.dart';
import '../../providers/attendance_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/injectable.dart';
import '../../utils/app_utils.dart';
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
                  final mode = await AttendanceModeDialog.show(context);

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
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SdkAttendancePage(
                          standard: widget.standard,
                          section: section!,
                          initialMode: mode,
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
              onChanged: (val) async {
                if (val == null || !mounted) return;

                AppUtils.showLoadingDialog(
                  context,
                  'Checking attendance...Please wait...',
                );

                try {
                  final attendanceProvider = context.read<AttendanceProvider>();
                  final date = DateTime.now().formattedGatePassDate() ?? '';
                  final exists = await attendanceProvider.checkAttendanceExists(
                    context: context,
                    classId: widget.standard.classId,
                    section: val,
                    date: date,
                    period: '1',
                  );

                  if (!mounted) return;
                  AppUtils.hideLoadingDialog(context);

                  setState(() {
                    section = !exists ? val : null;
                  });
                } catch (e) {
                  if (mounted) {
                    AppUtils.hideLoadingDialog(context);
                    AppUtils.showErrorMessage(
                      context,
                      'An unexpected error occurred.',
                    );
                    setState(() {
                      section = null;
                    });
                  }
                }
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
