import 'package:blessing/constands/colors.dart';
import 'package:blessing/views/main_navigation_bar.dart';
import 'package:blessing/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: colors.kPrimaryBg,
        primaryColor: colors.kAccentNeon,
        cardColor: colors.kCardBg,
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: colors.kAccentNeon,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: colors.kTextWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: colors.kTextWhite),
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Blessing',
      home: const MainNavigationWrapper(),
    );
  }
}
