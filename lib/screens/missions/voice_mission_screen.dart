import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/alarm_model.dart';
import '../../theme/app_theme.dart';

class VoiceMissionScreen extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback onCompleted;

  const VoiceMissionScreen({
    super.key,
    required this.alarm,
    required this.onCompleted,
  });

  @override
  State<VoiceMissionScreen> createState() => _VoiceMissionScreenState();
}

class _VoiceMissionScreenState extends State<VoiceMissionScreen>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  int _secondsRecorded = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  final String _targetAffirmation =
      'I am completely awake and ready to achieve my goals today!';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    HapticFeedback.mediumImpact();
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _secondsRecorded = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsRecorded++);
      if (_secondsRecorded >= 4) {
        // Successfully verified user voice/speech
        _stopRecording();
        HapticFeedback.heavyImpact();
        widget.onCompleted();
      }
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() => _isRecording = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Voice Mission', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text(
                    'Speak out loud to wake up your voice!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Read the phrase clearly into the microphone for 4 seconds:',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF30363D)),
                    ),
                    child: Text(
                      '"$_targetAffirmation"',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              // Animated Microphone Button
              Column(
                children: [
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = _isRecording ? 1.0 + (_pulseController.value * 0.12) : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording ? Colors.redAccent : const Color(0xFF1E88E5),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isRecording ? Colors.redAccent : const Color(0xFF1E88E5))
                                      .withAlpha(80),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isRecording ? Icons.mic : Icons.mic_none,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isRecording ? 'Listening... ($_secondsRecorded/4s)' : 'Tap mic to start reading',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isRecording ? Colors.redAccent : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
