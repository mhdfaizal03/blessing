import 'package:blessing/constands/colors.dart';
import 'package:blessing/views/more_screen.dart';
import 'package:blessing/views/qibla_screen.dart';
import 'package:blessing/views/quran_section.dart';
import 'package:blessing/views/home_Screen.dart';
import 'package:blessing/views/morning_reminder_screen.dart';
import 'package:flutter/material.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  static int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    // This triggers the Remembrance screen automatically on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRemembranceSheet(context);
    });
  }

  void _showRemembranceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true, // This enables the swipe down to dismiss
      builder: (context) => RemembranceContent(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      backgroundColor: AppColors().kCardBg,
      selectedItemColor: AppColors().kAccentNeon,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Quran"),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Qibla"),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
      ],
    );
  }

  List<Widget> _buildPages() {
    return [DashboardScreen(), QuranSection(), QiblaScreen(), MoreScreen()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPages()[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}
