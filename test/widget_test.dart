import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wakkey/main.dart';
import 'package:wakkey/services/alarm_service.dart';
import 'package:wakkey/services/sleep_sound_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final alarmService = AlarmService();
    final sleepService = SleepSoundService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AlarmService>.value(value: alarmService),
          ChangeNotifierProvider<SleepSoundService>.value(value: sleepService),
        ],
        child: const WakkeyApp(),
      ),
    );

    expect(find.text('Alarms'), findsOneWidget);
  });
}
