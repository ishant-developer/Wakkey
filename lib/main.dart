import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/alarm_service.dart';
import 'services/sleep_sound_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark navigation & status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0C1017),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final alarmService = AlarmService();
  await alarmService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AlarmService>.value(value: alarmService),
        ChangeNotifierProvider<SleepSoundService>(create: (_) => SleepSoundService()),
      ],
      child: WakkeyApp(showOnboarding: !hasSeenOnboarding),
    ),
  );
}

class WakkeyApp extends StatelessWidget {
  final bool showOnboarding;

  const WakkeyApp({super.key, this.showOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep If U Can',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
