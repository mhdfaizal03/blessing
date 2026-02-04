import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/prayer_time_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrayerJourneyScreen extends StatefulWidget {
  const PrayerJourneyScreen({super.key});

  @override
  State<PrayerJourneyScreen> createState() => _PrayerJourneyScreenState();
}

class _PrayerJourneyScreenState extends State<PrayerJourneyScreen> {
  final AppColors colors = AppColors();
  final PrayerTimeService _prayerService = PrayerTimeService();
  final LocalStorageService _storageService = LocalStorageService();

  late DateTime _selectedDate;
  late DateTime _displayMonth;

  Map<String, DateTime>? _dayPrayerTimes;
  Map<String, bool> _loggedPrayers = {};
  int _totalPrayers = 0;
  int _streak = 0;
  bool _isLoading = true;
  Map<int, bool> _monthLogStatus = {}; // day -> hasAnyLog

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _displayMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final location = await _storageService.getCachedLocation();
    if (location != null) {
      final pt = await _prayerService.getPrayerTimesForDate(
        location['lat'],
        location['lng'],
        _selectedDate,
      );

      final prayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
      Map<String, bool> logs = {};
      for (var p in prayers) {
        logs[p] = await _storageService.isPrayerLogged(_selectedDate, p);
      }

      final total = await _storageService.getTotalLoggedPrayers();
      final streak = await _storageService.getCurrentStreak();

      // Load month log status for dots
      Map<int, bool> monthStatus = {};
      final daysInMonth = DateTime(
        _displayMonth.year,
        _displayMonth.month + 1,
        0,
      ).day;
      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(_displayMonth.year, _displayMonth.month, i);
        monthStatus[i] = await _storageService.isAnyPrayerLogged(date);
      }

      if (mounted) {
        setState(() {
          _dayPrayerTimes = {
            "Fajr": pt.fajr,
            "Dhuhr": pt.dhuhr,
            "Asr": pt.asr,
            "Maghrib": pt.maghrib,
            "Isha": pt.isha,
          };
          _loggedPrayers = logs;
          _totalPrayers = total;
          _streak = streak;
          _monthLogStatus = monthStatus;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePrayer(String name) async {
    final newStatus = await _storageService.togglePrayerLog(
      _selectedDate,
      name,
    );
    setState(() {
      _loggedPrayers[name] = newStatus;
    });
    // Reload stats
    final total = await _storageService.getTotalLoggedPrayers();
    final streak = await _storageService.getCurrentStreak();
    // Update month dot if it's the first log or last unlog
    final hasAny = await _storageService.isAnyPrayerLogged(_selectedDate);

    setState(() {
      _totalPrayers = total;
      _streak = streak;
      if (_selectedDate.month == _displayMonth.month) {
        _monthLogStatus[_selectedDate.day] = hasAny;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Prayer Journey',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.kTextWhite,
          ),
        ),
        leading: CustomCircleIconButton(
          icon: Icons.keyboard_arrow_left_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colors.kAccentNeon))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildCalendarSection(),
                  const SizedBox(height: 30),
                  _buildStatsRow(),
                  const SizedBox(height: 25),
                  _buildLogButton(),
                  const SizedBox(height: 35),
                  _buildPrayerListHeader(),
                  const SizedBox(height: 20),
                  ..._buildPrayerItems(),
                  const SizedBox(height: 30),
                  _buildQuoteCard(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildPrayerItems() {
    if (_dayPrayerTimes == null)
      return [const Text("Location required for prayer times")];

    final prayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
    final icons = {
      "Fajr": Icons.wb_twilight,
      "Dhuhr": Icons.wb_sunny_outlined,
      "Asr": Icons.wb_sunny,
      "Maghrib": Icons.wb_twilight_rounded,
      "Isha": Icons.nightlight_round,
    };

    return prayers.map((name) {
      final time = _dayPrayerTimes![name]!;
      final isLogged = _loggedPrayers[name] ?? false;
      return GestureDetector(
        onTap: () => _togglePrayer(name),
        child: _buildPrayerItem(
          name,
          DateFormat('h:mm A').format(time),
          icons[name]!,
          isLogged,
        ),
      );
    }).toList();
  }

  Widget _buildCalendarSection() {
    final String monthName = DateFormat('MMMM yyyy').format(_displayMonth);

    // Calculate days for the grid
    final firstDayOfMonth = DateTime(
      _displayMonth.year,
      _displayMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _displayMonth.year,
      _displayMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: colors.kTextGrey),
              onPressed: () {
                setState(() {
                  _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month - 1,
                  );
                });
                _loadData();
              },
            ),
            Text(
              monthName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colors.kTextWhite,
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: colors.kTextGrey),
              onPressed: () {
                setState(() {
                  _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month + 1,
                  );
                });
                _loadData();
              },
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ["S", "M", "T", "W", "T", "F", "S"]
              .map(
                (d) => SizedBox(
                  width: 40,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.kTextGrey.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 42, // 6 weeks to ensure any month fits
          itemBuilder: (context, index) {
            final dayNumber = index - firstWeekday + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final date = DateTime(
              _displayMonth.year,
              _displayMonth.month,
              dayNumber,
            );
            final isSelected =
                DateFormat('yyyy-MM-dd').format(date) ==
                DateFormat('yyyy-MM-dd').format(_selectedDate);
            final isToday =
                DateFormat('yyyy-MM-dd').format(date) ==
                DateFormat('yyyy-MM-dd').format(DateTime.now());

            final completed = _monthLogStatus[dayNumber] ?? false;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedDate = date);
                _loadData();
              },
              child: _dateIcon(
                dayNumber.toString(),
                completed,
                isSelected: isSelected,
                isToday: isToday,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _dateIcon(
    String day,
    bool completed, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: isSelected
                ? colors.kAccentNeon
                : (isToday ? colors.kAccentDark : Colors.transparent),
            shape: BoxShape.circle,
            border: isToday && !isSelected
                ? Border.all(
                    color: colors.kAccentNeon.withOpacity(0.5),
                    width: 1,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(
              color: isSelected
                  ? colors.kPrimaryBg
                  : (isToday
                        ? colors.kAccentNeon
                        : colors.kTextWhite.withOpacity(0.8)),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 2),
        if (completed && !isSelected)
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: colors.kAccentNeon,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard(
          "Current Streak",
          "$_streak Days",
          _streak > 0 ? "Keep it up!" : "Start your journey",
          Icons.local_fire_department,
          colors.kAccentNeon.withOpacity(0.8),
        ),
        const SizedBox(width: 15),
        _statCard(
          "Total Prayers",
          "$_totalPrayers",
          "Consistent Growth",
          Icons.auto_awesome,
          colors.kAccentNeon.withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String val,
    String sub,
    IconData icon,
    Color iconCol,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.kSecondaryBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.kGlassBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconCol, size: 16),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(color: colors.kTextGrey, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              val,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.kTextWhite,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(color: colors.kAccentNeon, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.add_circle_outline, color: colors.kPrimaryBg),
        label: Text(
          "Log Missing Prayer",
          style: TextStyle(
            color: colors.kPrimaryBg,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.kAccentNeon,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerListHeader() {
    int count = _loggedPrayers.values.where((v) => v).length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('E, MMM dd').format(_selectedDate) ==
                  DateFormat('E, MMM dd').format(DateTime.now())
              ? "Today's Prayers"
              : DateFormat('MMM dd').format(_selectedDate),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.kTextWhite,
          ),
        ),
        Text(
          "$count of 5 Complete",
          style: TextStyle(
            color: colors.kAccentNeon,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerItem(
    String name,
    String time,
    IconData icon,
    bool isComplete,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.kSecondaryBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.kGlassBorder, width: 1),
            ),
            child: Icon(
              icon,
              color: isComplete ? colors.kAccentNeon : colors.kTextGrey,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.kTextWhite,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isComplete ? "$time • On Time" : "$time • Upcoming",
                style: TextStyle(color: colors.kTextGrey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isComplete
                ? colors.kAccentNeon
                : colors.kTextGrey.withOpacity(0.3),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.kSecondaryBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.kAccentNeon.withOpacity(0.1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.kAccentNeon.withOpacity(0.05), colors.kSecondaryBg],
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: colors.kAccentNeon.withOpacity(0.3),
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            "\"The most beloved of deeds to Allah are those that are most consistent, even if they are small.\"",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.kTextWhite.withOpacity(0.7),
              fontStyle: FontStyle.italic,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "— SAHIH BUKHARI",
            style: TextStyle(
              color: colors.kAccentNeon,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
