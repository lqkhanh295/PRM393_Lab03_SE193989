import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/explore_viewmodel.dart';
import '../viewmodels/my_tickets_vm.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'home/home_screen.dart';
import 'explore/explore_screen.dart';
import 'tickets/my_tickets_screen.dart';
import 'calendar/calendar_screen.dart';
import 'profile/profile_screen.dart';

/// Main Navigation Destination with Anti-slop Accent Navigation Bar
/// Clean 1px hairline top rule, zero elevation, crisp typography.
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Trigger initial data loads through ViewModels
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeScreenData();
      context.read<ExploreViewModel>().loadExploreData();
      final user = context.read<AuthViewModel>().currentUser;
      if (user != null) {
        context.read<MyTicketsViewModel>().loadUserTickets(user.id);
      }
    });
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    MyTicketsScreen(),
    CampusCalendarScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.hairline, width: 1),
          ),
        ),
        child: NavigationBar(
          elevation: 0,
          backgroundColor: AppTheme.surface,
          selectedIndex: _currentIndex,
          indicatorColor: AppTheme.surfaceSubtle,
          height: 64,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 22),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary, size: 22),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined, size: 22),
              selectedIcon: Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
              label: 'Khám phá',
            ),
            NavigationDestination(
              icon: Icon(Icons.confirmation_number_outlined, size: 22),
              selectedIcon: Icon(Icons.confirmation_number_rounded, color: AppTheme.primary, size: 22),
              label: 'Vé của tôi',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined, size: 20),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 20),
              label: 'Lịch biểu',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, size: 22),
              selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary, size: 22),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}
