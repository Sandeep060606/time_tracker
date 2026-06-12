import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'scan_history_screen.dart';

class HomeShellScreen extends StatelessWidget {
  const HomeShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationProvider>();

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF5F9FF),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
          ),
        ),
        child: IndexedStack(
          index: navigation.index,
          children: const [
            DashboardScreen(),
            ScanHistoryScreen(),
            ProfileScreen(),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: NavigationBar(
            height: 75,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            selectedIndex: navigation.index,
            onDestinationSelected: navigation.setIndex,
            indicatorColor: const Color(0xFF2196F3).withOpacity(0.20),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
                selectedIcon: Icon(
                  Icons.dashboard_rounded,
                  color: Color(0xFF1565C0),
                ),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined, color: Colors.grey),
                selectedIcon: Icon(
                  Icons.history_rounded,
                  color: Color(0xFF1565C0),
                ),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: Colors.grey),
                selectedIcon: Icon(
                  Icons.person_rounded,
                  color: Color(0xFF1565C0),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
