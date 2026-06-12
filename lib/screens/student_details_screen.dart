import 'package:flutter/material.dart';

import '../models/scan_result_model.dart';
import '../utils/app_theme.dart';
import '../utils/date_time_utils.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/info_row.dart';

class StudentDetailsScreen extends StatelessWidget {
  const StudentDetailsScreen({super.key, required this.result});

  final ScanResultModel result;

  @override
  Widget build(BuildContext context) {
    final student = result.student;
    final history = result.history;
    final title = student?.name.isNotEmpty == true
        ? student!.name
        : 'Student QR ${history.studentQr}';

    return Scaffold(
      appBar: const GradientAppBar(title: 'Student Details'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 104,
                          height: 126,
                          child: student?.studentId.isNotEmpty == true
                              ? Image.network(
                                  student!.photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const _PhotoPlaceholder(),
                                )
                              : const _PhotoPlaceholder(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Chip(
                              avatar: const Icon(Icons.qr_code_2, size: 18),
                              label: Text('#SUC: ${history.studentQr}'),
                              backgroundColor: AppTheme.primary.withValues(
                                alpha: 0.08,
                              ),
                              labelStyle: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            if (student != null) ...[
                              Text('Class: ${student.className}'),
                              Text('Section: ${student.section}'),
                              Text('Roll No: ${student.rollNo}'),
                            ] else
                              const Text('Student transport record not found.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _TransportChip(
                        icon: Icons.directions_bus_filled_outlined,
                        label: student?.hasBus == true ? 'Bus' : 'No Bus',
                        color: student?.hasBus == true
                            ? AppTheme.accent
                            : AppTheme.danger,
                      ),
                      if (student?.hasHostel == true)
                        const _TransportChip(
                          icon: Icons.apartment_outlined,
                          label: 'Hostel',
                          color: AppTheme.primary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.success,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Scan Successful',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.success,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.person_pin_outlined,
                    label: 'Student ID',
                    value: student?.studentId ?? '-',
                  ),
                  InfoRow(
                    icon: Icons.qr_code_rounded,
                    label: 'QR Value',
                    value: history.studentQr,
                  ),
                  InfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Purpose',
                    value: history.purpose,
                  ),
                  InfoRow(
                    icon: Icons.access_time_outlined,
                    label: 'Scan Time',
                    value: DateTimeUtils.displayDateTime.format(history.time),
                  ),
                  InfoRow(
                    icon: Icons.my_location_outlined,
                    label: 'Latitude',
                    value: history.latitude ?? '-',
                  ),
                  InfoRow(
                    icon: Icons.explore_outlined,
                    label: 'Longitude',
                    value: history.longitude ?? '-',
                  ),
                  InfoRow(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transaction ID',
                    value: history.transactionId ?? '-',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.dashboard_outlined),
            label: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFF4FF),
      child: const Icon(Icons.person_rounded, size: 56, color: Colors.black38),
    );
  }
}

class _TransportChip extends StatelessWidget {
  const _TransportChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
