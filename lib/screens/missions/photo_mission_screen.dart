import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/alarm_model.dart';
import '../../theme/app_theme.dart';

class PhotoMissionScreen extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback onCompleted;

  const PhotoMissionScreen({
    super.key,
    required this.alarm,
    required this.onCompleted,
  });

  @override
  State<PhotoMissionScreen> createState() => _PhotoMissionScreenState();
}

class _PhotoMissionScreenState extends State<PhotoMissionScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isCaptured = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _capturePhoto() {
    HapticFeedback.heavyImpact();
    setState(() => _isCaptured = true);

    // Show verification animation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        widget.onCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live camera viewfinder
          MobileScanner(
            controller: _controller,
          ),

          // Overlay Frame
          SafeArea(
            child: Column(
              children: [
                // Top banner
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded, color: Color(0xFF2979FF)),
                        SizedBox(width: 10),
                        Text(
                          'Take a photo of your room',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Center Guide Reticle
                Container(
                  width: 280,
                  height: 340,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2979FF), width: 3),
                  ),
                ),

                const Spacer(),

                // Capture Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      const Text(
                        'Align room or furniture in frame & capture',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isCaptured ? AppTheme.secondary : const Color(0xFF2979FF),
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2979FF).withAlpha(120),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isCaptured ? Icons.check : Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
