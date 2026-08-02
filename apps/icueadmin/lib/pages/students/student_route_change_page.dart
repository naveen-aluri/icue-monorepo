import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../dialogs/change_route_dialog.dart';
import '../../models/routes.dart';
import '../../models/standards.dart';
import '../../models/student.dart';
import '../../providers/students_provider.dart';
import '../../widgets/no_data_widget.dart';

class StudentRouteChangePage extends StatefulWidget {
  const StudentRouteChangePage({super.key});

  @override
  State<StudentRouteChangePage> createState() => _StudentRouteChangePageState();
}

class _StudentRouteChangePageState extends State<StudentRouteChangePage> {
  int? classId;
  String? section;
  List<Section> sections = [];
  String? selectedRouteOption;

  Timer? _debounce;
  bool _isPaginating = false;
  int _pageNo = 1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentsProvider>(
        context,
        listen: false,
      ).getStandards(context);
    });
    _scrollController.addListener(_onScroll);
  }

  void updateRouteModal(StudentData item) {
    selectedRouteOption = null;

    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              color: const Color(0XFFE5F4FF),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
                        Flexible(
                          child: Text(
                            '${item.name.toUpperCase()}\t\t\t${item.standard}\t\t${item.section}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close_outlined),
                        ),
                      ],
                    ),
                    const Divider(),

                    RadioGroup(
                      groupValue: selectedRouteOption,
                      onChanged: (val) {
                        setState(() => selectedRouteOption = val);
                      },
                      child: const Column(
                        children: [
                          RadioListTile(
                            value: 'pickup',
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Change pickup',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff1F1D31),
                              ),
                            ),
                            // No groupValue or onChanged here
                          ),
                          RadioListTile(
                            value: 'drop',
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Change Drop',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff1F1D31),
                              ),
                            ),
                            // No groupValue or onChanged here
                          ),
                          RadioListTile(
                            value: 'both',
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Both',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff1F1D31),
                              ),
                            ),
                            // No groupValue or onChanged here
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF2D7FBB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: selectedRouteOption == null
                          ? null
                          : () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => ChangeRouteDialog(
                                  mode: selectedRouteOption == 'drop'
                                      ? Mode.DROP
                                      : Mode.PICKUP,
                                  both: selectedRouteOption == 'both',
                                  student: item,
                                ),
                              );
                            },
                      child: const Text(
                        'SUBMIT',
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
          },
        );
      },
    );
  }

  void _onScroll() {
    final provider = Provider.of<StudentsProvider>(context, listen: false);

    // Check if we're at the end and not already paginating
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isPaginating &&
        provider.hasNextPage) {
      setState(() {
        _isPaginating = true;
        _pageNo++;
      });

      // Call the correct API based on current mode (search or browse)
      if (_searchController.text.isNotEmpty) {
        provider
            .searchStudent(
              context: context,
              search: _searchController.text,
              classId: classId,
              sections: section == null ? null : [section!],
            )
            .whenComplete(() {
              if (mounted) setState(() => _isPaginating = false);
            });
      } else if (classId != null && section != null) {
        provider
            .getStudents(context, classId!, [section!], pageNo: _pageNo)
            .whenComplete(() {
              if (mounted) setState(() => _isPaginating = false);
            });
      } else {
        // Fallback, though should not be reachable if list is visible
        if (mounted) setState(() => _isPaginating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student/Staff Route Change'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
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
                'Systematic adjustment of transportation routes for students, optimizing efficiency, safety, and convenience based on evolving needs and logistical considerations within educational institutions.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        hint: const Text(
                          'Class',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        isExpanded: true,
                        initialValue: classId,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0XFF2D7FBB),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0XFF2D7FBB),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0XFF2D7FBB),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onChanged: (int? newValue) {
                          provider.reset();
                          setState(() {
                            classId = newValue;
                            section = null;
                            _searchController.clear();
                            _pageNo = 1;
                            sections = (newValue == null)
                                ? []
                                : provider.standards
                                      .firstWhere((e) => e.id == newValue)
                                      .sections;
                          });
                        },
                        items: provider.standards.map((data) {
                          return DropdownMenuItem(
                            value: data.id,
                            child: Text(data.name),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(
                        hint: const Text(
                          'Section',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        isExpanded: true,
                        initialValue: section,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0XFF2D7FBB),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0XFF2D7FBB),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0XFF2D7FBB),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onChanged: (String? newValue) {
                          if (newValue == null || classId == null) return;
                          provider.reset();
                          setState(() {
                            section = newValue;
                            _searchController.clear(); // Clear search
                            _pageNo = 1; // Reset page
                          });
                          provider.getStudents(context, classId!, [
                            section!,
                          ], pageNo: _pageNo);
                        },
                        items: sections.map((data) {
                          return DropdownMenuItem(
                            value: data.name,
                            child: Text(data.name),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      provider.reset();
                      setState(() {
                        _pageNo = 1;
                      });

                      if (value.isNotEmpty) {
                        provider.searchStudent(
                          context: context,
                          search: value,
                          classId: classId,
                          sections: section == null ? null : [section!],
                        );
                      } else {
                        // Only fetch students if both classId and section are selected
                        if (classId != null && section != null) {
                          final selectedClassId = classId!;
                          final selectedSection = section!;
                          provider.getStudents(context, selectedClassId, [
                            selectedSection,
                          ], pageNo: _pageNo);
                        } else {
                          // Clear students if filters are not selected
                          provider.reset();
                        }
                      }
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0XFF2D7FBB),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0XFF2D7FBB),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0XFF2D7FBB),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    hintText: 'Search Admission No/Name (Global)',
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),

                // Updated list rendering logic
                if (provider.studentsLoading && _pageNo == 1)
                  const Center(child: CircularProgressIndicator())
                else if (provider.students.isEmpty)
                  NoDataWidget(
                    msg: _searchController.text.isNotEmpty
                        ? 'No students found for "${_searchController.text}"'
                        : (classId == null || section == null
                              ? 'Please select Class and Section or use Search'
                              : 'No Students Found!'),
                  )
                else
                  // Use provider.students directly
                  ListView.separated(
                    primary: false,
                    shrinkWrap: true,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(
                      16,
                    ), // Padding was here, maybe remove if outer has it? Keeping it.
                    itemBuilder: (context, index) {
                      final item = provider.students[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: Image.asset('assets/profile.png'),
                            title: Text(
                              item.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Admission No ${item.admissionNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0XFF4C4A5A),
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                updateRouteModal(item);
                              },
                              icon: const Icon(
                                Icons.edit_document,
                                color: Color(0XFF2D7FBB),
                                size: 30,
                              ),
                            ),
                          ),
                          ...(item.pickPoint == null &&
                                      item.dropPoint == null ||
                                  item.routes.isEmpty
                              ? [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 60),
                                    child: Text(
                                      '⚠️ Non Transport!',
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ]
                              : [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Pickup',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: RichText(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            text: item.routes.isNotEmpty
                                                ? '${item.routes[0]} - '
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: item.pickPoint ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0XFF2D7FBB),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Drop',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: RichText(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            text: item.routes.length == 2
                                                ? '${item.routes[1]} - '
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: item.dropPoint ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0XFF2D7FBB),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: provider.students.length,
                  ),

                // Add the pagination loading indicator at the bottom
                if (_isPaginating)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }
}
