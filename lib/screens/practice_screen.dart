import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../theme/app_theme.dart';
import 'missions/math_mission_screen.dart';
import 'missions/shake_mission_screen.dart';
import 'missions/barcode_mission_screen.dart';
import 'missions/memory_mission_screen.dart';
import 'missions/typing_mission_screen.dart';
import 'missions/step_mission_screen.dart';
import 'missions/photo_mission_screen.dart';
import 'missions/voice_mission_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  void _openPractice(BuildContext context, MissionType type) {
    final dummyAlarm = AlarmModel(
      id: 'practice',
      hour: 7,
      minute: 0,
      missionType: type,
      missionDifficulty: MissionDifficulty.normal,
      missionCount: type == MissionType.shake ? 20 : (type == MissionType.step ? 15 : 3),
    );

    Widget missionScreen;
    switch (type) {
      case MissionType.math:
        missionScreen = MathMissionScreen(
          alarm: dummyAlarm,
          onCompleted: () => _onPracticeSuccess(context),
        );
        break;
      case MissionType.shake:
        missionScreen = ShakeMissionScreen(
          alarm: dummyAlarm,
          onCompleted: () => _onPracticeSuccess(context),
        );
        break;
      case MissionType.barcode:
        missionScreen = BarcodeMissionScreen(
          alarm: dummyAlarm,
          onCompleted: () => _onPracticeSuccess(context),
        );
        break;
      case MissionType.memory:
        missionScreen = MemoryMissionScreen(
          alarm: dummyAlarm,
          onCompleted: () => _onPracticeSuccess(context),
        );
        break;
      case MissionType.typing:
        missionScreen = TypingMissionScreen(
          alarm: dummyAlarm,
          onCompleted: () => _onPracticeSuccess(context),
        );
        break;
      case MissionType.step:
        missionScreen = StepMissionScreen(
          alarm: dummyAlarm,
          onCompleted: () => _onPracticeSuccess(context),
        );
        break;
      case MissionType.photo:
        missionScreen = PhotoMissionScreen(
          alarm: dummyAlarm,
          onCompleted: () => _onPracticeSuccess(context),
        );
        break;
      case MissionType.voice:
        missionScreen = VoiceMissionScreen(
          alarm: dummyAlarm,
          onCompleted: () => _onPracticeSuccess(context),
        );
        break;
      case MissionType.none:
        return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => missionScreen));
  }

  void _onPracticeSuccess(BuildContext context) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Practice completed! You\'re ready for morning wake-up.'),
        backgroundColor: AppTheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mission Practice & Testing'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Test missions anytime to train your morning reflexes or verify barcode scanning without waiting for an alarm.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _buildPracticeItem(
            context,
            title: 'Math Mission',
            subtitle: 'Solve equations under pressure',
            icon: Icons.calculate_rounded,
            color: const Color(0xFFFF5252),
            type: MissionType.math,
          ),
          _buildPracticeItem(
            context,
            title: 'Shake Mission',
            subtitle: 'Calibrate accelerometer shake sensitivity',
            icon: Icons.vibration_rounded,
            color: const Color(0xFFFF9100),
            type: MissionType.shake,
          ),
          _buildPracticeItem(
            context,
            title: 'Barcode / QR Scanner',
            subtitle: 'Test your bathroom or kitchen barcode',
            icon: Icons.qr_code_scanner_rounded,
            color: const Color(0xFF00E676),
            type: MissionType.barcode,
          ),
          _buildPracticeItem(
            context,
            title: 'Memory Tiles Puzzle',
            subtitle: 'Flip and match cognitive card pairs',
            icon: Icons.psychology_rounded,
            color: const Color(0xFF448AFF),
            type: MissionType.memory,
          ),
          _buildPracticeItem(
            context,
            title: 'Affirmation Typing',
            subtitle: 'Type inspirational wake-up sentences',
            icon: Icons.keyboard_rounded,
            color: const Color(0xFFAB47BC),
            type: MissionType.typing,
          ),
          _buildPracticeItem(
            context,
            title: 'Steps / Squats',
            subtitle: 'Count vertical movement pulses',
            icon: Icons.directions_walk_rounded,
            color: const Color(0xFF26A69A),
            type: MissionType.step,
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required MissionType type,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          trailing: const Icon(Icons.play_arrow_rounded, color: AppTheme.textMuted),
          onTap: () => _openPractice(context, type),
        ),
      ),
    );
  }
}
