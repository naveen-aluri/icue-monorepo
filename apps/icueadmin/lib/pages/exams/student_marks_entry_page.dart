import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/exam_marks.dart';
import '../../models/exam_schedule.dart';
import '../../providers/exam_provider.dart';
import '../../utils/app_utils.dart';

class StudentMarksEntryPage extends StatefulWidget {
  const StudentMarksEntryPage({
    super.key,
    required this.schedule,
    required this.academicYear,
    this.className,
  });

  final String academicYear;
  final String? className;
  final ExamSchedule schedule;

  @override
  State<StudentMarksEntryPage> createState() => _StudentMarksEntryPageState();
}

class _StudentMarksEntryPageState extends State<StudentMarksEntryPage> {
  String _filterStatus = 'ALL'; // 'ALL', 'PENDING', 'PRESENT', 'ABSENT'
  final Map<int, TextEditingController> _marksControllers = {};
  final Map<int, FocusNode> _marksFocusNodes = {};
  final Map<int, TextEditingController> _remarksControllers = {};
  final Map<int, FocusNode> _remarksFocusNodes = {};
  final Set<int> _savingStudentIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    for (final c in _marksControllers.values) {
      c.dispose();
    }
    for (final c in _remarksControllers.values) {
      c.dispose();
    }
    for (final f in _marksFocusNodes.values) {
      f.dispose();
    }
    for (final f in _remarksFocusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    final examProvider = context.read<ExamProvider>();
    await examProvider.getExamStudents(
      examId: widget.schedule.id,
      academicYear: widget.academicYear,
      classId: widget.schedule.classId,
      section: widget.schedule.section,
    );

    if (mounted) {
      _initControllers(examProvider.students);
    }
  }

  void _initControllers(List<ExamStudent> students) {
    for (final s in students) {
      final marksText =
          (s.status == 'ABSENT' || s.status == 'NA' || s.marks == null)
          ? ''
          : s.marks.toString();

      if (_marksControllers.containsKey(s.studentId)) {
        if (_marksFocusNodes[s.studentId]?.hasFocus != true &&
            _marksControllers[s.studentId]!.text != marksText) {
          _marksControllers[s.studentId]!.text = marksText;
        }
      } else {
        _marksControllers[s.studentId] = TextEditingController(text: marksText);
      }

      final remarksText = s.remarks ?? '';
      if (_remarksControllers.containsKey(s.studentId)) {
        if (_remarksFocusNodes[s.studentId]?.hasFocus != true &&
            _remarksControllers[s.studentId]!.text != remarksText) {
          _remarksControllers[s.studentId]!.text = remarksText;
        }
      } else {
        _remarksControllers[s.studentId] = TextEditingController(
          text: remarksText,
        );
      }

      if (!_marksFocusNodes.containsKey(s.studentId)) {
        final fn = FocusNode();
        fn.addListener(() {
          if (!fn.hasFocus) {
            _onStudentFieldFocusLost(s.studentId);
          }
        });
        _marksFocusNodes[s.studentId] = fn;
      }

      if (!_remarksFocusNodes.containsKey(s.studentId)) {
        final rfn = FocusNode();
        rfn.addListener(() {
          if (!rfn.hasFocus) {
            _onStudentFieldFocusLost(s.studentId);
          }
        });
        _remarksFocusNodes[s.studentId] = rfn;
      }
    }
  }

  Future<void> _onStudentFieldFocusLost(int studentId) async {
    final examProvider = context.read<ExamProvider>();
    final student = examProvider.students.firstWhereOrNull(
      (s) => s.studentId == studentId,
    );
    if (student == null) return;

    // Avoid redundant auto-save if already saving or clean
    if (_savingStudentIds.contains(studentId) || student.isSaved) return;

    if (student.status != 'ABSENT' && student.status != 'NA') {
      final ctrl = _marksControllers[studentId];
      final text = ctrl?.text.trim() ?? '';
      if (text.isEmpty && student.marks == null) {
        // Field is empty and no marks were set, don't auto-save
        return;
      }
      final val = num.tryParse(text);
      if (val != null && val > widget.schedule.maximumMarks) {
        // Mark exceeds maximum, do not auto-save invalid score
        return;
      }
    }

    await _saveSingleStudent(student, isAutoSave: true);
  }

  List<ExamStudent> _getFilteredStudents(List<ExamStudent> allStudents) {
    var list = allStudents;

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((s) {
        return s.name.toLowerCase().contains(q) ||
            (s.rollNo?.toLowerCase().contains(q) ?? false) ||
            (s.admissionNumber?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Filter by status tab
    switch (_filterStatus) {
      case 'PENDING':
        list = list
            .where(
              (s) =>
                  s.marks == null && s.status != 'ABSENT' && s.status != 'NA',
            )
            .toList();
        break;
      case 'PRESENT':
        list = list
            .where((s) => s.status == 'PRESENT' && s.marks != null)
            .toList();
        break;
      case 'ABSENT':
        list = list.where((s) => s.status == 'ABSENT').toList();
        break;
      case 'NA':
        list = list.where((s) => s.status == 'NA').toList();
        break;
      case 'ALL':
      default:
        break;
    }

    return list;
  }

  Future<void> _flushPendingMarks() async {
    final examProvider = context.read<ExamProvider>();
    final unsavedList = examProvider.students
        .where(
          (s) =>
              !s.isSaved &&
              (s.marks != null || s.status == 'ABSENT' || s.status == 'NA'),
        )
        .toList();

    if (unsavedList.isNotEmpty) {
      final validList = unsavedList.where((s) {
        if (s.status == 'ABSENT' || s.status == 'NA') return true;
        return s.marks == null || s.marks! <= widget.schedule.maximumMarks;
      }).toList();

      if (validList.isNotEmpty) {
        await examProvider.saveExamMarks(
          null,
          examId: widget.schedule.id,
          studentList: validList,
          showLoading: false,
        );
      }
    }
  }

  Future<void> _saveAllUnsavedMarks() async {
    final examProvider = context.read<ExamProvider>();
    final unsavedList = examProvider.students
        .where(
          (s) =>
              !s.isSaved &&
              (s.marks != null || s.status == 'ABSENT' || s.status == 'NA'),
        )
        .toList();

    if (unsavedList.isEmpty) return;

    // Validate marks before batch saving
    for (final s in unsavedList) {
      if (s.status != 'ABSENT' && s.status != 'NA') {
        if (s.marks != null && s.marks! > widget.schedule.maximumMarks) {
          AppUtils.showErrorMessage(
            context,
            '${s.name}\'s mark (${s.marks}) exceeds Maximum Marks (${widget.schedule.maximumMarks})',
          );
          _marksFocusNodes[s.studentId]?.requestFocus();
          return;
        }
      }
    }

    setState(() {
      for (final s in unsavedList) {
        _savingStudentIds.add(s.studentId);
      }
    });

    try {
      await examProvider.saveExamMarks(
        context,
        examId: widget.schedule.id,
        studentList: unsavedList,
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingStudentIds.clear();
        });
      }
    }
  }

  Future<void> _saveSingleStudent(
    ExamStudent student, {
    bool isAutoSave = false,
  }) async {
    final examProvider = context.read<ExamProvider>();

    if (student.status != 'ABSENT' && student.status != 'NA') {
      final ctrl = _marksControllers[student.studentId];
      final val = num.tryParse(ctrl?.text.trim() ?? '');
      if (val != null && val > widget.schedule.maximumMarks) {
        if (!isAutoSave) {
          AppUtils.showErrorMessage(
            context,
            '${student.name}\'s mark ($val) exceeds Maximum Marks (${widget.schedule.maximumMarks})',
          );
        }
        _marksFocusNodes[student.studentId]?.requestFocus();
        return;
      }
    }

    setState(() => _savingStudentIds.add(student.studentId));
    try {
      await examProvider.saveExamMarks(
        isAutoSave ? null : context,
        examId: widget.schedule.id,
        studentList: [student],
        showLoading: !isAutoSave,
      );
    } finally {
      if (mounted) {
        setState(() => _savingStudentIds.remove(student.studentId));
      }
    }
  }

  void _focusNextStudentMark(
    int currentStudentId,
    List<ExamStudent> visibleList,
  ) {
    final currentIndex = visibleList.indexWhere(
      (s) => s.studentId == currentStudentId,
    );
    if (currentIndex != -1 && currentIndex + 1 < visibleList.length) {
      for (int i = currentIndex + 1; i < visibleList.length; i++) {
        final next = visibleList[i];
        if (next.status != 'ABSENT' && next.status != 'NA') {
          _marksFocusNodes[next.studentId]?.requestFocus();
          break;
        }
      }
    }
  }

  Widget _buildStickyHeader({
    required ThemeData theme,
    required int total,
    required int enteredCount,
    required int pendingCount,
    required int presentCount,
    required int absentCount,
    required int naCount,
    required double progress,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Progress row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$enteredCount of $total Entered',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(progress * 100).toInt()}% Done',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search roll, student name, admission #',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
          ),

          // Status Filter Tabs (All, Pending, Present, Absent, N/A)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All ($total)'),
                _buildFilterChip('PENDING', 'Pending ($pendingCount)'),
                _buildFilterChip('PRESENT', 'Present ($presentCount)'),
                _buildFilterChip('ABSENT', 'Absent ($absentCount)'),
                if (naCount > 0) _buildFilterChip('NA', 'Exempted ($naCount)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filterStatus == key;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => setState(() => _filterStatus = key),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? theme.primaryColor : const Color(0xFFCBD5E1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard({
    required ExamStudent student,
    required List<ExamStudent> visibleList,
    required ThemeData theme,
  }) {
    final isAbsent = student.status == 'ABSENT';
    final isNA = student.status == 'NA';
    final isPresent = !isAbsent && !isNA;
    final isSavingRow = _savingStudentIds.contains(student.studentId);
    final examProvider = context.read<ExamProvider>();

    final marksCtrl = _marksControllers[student.studentId];
    final remarksCtrl = _remarksControllers[student.studentId];
    final focusNode = _marksFocusNodes[student.studentId];
    final remarksFocusNode = _remarksFocusNodes[student.studentId];

    final enteredMark = num.tryParse(marksCtrl?.text.trim() ?? '');
    final isMarkExceeded =
        enteredMark != null && enteredMark > widget.schedule.maximumMarks;
    final isPassed =
        enteredMark != null && enteredMark >= widget.schedule.passingMarks;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMarkExceeded
              ? const Color(0xFFEF4444)
              : const Color(0xFFE2E8F0),
          width: isMarkExceeded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Roll, Student Name, Adm No, Saved Badge & Save Action
            Row(
              children: [
                // Roll Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    student.rollNo?.isNotEmpty == true
                        ? '#${student.rollNo}'
                        : '-',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Name & Adm No
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (student.admissionNumber?.isNotEmpty == true)
                        Text(
                          'Adm: ${student.admissionNumber}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Save Indicator Badge
                if (isSavingRow)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Saving...',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (student.isSaved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: Color(0xFF15803D),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Saved',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (student.marks != null || isAbsent || isNA)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Unsaved',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                // Individual Save Icon Button
                IconButton(
                  tooltip: 'Save for this student',
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: isSavingRow
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.save_outlined,
                          color: Color(0xFF475569),
                        ),
                  onPressed: isSavingRow
                      ? null
                      : () => _saveSingleStudent(student),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Row 2: Status Toggle Pills (Present / Absent / N/A)
            Row(
              children: [
                _buildStatusPill(
                  label: 'Present',
                  isActive: isPresent,
                  activeBgColor: const Color(0xFFDCFCE7),
                  activeTextColor: const Color(0xFF15803D),
                  activeBorderColor: const Color(0xFF86EFAC),
                  onTap: () {
                    if (isAbsent || isNA) {
                      examProvider.updateStudentStatus(
                        student.studentId,
                        'PRESENT',
                      );
                      focusNode?.requestFocus();
                    }
                  },
                ),
                const SizedBox(width: 8),
                _buildStatusPill(
                  label: 'Absent',
                  isActive: isAbsent,
                  activeBgColor: const Color(0xFFFEE2E2),
                  activeTextColor: const Color(0xFFB91C1C),
                  activeBorderColor: const Color(0xFFFCA5A5),
                  onTap: () {
                    if (student.status != 'ABSENT') {
                      marksCtrl?.clear();
                      examProvider.updateStudentStatus(
                        student.studentId,
                        'ABSENT',
                      );
                      // Auto save when toggled to absent
                      _saveSingleStudent(student, isAutoSave: true);
                    }
                  },
                ),
                const SizedBox(width: 8),
                _buildStatusPill(
                  label: 'N/A',
                  isActive: isNA,
                  activeBgColor: const Color(0xFFF1F5F9),
                  activeTextColor: const Color(0xFF475569),
                  activeBorderColor: const Color(0xFFCBD5E1),
                  onTap: () {
                    if (student.status != 'NA') {
                      marksCtrl?.clear();
                      examProvider.updateStudentStatus(student.studentId, 'NA');
                      // Auto save when toggled to NA
                      _saveSingleStudent(student, isAutoSave: true);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Row 3: Marks Entry Input or Absent Notice
            if (isPresent) ...[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: marksCtrl,
                        focusNode: focusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: '0 - ${widget.schedule.maximumMarks}',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w400,
                          ),
                          suffixText: '/ ${widget.schedule.maximumMarks}',
                          suffixStyle: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isMarkExceeded
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isMarkExceeded
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isMarkExceeded
                                  ? const Color(0xFFEF4444)
                                  : theme.primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          final parsed = num.tryParse(val.trim());
                          examProvider.updateStudentMark(
                            student.studentId,
                            parsed,
                          );
                        },
                        onSubmitted: (_) {
                          _focusNextStudentMark(student.studentId, visibleList);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Pass/Fail Pill Indicator
                  if (enteredMark != null && !isMarkExceeded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPassed
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFFCA5A5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPassed ? Icons.check : Icons.close,
                            size: 13,
                            color: isPassed
                                ? const Color(0xFF15803D)
                                : const Color(0xFFB91C1C),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isPassed ? 'Pass' : 'Fail',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isPassed
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (isMarkExceeded)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    'Exceeds maximum marks (${widget.schedule.maximumMarks})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ] else ...[
              // Soft banner when Absent or NA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isAbsent
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAbsent
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAbsent
                          ? Icons.person_off_outlined
                          : Icons.remove_circle_outline,
                      size: 16,
                      color: isAbsent
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAbsent
                          ? 'Marked as Absent (Marks exempted)'
                          : 'Marked as Not Applicable (Exempted)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isAbsent
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Row 4: Remarks Field (Compact)
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: remarksCtrl,
                focusNode: remarksFocusNode,
                style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                decoration: InputDecoration(
                  hintText: 'Remarks / note (optional)',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                      width: 1.2,
                    ),
                  ),
                ),
                onChanged: (val) {
                  examProvider.updateStudentRemarks(student.studentId, val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill({
    required String label,
    required bool isActive,
    required Color activeBgColor,
    required Color activeTextColor,
    required Color activeBorderColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? activeBgColor : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? activeBorderColor : const Color(0xFFE2E8F0),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeTextColor : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No students match the criteria',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search query or status filter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final examProvider = context.watch<ExamProvider>();

    final total = examProvider.students.length;
    final presentCount = examProvider.students
        .where((s) => s.status == 'PRESENT' && s.marks != null)
        .length;
    final absentCount = examProvider.students
        .where((s) => s.status == 'ABSENT')
        .length;
    final naCount = examProvider.students.where((s) => s.status == 'NA').length;
    final enteredCount = presentCount + absentCount + naCount;
    final pendingCount = total - enteredCount;
    final unsavedCount = examProvider.students
        .where(
          (s) =>
              !s.isSaved &&
              (s.marks != null || s.status == 'ABSENT' || s.status == 'NA'),
        )
        .length;
    final progress = total > 0 ? (enteredCount / total) : 0.0;

    final filteredStudents = _getFilteredStudents(examProvider.students);

    final displayClass =
        widget.className ??
        (widget.schedule.standard?.isNotEmpty == true
            ? widget.schedule.standard!
            : 'Class ${widget.schedule.classId}');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        FocusScope.of(context).unfocus();
        await _flushPendingMarks();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  await _flushPendingMarks();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.schedule.subject} Marks',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$displayClass • Sec ${widget.schedule.section} • Max: ${widget.schedule.maximumMarks}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              actions: [
                if (unsavedCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.save, size: 16),
                      label: Text(
                        'Save All ($unsavedCount)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _saveAllUnsavedMarks(),
                    ),
                  ),
              ],
            ),
            body: examProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Top Sticky Summary Card & Filter Strip
                      _buildStickyHeader(
                        theme: theme,
                        total: total,
                        enteredCount: enteredCount,
                        pendingCount: pendingCount,
                        presentCount: presentCount,
                        absentCount: absentCount,
                        naCount: naCount,
                        progress: progress,
                      ),

                      // Student Cards List
                      Expanded(
                        child: filteredStudents.isEmpty
                            ? _buildEmptyView()
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth > 700;
                                  if (isWide) {
                                    return GridView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        8,
                                        16,
                                        24,
                                      ),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 1.6,
                                            crossAxisSpacing: 14,
                                            mainAxisSpacing: 14,
                                          ),
                                      itemCount: filteredStudents.length,
                                      itemBuilder: (ctx, i) {
                                        return _buildStudentCard(
                                          student: filteredStudents[i],
                                          visibleList: filteredStudents,
                                          theme: theme,
                                        );
                                      },
                                    );
                                  }

                                  return ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      24,
                                    ),
                                    itemCount: filteredStudents.length,
                                    separatorBuilder: (ctx, i) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (ctx, i) {
                                      return _buildStudentCard(
                                        student: filteredStudents[i],
                                        visibleList: filteredStudents,
                                        theme: theme,
                                      );
                                    },
                                  );
                                },
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
