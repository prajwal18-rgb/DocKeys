import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/role_helper.dart';
import '../admin/admin_home_screen.dart';
import '../admin/admin_tab_screen.dart';
import '../documents/document_provider.dart';
import '../profile/profile_provider.dart';
import 'home_screen.dart';
import '../schemes/scheme_details_screen.dart';
import '../notice_board/notice_board_screen.dart';
import '../documents/documents_screen.dart';
import '../notifications/notifications_screen.dart';
import '../notifications/notification_provider.dart';
import '../profile/profile_screen.dart';
import 'tab_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).loadProfile();
      Provider.of<DocumentProvider>(context, listen: false).loadDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasUnreadNotifications =
        Provider.of<NotificationProvider>(context).unreadCount > 0;
    final tabProvider = Provider.of<TabProvider>(context);

    List<Widget> pages;
    if (RoleHelper.isAdmin) {
      pages = const [
        AdminHomeScreen(),
        AdminTabScreen(),
        NoticeBoardScreen(),
        NotificationsScreen(),
        ProfileScreen(),
      ];
    } else {
      pages = const [
        HomeScreen(),
        SchemesScreen(),
        NoticeBoardScreen(),
        DocumentsScreen(),
        NotificationsScreen(),
        ProfileScreen(),
      ];
    }

    List<BottomNavigationBarItem> navItems;
    if (RoleHelper.isAdmin) {
      navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Publish Scheme',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.campaign),
          label: 'Notice',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications),
              if (hasUnreadNotifications)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Notifications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Schemes',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.campaign),
          label: 'Notice',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          label: 'Documents',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications),
              if (hasUnreadNotifications)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Notifications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    // Clamp current tab index to valid range for current role (admin vs user).
    int currentIndex = tabProvider.index;
    if (currentIndex < 0 || currentIndex >= navItems.length) {
      currentIndex = 0;
      // Update provider after build frame to avoid setState during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tabProvider.setIndex(0);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF2962FF),
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            onTap: tabProvider.setIndex,
            items: navItems,
          ),
        ),
      ),
    );
  }
}
