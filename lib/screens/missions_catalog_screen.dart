import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../theme/app_theme.dart';
import 'missions/math_mission_screen.dart';
import 'missions/shake_mission_screen.dart';
import 'missions/barcode_mission_screen.dart';
import 'missions/photo_mission_screen.dart';
import 'missions/voice_mission_screen.dart';
import 'missions/step_mission_screen.dart';

class MissionsCatalogScreen extends StatefulWidget {
  const MissionsCatalogScreen({super.key});

  @override
  State<MissionsCatalogScreen> createState() => _MissionsCatalogScreenState();
}

class _MissionsCatalogScreenState extends State<MissionsCatalogScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _missions = [
    {
      'title': 'Take a photo',
      'desc': 'Take a photo of your room',
      'category': 'Location',
      'icon': Icons.camera_alt_rounded,
      'color': const Color(0xFF1E3A8A),
      'iconColor': const Color(0xFF60A5FA),
      'type': MissionType.photo,
    },
    {
      'title': 'Scan a QR code',
      'desc': 'Scan a custom QR code',
      'category': 'Location',
      'icon': Icons.qr_code_2_rounded,
      'color': const Color(0xFF0369A1),
      'iconColor': const Color(0xFF38BDF8),
      'type': MissionType.barcode,
    },
    {
      'title': 'Solve a math problem',
      'desc': 'Solve a simple calculation',
      'category': 'Mental',
      'icon': Icons.calculate_rounded,
      'color': const Color(0xFFC2410C),
      'iconColor': const Color(0xFFFB923C),
      'type': MissionType.math,
    },
    {
      'title': 'Walk 10 steps',
      'desc': 'Walk around your room',
      'category': 'Physical',
      'icon': Icons.directions_walk_rounded,
      'color': const Color(0xFF047857),
      'iconColor': const Color(0xFF34D399),
      'type': MissionType.step,
    },
    {
      'title': 'Shake your phone',
      'desc': 'Shake your device 30 times',
      'category': 'Physical',
      'icon': Icons.vibration_rounded,
      'color': const Color(0xFF1D4ED8),
      'iconColor': const Color(0xFF93C5FD),
      'type': MissionType.shake,
    },
    {
      'title': 'Voice recording',
      'desc': 'Record a short voice message',
      'category': 'Mental',
      'icon': Icons.mic_rounded,
      'color': const Color(0xFF6D28D9),
      'iconColor': const Color(0xFFA78BFA),
      'type': MissionType.voice,
    },
  ];

  void _testMission(MissionType type) {
    final dummy = AlarmModel(
      id: 'preview',
      hour: 7,
      minute: 0,
      missionType: type,
      missionDifficulty: MissionDifficulty.normal,
      missionCount: type == MissionType.shake ? 20 : (type == MissionType.step ? 10 : 3),
    );

    Widget screen;
    switch (type) {
      case MissionType.photo:
        screen = PhotoMissionScreen(alarm: dummy, onCompleted: () => _done(context));
        break;
      case MissionType.barcode:
        screen = BarcodeMissionScreen(alarm: dummy, onCompleted: () => _done(context));
        break;
      case MissionType.math:
        screen = MathMissionScreen(alarm: dummy, onCompleted: () => _done(context));
        break;
      case MissionType.step:
        screen = StepMissionScreen(alarm: dummy, onCompleted: () => _done(context));
        break;
      case MissionType.shake:
        screen = ShakeMissionScreen(alarm: dummy, onCompleted: () => _done(context));
        break;
      case MissionType.voice:
        screen = VoiceMissionScreen(alarm: dummy, onCompleted: () => _done(context));
        break;
      default:
        return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _done(BuildContext context) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Mission verified! Wake-up reflexes sharp.'),
        backgroundColor: Color(0xFF00E676),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _missions
        : _missions.where((m) => m['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Missions',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.emoji_events_outlined, color: Colors.white, size: 26),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const Text(
            'Choose a mission for your alarm.\nMake waking up more challenging!',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 18),

          // Category Pills Filter (All, Physical, Mental, Location)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Physical', 'Mental', 'Location'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : const Color(0xFF30363D),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Missions List
          ...filtered.map((m) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF262C36)),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (m['color'] as Color).withAlpha(140),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(m['icon'], color: m['iconColor'], size: 26),
                  ),
                  title: Text(
                    m['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      m['desc'],
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                  onTap: () => _testMission(m['type']),
                ),
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
