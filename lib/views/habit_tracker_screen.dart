import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:flutter/material.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final AppColors _colors = AppColors();
  final LocalStorageService _storageService = LocalStorageService();

  bool _isLoading = true;

  final List<Map<String, dynamic>> _habits = [
    {
      'id': 'prayers_5',
      'title': 'Pray 5 Daily Prayers',
      'subtitle': 'Fajr, Dhuhr, Asr, Maghrib, Isha',
      'icon': Icons.mosque_rounded,
      'completed': false,
    },
    {
      'id': 'morning_adhkar',
      'title': 'Morning Adhkar',
      'subtitle': 'Recite after Fajr prayer',
      'icon': Icons.wb_sunny_rounded,
      'completed': false,
    },
    {
      'id': 'evening_adhkar',
      'title': 'Evening Adhkar',
      'subtitle': 'Recite after Asr or Maghrib',
      'icon': Icons.nightlight_round,
      'completed': false,
    },
    {
      'id': 'quran_reading',
      'title': 'Read Quran (15 Mins)',
      'subtitle': 'Build daily connection with Allah\'s words',
      'icon': Icons.menu_book_rounded,
      'completed': false,
    },
    {
      'id': 'tahajjud',
      'title': 'Tahajjud Prayer',
      'subtitle': 'Voluntary night prayer in last third of night',
      'icon': Icons.bedtime_rounded,
      'completed': false,
    },
    {
      'id': 'duha_prayer',
      'title': 'Duha (Forenoon) Prayer',
      'subtitle': '2 to 8 rak\'ahs before Dhuhr',
      'icon': Icons.wb_twilight_rounded,
      'completed': false,
    },
    {
      'id': 'surah_mulk',
      'title': 'Recite Surah Al-Mulk',
      'subtitle': 'Protection from punishment of the grave',
      'icon': Icons.auto_stories_rounded,
      'completed': false,
    },
    {
      'id': 'daily_sadaqah',
      'title': 'Daily Sadaqah / Good Deed',
      'subtitle': 'Smile, help someone, or give charity',
      'icon': Icons.favorite_rounded,
      'completed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    try {
      final savedStates = await _storageService.getHabitsState();
      for (var habit in _habits) {
        final id = habit['id'] as String;
        if (savedStates.containsKey(id)) {
          habit['completed'] = savedStates[id] ?? false;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Load habits error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleHabit(int index) async {
    setState(() {
      _habits[index]['completed'] = !(_habits[index]['completed'] as bool);
    });

    final habitsMap = <String, bool>{};
    for (var h in _habits) {
      habitsMap[h['id'] as String] = h['completed'] as bool;
    }
    await _storageService.saveHabitsState(habitsMap);
  }

  double get _completionPercentage {
    if (_habits.isEmpty) return 0.0;
    final completedCount = _habits.where((h) => h['completed'] == true).length;
    return completedCount / _habits.length;
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _habits.where((h) => h['completed'] == true).length;

    return Scaffold(
      backgroundColor: _colors.kPrimaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CustomCircleIconButton(
          icon: Icons.keyboard_arrow_left_rounded,
          onTap: () => Navigator.pop(context),
        ),
        title: Text(
          'Sunnah Habit Tracker',
          style: TextStyle(
            color: _colors.kTextWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          CustomCircleIconButton(
            icon: Icons.restart_alt_rounded,
            onTap: () => _confirmResetDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: _colors.kAccentNeon),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Progress Overview Ring Card
                    _buildOverviewCard(completedCount),

                    const SizedBox(height: 24),

                    // Habit Checklist Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "DAILY HABITS",
                          style: TextStyle(
                            color: _colors.kTextGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          "$completedCount of ${_habits.length} Done",
                          style: TextStyle(
                            color: _colors.kAccentNeon,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Habit Tiles
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        final habit = _habits[index];
                        final isDone = habit['completed'] as bool;

                        return GestureDetector(
                          onTap: () => _toggleHabit(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? _colors.kAccentNeon.withValues(alpha: 0.1)
                                  : _colors.kSecondaryBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDone
                                    ? _colors.kAccentNeon
                                    : _colors.kGlassBorder,
                                width: isDone ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? _colors.kAccentNeon
                                        : _colors.kAccentNeon.withValues(
                                            alpha: 0.15,
                                          ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    habit['icon'] as IconData,
                                    color: isDone
                                        ? _colors.kPrimaryBg
                                        : _colors.kAccentNeon,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habit['title'] as String,
                                        style: TextStyle(
                                          color: _colors.kTextWhite,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          decoration: isDone
                                              ? TextDecoration.lineThrough
                                              : null,
                                          decorationColor: _colors.kAccentNeon,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        habit['subtitle'] as String,
                                        style: TextStyle(
                                          color: _colors.kTextGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? _colors.kAccentNeon
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDone
                                          ? _colors.kAccentNeon
                                          : Colors.white38,
                                      width: 2,
                                    ),
                                  ),
                                  child: isDone
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: _colors.kPrimaryBg,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOverviewCard(int completedCount) {
    final percentageInt = (_completionPercentage * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _colors.kSecondaryBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _colors.kGlassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _completionPercentage,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  color: _colors.kAccentNeon,
                ),
                Text(
                  "$percentageInt%",
                  style: TextStyle(
                    color: _colors.kAccentNeon,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Progress",
                  style: TextStyle(
                    color: _colors.kTextWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$completedCount of ${_habits.length} Sunnah habits completed today",
                  style: TextStyle(color: _colors.kTextGrey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _colors.kSecondaryBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Reset Today's Habits?",
          style: TextStyle(
            color: _colors.kTextWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "This will uncheck all completed habits for today.",
          style: TextStyle(color: _colors.kTextGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: _colors.kTextGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
                for (var h in _habits) {
                  h['completed'] = false;
                }
              });
              await _storageService.saveHabitsState({});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _colors.kAccentNeon,
              foregroundColor: _colors.kPrimaryBg,
            ),
            child: const Text(
              "Reset",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
