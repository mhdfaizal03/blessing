import 'dart:ui';

import 'package:blessing/constands/colors.dart';
import 'package:blessing/views/home_screen.dart';
import 'package:blessing/views/more_screen.dart';
import 'package:blessing/views/morning_reminder_screen.dart';
import 'package:blessing/views/qibla_screen.dart';
import 'package:blessing/views/quran_section.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;
  final AppColors _colors = AppColors();

  final List<Widget> _pages = const [
    DashboardScreen(),
    QuranSection(),
    QiblaScreen(),
    MoreScreen(),
  ];

  final List<NavItemData> _navItems = const [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: "Home",
    ),
    NavItemData(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: "Quran",
    ),
    NavItemData(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: "Qibla",
    ),
    NavItemData(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: "More",
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowDailyRemembrance();
    });
  }

  Future<void> _checkAndShowDailyRemembrance() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final lastShown = prefs.getString('last_remembrance_shown_date');

    if (lastShown != todayStr) {
      await prefs.setString('last_remembrance_shown_date', todayStr);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        builder: (context) => const RemembranceContent(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBubblyFloatingNav(),
    );
  }

  Widget _buildBubblyFloatingNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _colors.kSecondaryBg.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: _colors.kGlassBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: _colors.kAccentNeon.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_navItems.length, (index) {
                  final isSelected = _selectedIndex == index;
                  final item = _navItems[index];

                  return GestureDetector(
                    onTap: () {
                      if (_selectedIndex != index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedScale(
                      scale: isSelected ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 18 : 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _colors.kAccentNeon.withValues(alpha: 0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          border: isSelected
                              ? Border.all(
                                  color: _colors.kAccentNeon.withValues(alpha: 0.5),
                                  width: 1.2,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _colors.kAccentNeon.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  color: isSelected
                                      ? _colors.kAccentNeon
                                      : _colors.kTextGrey,
                                  size: 24,
                                ),
                                if (isSelected)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _colors.kAccentNeon,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _colors.kAccentNeon,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: _colors.kAccentNeon,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
