import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/purpose_model.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import '../providers/scanner_provider.dart';
import '../routes/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/date_time_utils.dart';
import '../widgets/analytics_card.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_gradient_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employee = context.watch<AuthProvider>().employee;
    final history = context.watch<HistoryProvider>();
    final PurposeModel? selectedPurpose = context
        .watch<ScannerProvider>()
        .selectedPurpose;
    final width = MediaQuery.sizeOf(context).width;

    double cardAspectRatio;

    if (width < 360) {
      cardAspectRatio = 1.05; // very small phones
    } else if (width < 460) {
      cardAspectRatio = 1.15; // small phones
    } else if (width < 768) {
      cardAspectRatio = 1.30; // normal phones
    } else {
      cardAspectRatio = 1.45; // tablets/web
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryDark,
                  AppTheme.primary,
                  AppTheme.accent,
                ],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(compact: true),
                  const SizedBox(height: 26),

                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _HeaderChip(
                        icon: Icons.badge_outlined,
                        label: employee?.paycode ?? '-',
                      ),
                      _HeaderChip(
                        icon: Icons.stars_outlined,
                        label: 'Purpose: ${selectedPurpose?.purpose ?? "-"}',
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.selectPurpose),
                      ),
                      if (context.watch<ScannerProvider>().campusCodeInput !=
                          null)
                        _HeaderChip(
                          icon: Icons.location_city_outlined,
                          label: context
                              .watch<ScannerProvider>()
                              .campusCodeInput!,
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.selectPurpose),
                        ),
                      _HeaderChip(
                        icon: Icons.calendar_today_outlined,
                        label: DateTimeUtils.displayDate.format(_now),
                      ),
                      _HeaderChip(
                        icon: Icons.schedule_outlined,
                        label: DateTimeUtils.displayTime.format(_now),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              childAspectRatio: cardAspectRatio,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildListDelegate([
              AnalyticsCard(
                title: 'Total Scans Today',
                value: history.totalToday.toString(),
                icon: Icons.qr_code_2_rounded,
                color: AppTheme.primary,
              ),
              AnalyticsCard(
                title: 'Successful Scans',
                value: history.successfulToday.toString(),
                icon: Icons.verified_rounded,
                color: AppTheme.success,
              ),
            ]),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 188,
                      height: 188,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.16),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 96,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    PrimaryGradientButton(
                      label: 'Open QR Scanner',
                      icon: Icons.camera_alt_rounded,
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.scanner),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            const Icon(Icons.edit_rounded, size: 14, color: Colors.white70),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: content,
      );
    }
    return content;
  }
}
