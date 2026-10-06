import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import '../theme/app_theme.dart';

class AlarmEditScreen extends StatefulWidget {
  final AlarmModel? alarm;

  const AlarmEditScreen({super.key, this.alarm});

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  late int _hour;
  late int _minute;
  late List<int> _repeatDays;
  late String _label;

  late MissionType _missionType;
  late MissionDifficulty _missionDifficulty;
  late int _missionCount;
  String? _barcodeTarget;
  String? _barcodeLabel;

  late String _soundPath;
  late String _soundTitle;
  late double _volume;
  late bool _vibrate;
  late bool _gentleWake;
  late int _gentleWakeMinutes;

  late bool _snoozeEnabled;
  late int _snoozeDurationMinutes;
  late int _maxSnoozeCount;

  late bool _wakeUpCheck;
  late int _wakeUpCheckMinutes;

  final AudioPlayer _previewPlayer = AudioPlayer();
  bool _isPlayingPreview = false;

  final List<Map<String, String>> _availableSounds = [
    {
      'title': 'Loud Piercing Siren',
      'path': 'assets/audio/loud_siren.wav',
    },
    {
      'title': 'Classic Digital Beeps',
      'path': 'assets/audio/digital_beep.wav',
    },
    {
      'title': 'Military Horn Alarm',
      'path': 'assets/audio/military_alarm.wav',
    },
    {
      'title': 'Gentle Morning Chimes',
      'path': 'assets/audio/gentle_chimes.wav',
    },
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.alarm;
    if (a != null) {
      _hour = a.hour;
      _minute = a.minute;
      _repeatDays = List.from(a.repeatDays);
      _label = a.label;
      _missionType = a.missionType;
      _missionDifficulty = a.missionDifficulty;
      _missionCount = a.missionCount;
      _barcodeTarget = a.barcodeTarget;
      _barcodeLabel = a.barcodeLabel;
      _soundPath = a.soundPath;
      _soundTitle = a.soundTitle;
      _volume = a.volume;
      _vibrate = a.vibrate;
      _gentleWake = a.gentleWake;
      _gentleWakeMinutes = a.gentleWakeMinutes;
      _snoozeEnabled = a.snoozeEnabled;
      _snoozeDurationMinutes = a.snoozeDurationMinutes;
      _maxSnoozeCount = a.maxSnoozeCount;
      _wakeUpCheck = a.wakeUpCheck;
      _wakeUpCheckMinutes = a.wakeUpCheckMinutes;
    } else {
      _hour = 7;
      _minute = 0;
      _repeatDays = [1, 2, 3, 4, 5];
      _label = 'Alarm';
      _missionType = MissionType.math;
      _missionDifficulty = MissionDifficulty.normal;
      _missionCount = 3;
      _barcodeTarget = null;
      _barcodeLabel = null;
      _soundPath = 'assets/audio/loud_siren.wav';
      _soundTitle = 'Loud Piercing Siren';
      _volume = 1.0;
      _vibrate = true;
      _gentleWake = false;
      _gentleWakeMinutes = 3;
      _snoozeEnabled = true;
      _snoozeDurationMinutes = 5;
      _maxSnoozeCount = 3;
      _wakeUpCheck = true;
      _wakeUpCheckMinutes = 5;
    }
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudioPreview(String path) async {
    if (_isPlayingPreview) {
      await _previewPlayer.stop();
      setState(() => _isPlayingPreview = false);
    } else {
      String cleanPath = path;
      if (cleanPath.startsWith('assets/')) {
        cleanPath = cleanPath.substring('assets/'.length);
      }
      await _previewPlayer.setVolume(1.0);
      await _previewPlayer.play(AssetSource(cleanPath));
      setState(() => _isPlayingPreview = true);
      _previewPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlayingPreview = false);
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              surface: AppTheme.cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
    }
  }

  void _saveAlarm() {
    _previewPlayer.stop();
    final updated = AlarmModel(
      id: widget.alarm?.id ?? const Uuid().v4(),
      hour: _hour,
      minute: _minute,
      repeatDays: _repeatDays,
      isEnabled: true,
      label: _label,
      missionType: _missionType,
      missionDifficulty: _missionDifficulty,
      missionCount: _missionCount,
      barcodeTarget: _barcodeTarget,
      barcodeLabel: _barcodeLabel,
      soundPath: _soundPath,
      soundTitle: _soundTitle,
      volume: _volume,
      vibrate: _vibrate,
      gentleWake: _gentleWake,
      gentleWakeMinutes: _gentleWakeMinutes,
      snoozeEnabled: _snoozeEnabled,
      snoozeDurationMinutes: _snoozeDurationMinutes,
      maxSnoozeCount: _maxSnoozeCount,
      wakeUpCheck: _wakeUpCheck,
      wakeUpCheckMinutes: _wakeUpCheckMinutes,
    );

    final service = AlarmService();
    if (widget.alarm == null) {
      service.addAlarm(updated);
    } else {
      service.updateAlarm(updated);
    }

    Navigator.of(context).pop();
  }

  void _scanBarcodeToRegister() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              AppBar(
                title: const Text('Scan Item to Register Barcode'),
                backgroundColor: Colors.black,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Scan an item in another room (e.g., toothpaste, cereal box, coffee machine)',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final barcode = capture.barcodes.firstOrNull?.rawValue;
                    if (barcode != null && barcode.isNotEmpty) {
                      Navigator.of(ctx).pop();
                      _promptBarcodeLabel(barcode);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _promptBarcodeLabel(String code) {
    final controller = TextEditingController(text: 'Bathroom Toothpaste');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Barcode Scanned!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Code: $code', style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Name this item'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _barcodeTarget = code;
                _barcodeLabel = controller.text.trim();
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Target'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final period = _hour >= 12 ? 'PM' : 'AM';
    final displayHour = _hour == 0 ? 12 : (_hour > 12 ? _hour - 12 : _hour);
    final minuteStr = _minute.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'New Alarm' : 'Edit Alarm'),
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: const Text(
              'SAVE',
              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Large Time Picker Card
          GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$displayHour:$minuteStr',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    period,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Days Repeat Selector
          _buildCard(
            title: 'Repeat',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDayChip('M', 1),
                _buildDayChip('T', 2),
                _buildDayChip('W', 3),
                _buildDayChip('T', 4),
                _buildDayChip('F', 5),
                _buildDayChip('S', 6),
                _buildDayChip('S', 7),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mission Selector
          _buildCard(
            title: 'Wake-Up Mission',
            subtitle: 'Choose challenge to dismiss alarm',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMissionChip('Photo', MissionType.photo, Icons.camera_alt_rounded),
                    _buildMissionChip('Voice', MissionType.voice, Icons.mic_rounded),
                    _buildMissionChip('Math', MissionType.math, Icons.calculate_rounded),
                    _buildMissionChip('Shake', MissionType.shake, Icons.vibration_rounded),
                    _buildMissionChip('Barcode/QR', MissionType.barcode, Icons.qr_code_scanner_rounded),
                    _buildMissionChip('Memory', MissionType.memory, Icons.psychology_rounded),
                    _buildMissionChip('Typing', MissionType.typing, Icons.keyboard_rounded),
                    _buildMissionChip('Steps', MissionType.step, Icons.directions_walk_rounded),
                    _buildMissionChip('None', MissionType.none, Icons.notifications_active_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMissionDetails(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Wake-Up Check (Anti-Snooze Guard)
          _buildCard(
            title: 'Wake-Up Check 🛡️',
            subtitle: 'Prevents falling back asleep after mission',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Wake-Up Check'),
                  subtitle: const Text('Re-rings if you don\'t tap confirm awake'),
                  value: _wakeUpCheck,
                  onChanged: (val) => setState(() => _wakeUpCheck = val),
                ),
                if (_wakeUpCheck) ...[
                  const Divider(color: Color(0xFF30363D)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Check delay after dismissing:'),
                      DropdownButton<int>(
                        value: _wakeUpCheckMinutes,
                        dropdownColor: AppTheme.cardColor,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 3, child: Text('3 mins')),
                          DropdownMenuItem(value: 5, child: Text('5 mins')),
                          DropdownMenuItem(value: 10, child: Text('10 mins')),
                          DropdownMenuItem(value: 15, child: Text('15 mins')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _wakeUpCheckMinutes = v);
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ringtone & Audio
          _buildCard(
            title: 'Ringtone & Audio',
            child: Column(
              children: [
                ..._availableSounds.map((snd) {
                  final isSelected = _soundPath == snd['path'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      snd['title']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primary : Colors.white,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlayingPreview && isSelected
                                ? Icons.stop_circle_rounded
                                : Icons.play_circle_rounded,
                            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                          ),
                          onPressed: () => _toggleAudioPreview(snd['path']!),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _soundPath = snd['path']!;
                        _soundTitle = snd['title']!;
                      });
                    },
                  );
                }),
                const Divider(color: Color(0xFF30363D)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Gentle Wake Up'),
                  subtitle: const Text('Starts soft and gradually increases volume'),
                  value: _gentleWake,
                  onChanged: (val) => setState(() => _gentleWake = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vibration'),
                  value: _vibrate,
                  onChanged: (val) => setState(() => _vibrate = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Snooze Settings
          _buildCard(
            title: 'Snooze Control',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Allow Snooze'),
                  value: _snoozeEnabled,
                  onChanged: (val) => setState(() => _snoozeEnabled = val),
                ),
                if (_snoozeEnabled) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Max Allowed Snoozes:'),
                      DropdownButton<int>(
                        value: _maxSnoozeCount,
                        dropdownColor: AppTheme.cardColor,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('0 (Strict / No Snooze)')),
                          DropdownMenuItem(value: 1, child: Text('1 time only')),
                          DropdownMenuItem(value: 3, child: Text('3 times')),
                          DropdownMenuItem(value: 5, child: Text('5 times')),
                          DropdownMenuItem(value: 999, child: Text('Unlimited')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _maxSnoozeCount = v);
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Delete Button if editing
          if (widget.alarm != null)
            TextButton.icon(
              onPressed: () {
                AlarmService().deleteAlarm(widget.alarm!.id);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: const Text('Delete Alarm', style: TextStyle(color: Colors.redAccent)),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, String? subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
          const SizedBox(height: 14),
          Material(
            color: Colors.transparent,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDayChip(String name, int day) {
    final isSelected = _repeatDays.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _repeatDays.remove(day);
          } else {
            _repeatDays.add(day);
          }
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppTheme.primary : AppTheme.surfaceLight,
        ),
        alignment: Alignment.center,
        child: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMissionChip(String label, MissionType type, IconData icon) {
    final isSelected = _missionType == type;
    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : AppTheme.textSecondary),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _missionType = type);
      },
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.surfaceLight,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textSecondary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMissionDetails() {
    switch (_missionType) {
      case MissionType.math:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Difficulty:'),
                DropdownButton<MissionDifficulty>(
                  value: _missionDifficulty,
                  dropdownColor: AppTheme.cardColor,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: MissionDifficulty.easy, child: Text('Easy (12+18)')),
                    DropdownMenuItem(value: MissionDifficulty.normal, child: Text('Normal (14x6+12)')),
                    DropdownMenuItem(value: MissionDifficulty.hard, child: Text('Hard (28x14+65)')),
                    DropdownMenuItem(value: MissionDifficulty.genius, child: Text('Genius (45x12-89)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _missionDifficulty = v);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Problem Count: $_missionCount'),
                Slider(
                  value: _missionCount.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: AppTheme.primary,
                  onChanged: (v) => setState(() => _missionCount = v.toInt()),
                ),
              ],
            ),
          ],
        );

      case MissionType.shake:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Number of Shakes: $_missionCount'),
            Slider(
              value: _missionCount.toDouble(),
              min: 15,
              max: 100,
              divisions: 17,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => _missionCount = v.toInt()),
            ),
          ],
        );

      case MissionType.barcode:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _barcodeTarget == null
                  ? 'No target barcode registered. Any barcode will dismiss, or register one now:'
                  : 'Target Item: ${_barcodeLabel ?? "Registered"} (${_barcodeTarget!})',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _scanBarcodeToRegister,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(_barcodeTarget == null ? 'Register Target Item' : 'Change Target Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceLight,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );

      case MissionType.step:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step/Squat Count: $_missionCount'),
            Slider(
              value: _missionCount.toDouble(),
              min: 10,
              max: 50,
              divisions: 8,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => _missionCount = v.toInt()),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
