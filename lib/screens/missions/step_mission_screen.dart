import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../models/alarm_model.dart';
import '../../theme/app_theme.dart';

class StepMissionScreen extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback onCompleted;

  const StepMissionScreen({
    super.key,
    required this.alarm,
    required this.onCompleted,
  });

  @override
  State<StepMissionScreen> createState() => _StepMissionScreenState();
}

class _StepMissionScreenState extends State<StepMissionScreen> {
  late int _targetSteps;
  int _currentSteps = 0;
  StreamSubscription<UserAccelerometerEvent>? _sensorSubscription;
  DateTime _lastStepTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _targetSteps = widget.alarm.missionCount > 0 ? widget.alarm.missionCount : 20;
    _startStepTracking();
  }

  void _startStepTracking() {
    _sensorSubscription = userAccelerometerEventStream().listen((event) {
      // Step or squat creates vertical pulse in Y/Z axis
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > 4.5) {
        final now = DateTime.now();
        if (now.difference(_lastStepTime).inMilliseconds > 400) {
          _lastStepTime = now;
          _registerStep();
        }
      }
    });
  }

  void _registerStep() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentSteps++;
    });

    if (_currentSteps >= _targetSteps) {
      _sensorSubscription?.cancel();
      widget.onCompleted();
    }
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentSteps / _targetSteps).clamp(0.0, 1.0);
    final remaining = _targetSteps - _currentSteps;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Squats / Steps Mission', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Walk or do Squats!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hold phone in hand and start moving',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 48),

              // Animated Radial Gauge
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 16,
                      backgroundColor: AppTheme.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.directions_walk_rounded,
                        size: 48,
                        color: AppTheme.secondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$remaining',
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'STEPS LEFT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // Dev/Emulator simulation button
              OutlinedButton.icon(
                onPressed: _registerStep,
                icon: const Icon(Icons.touch_app, size: 18),
                label: const Text('Tap to Count Step (Testing)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  side: const BorderSide(color: Color(0xFF30363D)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
