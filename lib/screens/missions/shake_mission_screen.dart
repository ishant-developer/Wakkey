import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../models/alarm_model.dart';
import '../../theme/app_theme.dart';

class ShakeMissionScreen extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback onCompleted;

  const ShakeMissionScreen({
    super.key,
    required this.alarm,
    required this.onCompleted,
  });

  @override
  State<ShakeMissionScreen> createState() => _ShakeMissionScreenState();
}

class _ShakeMissionScreenState extends State<ShakeMissionScreen>
    with SingleTickerProviderStateMixin {
  late int _targetShakes;
  int _currentShakes = 0;
  StreamSubscription<UserAccelerometerEvent>? _sensorSubscription;
  DateTime _lastShakeTime = DateTime.now();

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _targetShakes = widget.alarm.missionCount > 0 ? widget.alarm.missionCount : 30;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _listenToShakes();
  }

  void _listenToShakes() {
    _sensorSubscription = userAccelerometerEventStream().listen((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      // Threshold for a genuine vigorous shake
      if (magnitude > 11.5) {
        final now = DateTime.now();
        if (now.difference(_lastShakeTime).inMilliseconds > 220) {
          _lastShakeTime = now;
          _registerShake();
        }
      }
    }, onError: (err) {
      debugPrint('Sensors error: $err');
    });
  }

  void _registerShake() {
    HapticFeedback.heavyImpact();
    _animController.forward().then((_) => _animController.reverse());

    setState(() {
      _currentShakes++;
    });

    if (_currentShakes >= _targetShakes) {
      _sensorSubscription?.cancel();
      widget.onCompleted();
    }
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentShakes / _targetShakes).clamp(0.0, 1.0);
    final remaining = _targetShakes - _currentShakes;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Shake Mission', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Shake your phone vigorously!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get out of bed and wake up your body',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 48),

              // Animated Radial Gauge
              ScaleTransition(
                scale: _scaleAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 16,
                        backgroundColor: AppTheme.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.vibration_rounded,
                          size: 48,
                          color: AppTheme.primary,
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
                          'SHAKES LEFT',
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
              ),
              const SizedBox(height: 60),

              // Helper / Emulator test button
              OutlinedButton.icon(
                onPressed: _registerShake,
                icon: const Icon(Icons.touch_app, size: 18),
                label: const Text('Tap to Simulate Shake (Dev / Testing)'),
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
