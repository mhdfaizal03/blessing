import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:blessing/constands/colors.dart';
import 'package:blessing/views/home_screen.dart';
import 'package:blessing/views/more_screen.dart';
import 'package:blessing/views/morning_reminder_screen.dart';
import 'package:blessing/views/qibla_screen.dart';
import 'package:blessing/views/quran_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Map<String, dynamic>> _navItems = const [
    {
      "name": "Home",
      "icon": Icons.home_outlined,
      "activeIcon": Icons.home_rounded,
      "page": DashboardScreen(),
    },
    {
      "name": "Quran",
      "icon": Icons.menu_book_outlined,
      "activeIcon": Icons.menu_book_rounded,
      "page": QuranSection(),
    },
    {
      "name": "Qibla",
      "icon": Icons.explore_outlined,
      "activeIcon": Icons.explore_rounded,
      "page": QiblaScreen(),
    },
    {
      "name": "More",
      "icon": Icons.grid_view_outlined,
      "activeIcon": Icons.grid_view_rounded,
      "page": MoreScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowDailyRemembrance();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutBack, // Bubbly bounce physics!
      );
    }
  }

  void _onPageChanged(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _navItems
            .map((e) => RepaintBoundary(child: e["page"] as Widget))
            .toList(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                child: CompactLiquidNavBar(
                  selectedIndex: _selectedIndex,
                  navItems: _navItems,
                  onTap: _onNavTap,
                  pageController: _pageController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================
// COMPACT LIQUID APPLE-STYLE NAV BAR
// ====================================================
class CompactLiquidNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<Map<String, dynamic>> navItems;
  final Function(int) onTap;
  final PageController pageController;

  const CompactLiquidNavBar({
    super.key,
    required this.selectedIndex,
    required this.navItems,
    required this.onTap,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    const double barHeight = 70.0;
    final double totalBarWidth = MediaQuery.of(context).size.width * 0.900;
    final double itemWidth = (totalBarWidth - 12.0) / navItems.length;

    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double currentPage = selectedIndex.toDouble();
        if (pageController.hasClients &&
            pageController.position.haveDimensions) {
          currentPage = pageController.page ?? selectedIndex.toDouble();
        }

        return Container(
          width: totalBarWidth,
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: colors.kAccentNeon.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.kSecondaryBg.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: colors.kGlassBorder, width: 1.2),
                  ),
                  child: Stack(
                    children: [
                      // Dynamic Liquid Sliding Indicator - smoothly stretches and bounces!
                      Positioned(
                        left:
                            currentPage * itemWidth +
                            6 -
                            (math.sin((currentPage % 1.0) * math.pi) * 10.0),
                        top: 6,
                        child: Container(
                          width:
                              itemWidth +
                              (math.sin((currentPage % 1.0) * math.pi) * 20.0),
                          height: barHeight - 12,
                          decoration: BoxDecoration(
                            color: colors.kAccentNeon.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: colors.kAccentNeon.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.kAccentNeon.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Nav Items & Pan gesture detector for slider effect
                      GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          if (pageController.hasClients) {
                            double screenWidth = MediaQuery.of(
                              context,
                            ).size.width;
                            double multiplier =
                                (screenWidth * navItems.length) / totalBarWidth;
                            double newPixels =
                                pageController.position.pixels +
                                details.primaryDelta! * multiplier;
                            newPixels = newPixels.clamp(
                              0.0,
                              pageController.position.maxScrollExtent,
                            );
                            pageController.position.jumpTo(newPixels);
                          }
                        },
                        onHorizontalDragEnd: (details) {
                          if (pageController.hasClients) {
                            double page = pageController.page ?? 0.0;

                            if (details.primaryVelocity != null) {
                              if (details.primaryVelocity! > 300) {
                                page = (page + 0.5).floorToDouble() + 1;
                              } else if (details.primaryVelocity! < -300) {
                                page = (page - 0.5).ceilToDouble() - 1;
                              }
                            }

                            int targetPage = page.round().clamp(
                              0,
                              navItems.length - 1,
                            );
                            pageController.animateToPage(
                              targetPage,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Row(
                            children: List.generate(navItems.length, (index) {
                              final item = navItems[index];

                              // Dynamically calculate distance from slider for liquid scaling
                              double distance = (currentPage - index).abs();
                              double scale =
                                  0.90 +
                                  (1.12 - 0.90) *
                                      (1 - distance.clamp(0.0, 1.0));

                              Color iconColor = Color.lerp(
                                colors.kAccentNeon,
                                colors.kTextGrey,
                                distance.clamp(0.0, 1.0),
                              )!;

                              bool isClosest = distance < 0.5;

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => onTap(index),
                                  behavior: HitTestBehavior.opaque,
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isClosest
                                              ? (item["activeIcon"] as IconData)
                                              : (item["icon"] as IconData),
                                          size: 22,
                                          color: iconColor,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item["name"].toString(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isClosest
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: iconColor,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
