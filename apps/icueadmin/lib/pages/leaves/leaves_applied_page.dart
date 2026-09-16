import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/leave_application.dart';
import '../../providers/leave_provider.dart';
import '../../widgets/no_data_widget.dart';

class LeavesAppliedPage extends StatefulWidget {
  const LeavesAppliedPage({super.key, this.initialStatus});

  final String? initialStatus;

  @override
  State<LeavesAppliedPage> createState() => _LeavesAppliedPageState();
}

class _LeavesAppliedPageState extends State<LeavesAppliedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = const ['Requested', 'Approved', 'Rejected'];

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialStatus != null
        ? _statuses.indexOf(widget.initialStatus!)
        : 0;
    _tabController = TabController(
      length: _statuses.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );

    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialStatus = _statuses[_tabController.index];
      context.read<LeaveProvider>().fetchAppliedLeaves(status: initialStatus);
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final status = _statuses[_tabController.index];
    context.read<LeaveProvider>().setAppliedStatus(status);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF059669);
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'requested':
      default:
        return const Color(0xFFD97706);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFFECFDF5);
      case 'rejected':
        return const Color(0xFFFEF2F2);
      case 'requested':
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'requested':
      default:
        return Icons.schedule_rounded;
    }
  }

  IconData _getCategoryIcon(String leaveType) {
    final type = leaveType.toLowerCase();
    if (type.contains('casual') || type.contains('(cl)')) {
      return Icons.beach_access_rounded;
    } else if (type.contains('sick') || type.contains('medical')) {
      return Icons.medical_services_rounded;
    } else if (type.contains('earned') || type.contains('(el)')) {
      return Icons.verified_rounded;
    } else if (type.contains('maternity')) {
      return Icons.family_restroom_rounded;
    } else if (type.contains('paternity')) {
      return Icons.child_care_rounded;
    } else if (type.contains('bereavement')) {
      return Icons.favorite_border_rounded;
    } else if (type.contains('marriage')) {
      return Icons.celebration_rounded;
    }
    return Icons.event_note_rounded;
  }

  String _formatDateRange(DateTime? from, DateTime? to) {
    if (from == null && to == null) return 'Dates not specified';
    if (from != null && to == null) return _dateFormat.format(from);
    if (from == null && to != null) return _dateFormat.format(to);

    final fromStr = _dateFormat.format(from!);
    final toStr = _dateFormat.format(to!);
    if (fromStr == toStr) return fromStr;
    return '$fromStr – $toStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Leaves Applied'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                final primaryColor = Theme.of(context).primaryColor;
                return TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: _statuses.map((status) {
                    return Consumer<LeaveProvider>(
                      builder: (context, provider, _) {
                        final count = provider.appliedCount(status);
                        final isSelected =
                            _statuses[_tabController.index] == status;
                        return Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(status),
                              if (count > 0) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _getStatusBgColor(status)
                                        : Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? _getStatusColor(status)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
      body: Consumer<LeaveProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: _statuses.map((status) {
              return _buildTabContent(context, provider, status);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    LeaveProvider provider,
    String status,
  ) {
    final list = provider.currentAppliedLeaves
        .where((l) => l.status.toLowerCase() == status.toLowerCase())
        .toList();

    if (provider.loadingApplied && list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading applications...',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    if (provider.errorMessage != null && list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  provider.fetchAppliedLeaves(status: status, refresh: true);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.fetchAppliedLeaves(status: status, refresh: true);
      },
      child: list.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Center(
                  child: NoDataWidget(
                    msg: 'No $status leave applications found.',
                  ),
                ),
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildApplicationCard(context, list[index]);
              },
            ),
    );
  }

  Widget _buildApplicationCard(
    BuildContext context,
    LeaveApplication application,
  ) {
    final statusColor = _getStatusColor(application.status);
    final statusBgColor = _getStatusBgColor(application.status);
    final statusIcon = _getStatusIcon(application.status);
    final categoryIcon = _getCategoryIcon(application.leaveType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category and Status Pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    categoryIcon,
                    size: 22,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              application.leaveType,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  application.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Date range row
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDateRange(
                              application.fromDate,
                              application.toDate,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              application.formattedDuration,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Reason Section
            if (application.reason != null &&
                application.reason!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reason: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      application.reason!.trim(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E293B),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Remarks Section (e.g. approval or rejection remarks)
            if (application.approveOrRejectionRemarks != null &&
                application.approveOrRejectionRemarks!.trim().isNotEmpty &&
                application.approveOrRejectionRemarks!.trim() != '{NULL}') ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusBgColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      application.status.toLowerCase() == 'rejected'
                          ? Icons.info_outline_rounded
                          : Icons.rate_review_outlined,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Remarks: ${application.approveOrRejectionRemarks!.trim()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Applied On Timestamp Footer
            if (application.createdOn != null ||
                application.requestedDate != null) ...[
              const SizedBox(height: 10),
              Text(
                'Applied: ${_dateFormat.format(application.createdOn ?? application.requestedDate!)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
