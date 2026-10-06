import 'dart:convert';

enum MissionType {
  none,
  math,
  shake,
  barcode,
  memory,
  typing,
  step,
  photo,
  voice,
}

enum MissionDifficulty {
  easy,
  normal,
  hard,
  genius,
}

class AlarmModel {
  final String id;
  int hour;
  int minute;
  List<int> repeatDays; // 1 = Monday, 7 = Sunday. Empty = once.
  bool isEnabled;
  String label;
  
  // Mission configuration
  MissionType missionType;
  MissionDifficulty missionDifficulty;
  int missionCount; // e.g. 3 math problems, 30 shakes, 6 pairs memory, 20 steps
  String? barcodeTarget; // Expected barcode/QR code data
  String? barcodeLabel; // e.g. "Bathroom Toothpaste"

  // Audio & Haptics
  String soundPath;
  String soundTitle;
  double volume;
  bool vibrate;
  bool gentleWake;
  int gentleWakeMinutes;

  // Snooze
  bool snoozeEnabled;
  int snoozeDurationMinutes;
  int maxSnoozeCount; // 0 = no snooze, 999 = unlimited
  int currentSnoozeCount;

  // Wake-Up Check (Anti-Sleep Guard)
  bool wakeUpCheck;
  int wakeUpCheckMinutes; // e.g. 5 or 10 min

  AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    List<int>? repeatDays,
    this.isEnabled = true,
    this.label = 'Alarm',
    this.missionType = MissionType.math,
    this.missionDifficulty = MissionDifficulty.normal,
    this.missionCount = 3,
    this.barcodeTarget,
    this.barcodeLabel,
    this.soundPath = 'assets/audio/loud_siren.wav',
    this.soundTitle = 'Loud Piercing Siren',
    this.volume = 1.0,
    this.vibrate = true,
    this.gentleWake = false,
    this.gentleWakeMinutes = 3,
    this.snoozeEnabled = true,
    this.snoozeDurationMinutes = 5,
    this.maxSnoozeCount = 3,
    this.currentSnoozeCount = 0,
    this.wakeUpCheck = true,
    this.wakeUpCheckMinutes = 5,
  }) : repeatDays = repeatDays ?? [];

  String get timeFormatted {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  String get repeatSummary {
    if (repeatDays.isEmpty) return 'Once';
    if (repeatDays.length == 7) return 'Every day';
    if (repeatDays.length == 5 &&
        repeatDays.contains(1) &&
        repeatDays.contains(2) &&
        repeatDays.contains(3) &&
        repeatDays.contains(4) &&
        repeatDays.contains(5)) {
      return 'Weekdays';
    }
    if (repeatDays.length == 2 &&
        repeatDays.contains(6) &&
        repeatDays.contains(7)) {
      return 'Weekends';
    }
    const dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays.map((d) => dayNames[d]).join(', ');
  }

  String get missionName {
    switch (missionType) {
      case MissionType.none:
        return 'Standard Alarm';
      case MissionType.math:
        return 'Math ($missionCount problems)';
      case MissionType.shake:
        return 'Shake ($missionCount shakes)';
      case MissionType.barcode:
        return 'Scan Barcode / QR';
      case MissionType.memory:
        return 'Memory Puzzle';
      case MissionType.typing:
        return 'Affirmation Typing';
      case MissionType.step:
        return 'Step / Squats ($missionCount)';
      case MissionType.photo:
        return 'Take a photo of room';
      case MissionType.voice:
        return 'Voice recording message';
    }
  }

  AlarmModel copyWith({
    String? id,
    int? hour,
    int? minute,
    List<int>? repeatDays,
    bool? isEnabled,
    String? label,
    MissionType? missionType,
    MissionDifficulty? missionDifficulty,
    int? missionCount,
    String? barcodeTarget,
    String? barcodeLabel,
    String? soundPath,
    String? soundTitle,
    double? volume,
    bool? vibrate,
    bool? gentleWake,
    int? gentleWakeMinutes,
    bool? snoozeEnabled,
    int? snoozeDurationMinutes,
    int? maxSnoozeCount,
    int? currentSnoozeCount,
    bool? wakeUpCheck,
    int? wakeUpCheckMinutes,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatDays: repeatDays ?? List.from(this.repeatDays),
      isEnabled: isEnabled ?? this.isEnabled,
      label: label ?? this.label,
      missionType: missionType ?? this.missionType,
      missionDifficulty: missionDifficulty ?? this.missionDifficulty,
      missionCount: missionCount ?? this.missionCount,
      barcodeTarget: barcodeTarget ?? this.barcodeTarget,
      barcodeLabel: barcodeLabel ?? this.barcodeLabel,
      soundPath: soundPath ?? this.soundPath,
      soundTitle: soundTitle ?? this.soundTitle,
      volume: volume ?? this.volume,
      vibrate: vibrate ?? this.vibrate,
      gentleWake: gentleWake ?? this.gentleWake,
      gentleWakeMinutes: gentleWakeMinutes ?? this.gentleWakeMinutes,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      snoozeDurationMinutes: snoozeDurationMinutes ?? this.snoozeDurationMinutes,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
      currentSnoozeCount: currentSnoozeCount ?? this.currentSnoozeCount,
      wakeUpCheck: wakeUpCheck ?? this.wakeUpCheck,
      wakeUpCheckMinutes: wakeUpCheckMinutes ?? this.wakeUpCheckMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'repeatDays': repeatDays,
      'isEnabled': isEnabled,
      'label': label,
      'missionType': missionType.index,
      'missionDifficulty': missionDifficulty.index,
      'missionCount': missionCount,
      'barcodeTarget': barcodeTarget,
      'barcodeLabel': barcodeLabel,
      'soundPath': soundPath,
      'soundTitle': soundTitle,
      'volume': volume,
      'vibrate': vibrate,
      'gentleWake': gentleWake,
      'gentleWakeMinutes': gentleWakeMinutes,
      'snoozeEnabled': snoozeEnabled,
      'snoozeDurationMinutes': snoozeDurationMinutes,
      'maxSnoozeCount': maxSnoozeCount,
      'currentSnoozeCount': currentSnoozeCount,
      'wakeUpCheck': wakeUpCheck,
      'wakeUpCheckMinutes': wakeUpCheckMinutes,
    };
  }

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'] ?? '',
      hour: map['hour'] ?? 7,
      minute: map['minute'] ?? 0,
      repeatDays: List<int>.from(map['repeatDays'] ?? []),
      isEnabled: map['isEnabled'] ?? true,
      label: map['label'] ?? 'Alarm',
      missionType: MissionType.values[map['missionType'] ?? 1],
      missionDifficulty: MissionDifficulty.values[map['missionDifficulty'] ?? 1],
      missionCount: map['missionCount'] ?? 3,
      barcodeTarget: map['barcodeTarget'],
      barcodeLabel: map['barcodeLabel'],
      soundPath: map['soundPath'] ?? 'assets/audio/loud_siren.wav',
      soundTitle: map['soundTitle'] ?? 'Loud Piercing Siren',
      volume: (map['volume'] as num?)?.toDouble() ?? 1.0,
      vibrate: map['vibrate'] ?? true,
      gentleWake: map['gentleWake'] ?? false,
      gentleWakeMinutes: map['gentleWakeMinutes'] ?? 3,
      snoozeEnabled: map['snoozeEnabled'] ?? true,
      snoozeDurationMinutes: map['snoozeDurationMinutes'] ?? 5,
      maxSnoozeCount: map['maxSnoozeCount'] ?? 3,
      currentSnoozeCount: map['currentSnoozeCount'] ?? 0,
      wakeUpCheck: map['wakeUpCheck'] ?? true,
      wakeUpCheckMinutes: map['wakeUpCheckMinutes'] ?? 5,
    );
  }

  String toJson() => json.encode(toMap());
  factory AlarmModel.fromJson(String source) => AlarmModel.fromMap(json.decode(source));
}
