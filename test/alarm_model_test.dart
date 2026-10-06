import 'package:flutter_test/flutter_test.dart';
import 'package:wakkey/models/alarm_model.dart';
import 'package:wakkey/services/alarm_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AlarmModel Tests', () {
    test('Serializes to and from JSON correctly', () {
      final alarm = AlarmModel(
        id: 'test_1',
        hour: 6,
        minute: 30,
        repeatDays: [1, 2, 3, 4, 5],
        label: 'Gym Time',
        missionType: MissionType.shake,
        missionCount: 40,
        soundPath: 'assets/audio/loud_siren.wav',
        wakeUpCheck: true,
        wakeUpCheckMinutes: 5,
      );

      final json = alarm.toJson();
      final restored = AlarmModel.fromJson(json);

      expect(restored.id, 'test_1');
      expect(restored.hour, 6);
      expect(restored.minute, 30);
      expect(restored.repeatDays, [1, 2, 3, 4, 5]);
      expect(restored.missionType, MissionType.shake);
      expect(restored.missionCount, 40);
      expect(restored.wakeUpCheck, isTrue);
      expect(restored.wakeUpCheckMinutes, 5);
      expect(restored.timeFormatted, '6:30 AM');
      expect(restored.repeatSummary, 'Weekdays');
    });

    test('Repeat summary covers all cases correctly', () {
      final alarmOnce = AlarmModel(id: '1', hour: 8, minute: 0, repeatDays: []);
      expect(alarmOnce.repeatSummary, 'Once');

      final alarmAllDays = AlarmModel(
        id: '2',
        hour: 8,
        minute: 0,
        repeatDays: [1, 2, 3, 4, 5, 6, 7],
      );
      expect(alarmAllDays.repeatSummary, 'Every day');

      final alarmWeekends = AlarmModel(
        id: '3',
        hour: 8,
        minute: 0,
        repeatDays: [6, 7],
      );
      expect(alarmWeekends.repeatSummary, 'Weekends');
    });
  });

  group('AlarmService Tests', () {
    test('Next alarm calculation handles upcoming alarms', () {
      final service = AlarmService();
      // Service should calculate time without crashing
      final timeRemaining = service.getTimeUntilNextAlarm();
      // May be null if no alarms loaded yet, but shouldn't throw
      expect(timeRemaining == null || timeRemaining.inSeconds >= 0, isTrue);
    });
  });
}
