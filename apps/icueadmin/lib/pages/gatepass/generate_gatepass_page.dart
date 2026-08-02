import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../models/assigned_entities.dart';
import '../../providers/auth_provider.dart';
import '../../providers/students_provider.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/no_data_widget.dart';
import 'confirm_gatepass_page.dart';

class GenerateGatePassPage extends StatefulWidget {
  const GenerateGatePassPage({super.key});

  @override
  State<GenerateGatePassPage> createState() => _GenerateGatePassPageState();
}

class _GenerateGatePassPageState extends State<GenerateGatePassPage> {
  int? _classId;
  Timer? _debounce;
  List<AssignedEntityClass> _filteredStandards = [];
  String? _forPerson;
  bool _isPaginating = false;
  int _pageNo = 1;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final _searchInputDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0XFF2D7FBB), width: 2),
      borderRadius: BorderRadius.circular(5),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0XFF2D7FBB), width: 2),
      borderRadius: BorderRadius.circular(5),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0XFF2D7FBB), width: 2),
      borderRadius: BorderRadius.circular(5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    hintText: 'Search Admission No/Name',
    hintStyle: const TextStyle(color: Colors.grey),
    suffixIcon: const Icon(Icons.search),
  );

  String? _section;
  List<String> _sections = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    SchedulerBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  StudentsProvider get _studentsProvider =>
      Provider.of<StudentsProvider>(context, listen: false);

  AuthProvider get _authProvider =>
      Provider.of<AuthProvider>(context, listen: false);

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  Future<void> _initialize() async {
    await _authProvider.getPersonTypes(context);
    await _authProvider.getAssignedEntities(context);
    _studentsProvider.reset();
  }

  void _resetAndFetch() {
    _studentsProvider.reset();
    setState(() => _resetPagination());
    _fetchData();
  }

  void _resetPagination() {
    _pageNo = 1;
    _isPaginating = false;
  }

  Future<void> _fetchData({bool isPaginating = false}) async {
    final search = _searchController.text.trim();
    final sections = _section == null ? null : [_section!];

    // Guard clause: Don't fetch if required filters are not set (and not searching).
    if (search.isEmpty && (_classId == null || _section == null)) return;

    if (search.isNotEmpty) {
      await _studentsProvider.searchStudent(
        context: context,
        search: search,
        classId: _classId,
        sections: sections,
      );
    } else {
      await _studentsProvider.getStudents(
        context,
        _classId!,
        sections!,
        pageNo: _pageNo,
      );
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _resetAndFetch();
    });
  }

  void _onScroll() {
    final isAtBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isAtBottom && !_isPaginating && _studentsProvider.hasNextPage) {
      setState(() {
        _isPaginating = true;
        _pageNo++;
      });
      // Fetch the next page and update pagination state.
      _fetchData(isPaginating: true).whenComplete(() {
        if (mounted) setState(() => _isPaginating = false);
      });
    }
  }

  void _onPersonTypeChanged(String? val) {
    setState(() {
      _forPerson = val;
      _classId = null;
      _section = null;
      _sections = [];
      _updateFilteredStandards();
    });
    _searchController.clear();
  }

  void _onClassChanged(int? newValue) {
    if (newValue == null) return;
    final found = _filteredStandards.firstWhere((e) => e.classId == newValue);
    setState(() {
      _classId = newValue;
      _section = null;
      _sections = List<String>.from(found.sections);
    });
    _searchController.clear();
    _resetAndFetch();
  }

  void _onSectionChanged(String? newValue) {
    setState(() => _section = newValue);
    _searchController.clear();
    _resetAndFetch();
  }

  void _updateFilteredStandards() {
    if (_forPerson == null) {
      _filteredStandards = [];
      return;
    }
    _filteredStandards = _authProvider.assignedEntityClasses
        .where((e) => e.standardType == _forPerson)
        .toList(growable: false);

    if (_forPerson != 'STUDENT' && _filteredStandards.isNotEmpty) {
      final entity = _filteredStandards.first;
      _classId = entity.classId;
      _sections = List<String>.from(entity.sections);
    }
  }

  Widget _buildFilters() {
    return Column(
      children: [
        Dropdown(
          title: 'For',
          value: _forPerson,
          required: true,
          onChanged: _onPersonTypeChanged,
          items: getDropDownMenuItems(
            null,
            context
                .read<AuthProvider>()
                .personTypes
                .map((e) => MenuItem(id: e.category, name: e.category))
                .toList(),
          ),
        ),
        if (_forPerson != null) const SizedBox(height: 10),
        if (_forPerson != null)
          Row(
            children: [
              if (_forPerson == 'STUDENT')
                Expanded(
                  child: Dropdown(
                    title: 'Class',
                    value: _classId,
                    required: true,
                    onChanged: _onClassChanged,
                    items: getDropDownMenuItems(
                      null,
                      _filteredStandards
                          .map((e) => MenuItem(id: e.classId, name: e.standard))
                          .toList(),
                    ),
                  ),
                ),
              if (_forPerson == 'STUDENT') const SizedBox(width: 10),
              Expanded(
                child: Dropdown(
                  title: _forPerson == 'STUDENT' ? 'Section' : 'Department',
                  value: _section,
                  required: true,
                  disabled: _filteredStandards.isEmpty,
                  onChanged: _onSectionChanged,
                  items: getDropDownMenuItems(_sections),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: _searchInputDecoration,
    );
  }

  Widget _buildStudentListBody() {
    final provider = context.watch<StudentsProvider>();

    if (provider.studentsLoading && !_isPaginating) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.students.isEmpty) {
      final msg = _isSearching
          ? 'No students found for "${_searchController.text}"'
          : (_classId == null || _section == null
                ? 'Please select filters to see students'
                : 'No Students Found!');
      return NoDataWidget(msg: msg);
    }

    return ListView.separated(
      controller: _scrollController,
      primary: false,
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: provider.students.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = provider.students[index];
        return ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0XFFDEDEDE)),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.blue[50],
            child: Icon(Icons.person_outline, color: Colors.blue[800]),
          ),
          title: Text(
            item.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Admission No: ${item.admissionNumber}',
            style: const TextStyle(fontSize: 12, color: Color(0XFF4C4A5A)),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmGatePassPage(
                student: item,
                personType: _forPerson ?? '',
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Issue Gate Pass')),
      body: authProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFilters(),
                  if (_section != null) ...[
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                  ],
                  Expanded(child: _buildStudentListBody()),
                  if (_isPaginating)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
    );
  }
}
