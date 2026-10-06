import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_model.dart';

class AlarmService extends ChangeNotifier {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  List<AlarmModel> _alarms = [];
  List<AlarmModel> get alarms => List.unmodifiable(_alarms);

  AlarmModel? _ringingAlarm;
  AlarmModel? get ringingAlarm => _ringingAlarm;
  bool get isRinging => _ringingAlarm != null;

  // Wake-up check state
  AlarmModel? _activeWakeUpCheckAlarm;
  AlarmModel? get activeWakeUpCheckAlarm => _activeWakeUpCheckAlarm;
  DateTime? _wakeUpCheckDeadline;
  DateTime? get wakeUpCheckDeadline => _wakeUpCheckDeadline;
  Timer? _wakeUpCheckTimer;
  Timer? _vibrationTimer;

  // Stream controllers to navigate to ringing screen
  final StreamController<AlarmModel> _alarmTriggerStream =
      StreamController<AlarmModel>.broadcast();
  Stream<AlarmModel> get onAlarmTrigger => _alarmTriggerStream.stream;

  final StreamController<AlarmModel> _wakeUpCheckTriggerStream =
      StreamController<AlarmModel>.broadcast();
  Stream<AlarmModel> get onWakeUpCheckTrigger => _wakeUpCheckTriggerStream.stream;

  int _getNumericId(String id) {
    final hash = id.hashCode & 0x7FFFFFFF;
    return (hash % 2000000000) + 1;
  }

  int _getWakeUpCheckNumericId(String id) {
    final hash = '${id}_wakeup_check'.hashCode & 0x7FFFFFFF;
    return (hash % 2000000000) + 1;
  }

  DateTime calculateNextRingTime(int hour, int minute, List<int> repeatDays) {
    final now = DateTime.now();
    if (repeatDays.isEmpty) {
      var candidate = DateTime(now.year, now.month, now.day, hour, minute);
      if (candidate.isBefore(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return candidate;
    } else {
      for (int offset = 0; offset <= 7; offset++) {
        final day = now.add(Duration(days: offset));
        if (repeatDays.contains(day.weekday)) {
          final candidate = DateTime(day.year, day.month, day.day, hour, minute);
          if (candidate.isAfter(now)) {
            return candidate;
          }
        }
      }
      return DateTime(now.year, now.month, now.day + 1, hour, minute);
    }
  }

  Future<void> initialize() async {
    // 1. Initialize native Android alarm engine
    try {
      await Alarm.init();
    } catch (e) {
      debugPrint('Alarm.init error: $e');
    }

    // 2. Load persisted alarms
    await _loadAlarms();

    // 3. Listen to native ringing alarms (triggered from background or lockscreen)
    Alarm.ringing.listen((alarmSet) {
      for (final alarmSettings in alarmSet.alarms) {
        _handleNativeAlarmRang(alarmSettings);
      }
    });

    // Reschedule all enabled alarms with native AlarmManager
    await _scheduleAllEnabledAlarms();
  }

  void _handleNativeAlarmRang(AlarmSettings alarmSettings) {
    // Find matching alarm model
    AlarmModel? matchedAlarm;
    bool isWakeUpCheck = false;

    for (final a in _alarms) {
      if (_getNumericId(a.id) == alarmSettings.id) {
        matchedAlarm = a;
        break;
      }
      if (_getWakeUpCheckNumericId(a.id) == alarmSettings.id) {
        matchedAlarm = a;
        isWakeUpCheck = true;
        break;
      }
    }

    if (matchedAlarm != null) {
      if (isWakeUpCheck) {
        _activeWakeUpCheckAlarm = matchedAlarm;
        _wakeUpCheckTriggerStream.add(matchedAlarm);
        notifyListeners();
      } else {
        _ringingAlarm = matchedAlarm;
        _alarmTriggerStream.add(matchedAlarm);
        notifyListeners();
      }
    }
  }

  Future<void> _scheduleAllEnabledAlarms() async {
    for (final alarm in _alarms) {
      if (alarm.isEnabled) {
        await _scheduleNativeAlarm(alarm);
      } else {
        await Alarm.stop(_getNumericId(alarm.id));
      }
    }
  }

  Future<void> _scheduleNativeAlarm(AlarmModel alarm) async {
    final nextTime = calculateNextRingTime(alarm.hour, alarm.minute, alarm.repeatDays);
    final numericId = _getNumericId(alarm.id);

    final volumeSettings = alarm.gentleWake
        ? VolumeSettings.fade(
            fadeDuration: Duration(minutes: alarm.gentleWakeMinutes),
            volume: alarm.volume,
            volumeEnforced: true,
          )
        : VolumeSettings.fixed(
            volume: alarm.volume,
            volumeEnforced: true,
          );

    final alarmSettings = AlarmSettings(
      id: numericId,
      dateTime: nextTime,
      assetAudioPath: alarm.soundPath,
      loopAudio: true,
      vibrate: alarm.vibrate,
      volumeSettings: volumeSettings,
      notificationSettings: NotificationSettings(
        title: alarm.label,
        body: 'Tap to complete mission: ${alarm.missionName}',
        stopButton: null, // Forces completing mission inside app
      ),
      androidFullScreenIntent: true,
      androidAlarmClock: true,
      warningNotificationOnKill: true,
    );

    try {
      await Alarm.set(alarmSettings: alarmSettings);
      debugPrint('Scheduled native alarm $numericId at $nextTime');
    } catch (e) {
      debugPrint('Error scheduling native alarm: $e');
    }
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getStringList('saved_alarms');
    if (alarmsJson != null && alarmsJson.isNotEmpty) {
      _alarms = alarmsJson.map((e) => AlarmModel.fromJson(e)).toList();
    } else {
      // Default initial alarm
      _alarms = [
        AlarmModel(
          id: 'default_1',
          hour: 6,
          minute: 0,
          repeatDays: [1, 2, 3, 4, 5],
          label: 'Standard Alarm',
          missionType: MissionType.math,
          missionDifficulty: MissionDifficulty.normal,
          missionCount: 3,
          isEnabled: true,
          soundPath: 'assets/audio/loud_siren.wav',
          soundTitle: 'Loud Piercing Siren',
          wakeUpCheck: true,
          wakeUpCheckMinutes: 5,
        ),
        AlarmModel(
          id: 'default_2',
          hour: 7,
          minute: 30,
          repeatDays: [6, 7],
          label: 'Standard Alarm',
          missionType: MissionType.photo,
          isEnabled: false,
          soundPath: 'assets/audio/digital_beep.wav',
          soundTitle: 'Classic Digital Beeps',
          wakeUpCheck: true,
          wakeUpCheckMinutes: 5,
        ),
        AlarmModel(
          id: 'default_3',
          hour: 8,
          minute: 0,
          repeatDays: [1, 2, 3, 4, 5],
          label: 'Gym Alarm',
          missionType: MissionType.step,
          missionCount: 15,
          isEnabled: false,
          soundPath: 'assets/audio/military_alarm.wav',
          soundTitle: 'Military Horn Alarm',
          wakeUpCheck: true,
          wakeUpCheckMinutes: 5,
        ),
      ];
      await _saveAlarms();
    }
    notifyListeners();
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = _alarms.map((e) => e.toJson()).toList();
    await prefs.setStringList('saved_alarms', alarmsJson);
  }

  /// Trigger alarm immediately (used for instant test buttons)
  Future<void> triggerAlarm(AlarmModel alarm) async {
    _ringingAlarm = alarm;
    notifyListeners();
    _alarmTriggerStream.add(alarm);

    // Schedule 1 second in the future so native engine rings with lockscreen wakeup
    final numericId = _getNumericId(alarm.id);
    final alarmSettings = AlarmSettings(
      id: numericId,
      dateTime: DateTime.now().add(const Duration(seconds: 1)),
      assetAudioPath: alarm.soundPath,
      loopAudio: true,
      vibrate: alarm.vibrate,
      volumeSettings: VolumeSettings.fixed(volume: alarm.volume, volumeEnforced: true),
      notificationSettings: NotificationSettings(
        title: alarm.label,
        body: 'Tap to start mission: ${alarm.missionName}',
      ),
      androidFullScreenIntent: true,
      androidAlarmClock: true,
    );

    try {
      await Alarm.set(alarmSettings: alarmSettings);
    } catch (e) {
      debugPrint('Trigger test alarm error: $e');
    }
  }

  /// Dismiss alarm (called after completing mission)
  Future<void> dismissAlarm() async {
    if (_ringingAlarm == null) return;
    final finishedAlarm = _ringingAlarm!;
    final numericId = _getNumericId(finishedAlarm.id);

    try {
      await Alarm.stop(numericId);
    } catch (e) {
      debugPrint('Error stopping alarm: $e');
    }

    _vibrationTimer?.cancel();
    _ringingAlarm = null;

    // Reset snooze count
    finishedAlarm.currentSnoozeCount = 0;

    // If one-time alarm, disable it. Otherwise reschedule next occurrence!
    if (finishedAlarm.repeatDays.isEmpty) {
      finishedAlarm.isEnabled = false;
      await updateAlarm(finishedAlarm);
    } else {
      await _scheduleNativeAlarm(finishedAlarm);
    }

    notifyListeners();

    // Trigger Wake-Up Check if enabled!
    if (finishedAlarm.wakeUpCheck) {
      _scheduleWakeUpCheck(finishedAlarm);
    }
  }

  /// Snooze current ringing alarm
  Future<bool> snoozeAlarm() async {
    if (_ringingAlarm == null) return false;
    final alarm = _ringingAlarm!;

    if (!alarm.snoozeEnabled) return false;
    if (alarm.maxSnoozeCount != 999 &&
        alarm.currentSnoozeCount >= alarm.maxSnoozeCount) {
      return false; // Snooze limit exceeded!
    }

    final numericId = _getNumericId(alarm.id);
    await Alarm.stop(numericId);

    alarm.currentSnoozeCount++;
    _ringingAlarm = null;
    notifyListeners();

    // Reschedule native alarm in snooze duration
    final snoozeTime = DateTime.now().add(Duration(minutes: alarm.snoozeDurationMinutes));
    final snoozeSettings = AlarmSettings(
      id: numericId,
      dateTime: snoozeTime,
      assetAudioPath: alarm.soundPath,
      loopAudio: true,
      vibrate: alarm.vibrate,
      volumeSettings: VolumeSettings.fixed(volume: alarm.volume, volumeEnforced: true),
      notificationSettings: NotificationSettings(
        title: '${alarm.label} (Snoozed)',
        body: 'Snooze finished! Complete mission now.',
      ),
      androidFullScreenIntent: true,
      androidAlarmClock: true,
    );

    await Alarm.set(alarmSettings: snoozeSettings);
    return true;
  }

  /// Schedule Wake-Up Check (Anti-Sleep Guard)
  void _scheduleWakeUpCheck(AlarmModel alarm) async {
    _wakeUpCheckTimer?.cancel();
    _activeWakeUpCheckAlarm = alarm;
    _wakeUpCheckDeadline =
        DateTime.now().add(Duration(minutes: alarm.wakeUpCheckMinutes));
    notifyListeners();

    // Schedule native alarm for wake-up check deadline so it rings even if phone is locked!
    final checkId = _getWakeUpCheckNumericId(alarm.id);
    final checkSettings = AlarmSettings(
      id: checkId,
      dateTime: _wakeUpCheckDeadline!,
      assetAudioPath: alarm.soundPath,
      loopAudio: true,
      vibrate: true,
      volumeSettings: const VolumeSettings.fixed(volume: 1.0, volumeEnforced: true),
      notificationSettings: NotificationSettings(
        title: 'Wake-Up Check Failed!',
        body: 'You did not confirm you were awake! Wake up now!',
      ),
      androidFullScreenIntent: true,
      androidAlarmClock: true,
    );

    try {
      await Alarm.set(alarmSettings: checkSettings);
    } catch (e) {
      debugPrint('Error scheduling native wake-up check: $e');
    }

    _wakeUpCheckTimer = Timer(Duration(minutes: alarm.wakeUpCheckMinutes), () {
      if (_activeWakeUpCheckAlarm != null) {
        _wakeUpCheckTriggerStream.add(_activeWakeUpCheckAlarm!);
      }
    });
  }

  /// User confirmed wake-up check: "I am awake!"
  Future<void> confirmWakeUpCheck() async {
    if (_activeWakeUpCheckAlarm != null) {
      final checkId = _getWakeUpCheckNumericId(_activeWakeUpCheckAlarm!.id);
      await Alarm.stop(checkId);
    }
    _wakeUpCheckTimer?.cancel();
    _activeWakeUpCheckAlarm = null;
    _wakeUpCheckDeadline = null;
    notifyListeners();
  }

  // Alarm CRUD Operations
  Future<void> addAlarm(AlarmModel alarm) async {
    _alarms.add(alarm);
    _alarms.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    await _saveAlarms();
    if (alarm.isEnabled) {
      await _scheduleNativeAlarm(alarm);
    }
    notifyListeners();
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      _alarms[index] = alarm;
      _alarms.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      await _saveAlarms();
      if (alarm.isEnabled) {
        await _scheduleNativeAlarm(alarm);
      } else {
        await Alarm.stop(_getNumericId(alarm.id));
      }
      notifyListeners();
    }
  }

  Future<void> toggleAlarm(String id, bool isEnabled) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alarms[index].isEnabled = isEnabled;
      await _saveAlarms();
      if (isEnabled) {
        await _scheduleNativeAlarm(_alarms[index]);
      } else {
        await Alarm.stop(_getNumericId(id));
      }
      notifyListeners();
    }
  }

  Future<void> deleteAlarm(String id) async {
    await Alarm.stop(_getNumericId(id));
    await Alarm.stop(_getWakeUpCheckNumericId(id));
    _alarms.removeWhere((a) => a.id == id);
    await _saveAlarms();
    notifyListeners();
  }

  /// Calculate time remaining until next enabled alarm
  Duration? getTimeUntilNextAlarm() {
    if (_alarms.isEmpty) return null;
    final enabledAlarms = _alarms.where((a) => a.isEnabled).toList();
    if (enabledAlarms.isEmpty) return null;

    final now = DateTime.now();
    Duration? minDiff;

    for (final alarm in enabledAlarms) {
      final nextTime = calculateNextRingTime(alarm.hour, alarm.minute, alarm.repeatDays);
      final diff = nextTime.difference(now);
      if (minDiff == null || diff < minDiff) {
        minDiff = diff;
      }
    }
    return minDiff;
  }

  @override
  void dispose() {
    _wakeUpCheckTimer?.cancel();
    _vibrationTimer?.cancel();
    _alarmTriggerStream.close();
    _wakeUpCheckTriggerStream.close();
    super.dispose();
  }
}
