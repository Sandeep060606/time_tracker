import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/scan_history_model.dart';
import '../models/scan_result_model.dart';
import '../models/scan_response_model.dart';
import '../providers/history_provider.dart';
import '../routes/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/date_time_utils.dart';
import '../widgets/empty_state.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  Future<void> _pickDate(BuildContext context) async {
    final provider = context.read<HistoryProvider>();
    final selected = await showDatePicker(
      context: context,
      initialDate: provider.filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (selected != null) {
      provider.updateDateFilter(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final items = provider.filteredHistory;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Scan History',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Filter by date',
                  onPressed: () => _pickDate(context),
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Clear filter',
                  onPressed: provider.filterDate == null
                      ? null
                      : () => provider.updateDateFilter(null),
                  icon: const Icon(Icons.filter_alt_off_outlined),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: provider.updateSearch,
              decoration: InputDecoration(
                hintText: 'Search QR, name, or purpose',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: provider.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () => provider.updateSearch(''),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          if (provider.filterDate != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(
                    DateTimeUtils.displayDate.format(provider.filterDate!),
                  ),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.refresh,
              child: items.isEmpty
                  ? const EmptyState(
                      icon: Icons.history_rounded,
                      title: 'No scans found',
                      message:
                          'Pull to refresh or clear filters to view scans.',
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.danger,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) => showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Delete history?'),
                              content: Text(
                                'Remove QR ${item.studentQr} from history.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (_) => provider.delete(item.id),
                          child: _HistoryTile(item: item),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemCount: items.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final ScanHistoryModel item;

  ScanResultModel _resultFromHistory() {
    final responseData = ScanResponseDataModel(
      purpose: item.purpose,
      scannedAt: '',
      empCode: item.employeeCode,
      suc: item.studentQr,
      timestamp: DateTimeUtils.formatForApi(item.time),
      longitude: item.longitude ?? '',
      latitude: item.latitude ?? '',
      id: item.transactionId ?? item.id,
    );

    return ScanResultModel(
      response: ScanResponseModel(
        timestamp: const [],
        topic: 'qrscanner',
        value: ScanValueModel(data: responseData),
      ),
      history: item,
      student: item.student,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = item.status == ScanStatus.success
        ? AppTheme.success
        : AppTheme.danger;
    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.studentDetails,
          arguments: _resultFromHistory(),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            item.status == ScanStatus.success
                ? Icons.check_rounded
                : Icons.close_rounded,
            color: color,
          ),
        ),
        title: Text(
          item.student?.name.isNotEmpty == true
              ? item.student!.name
              : 'QR ${item.studentQr}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${item.purpose} • ${DateTimeUtils.displayDateTime.format(item.time)}',
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.status == ScanStatus.success ? 'Success' : 'Failed',
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(item.studentQr, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
