import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/alarm_model.dart';
import '../../theme/app_theme.dart';

class BarcodeMissionScreen extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback onCompleted;

  const BarcodeMissionScreen({
    super.key,
    required this.alarm,
    required this.onCompleted,
  });

  @override
  State<BarcodeMissionScreen> createState() => _BarcodeMissionScreenState();
}

class _BarcodeMissionScreenState extends State<BarcodeMissionScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isTorchOn = false;
  bool _isCompleted = false;
  String? _errorMessage;

  // Emergency unlock timer (hold for 15 seconds)
  double _emergencyHoldProgress = 0.0;
  Timer? _emergencyTimer;

  @override
  void dispose() {
    _controller.dispose();
    _emergencyTimer?.cancel();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isCompleted) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _checkBarcode(code);
        break;
      }
    }
  }

  void _checkBarcode(String scannedValue) {
    final target = widget.alarm.barcodeTarget;

    // If no specific barcode was saved, any barcode succeeds
    if (target == null || target.trim().isEmpty || target.trim() == scannedValue.trim()) {
      _isCompleted = true;
      HapticFeedback.heavyImpact();
      widget.onCompleted();
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        _errorMessage = 'Wrong barcode! Scan: ${widget.alarm.barcodeLabel ?? "Target barcode"}';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _errorMessage = null);
      });
    }
  }

  void _startEmergencyHold() {
    _emergencyTimer?.cancel();
    _emergencyHoldProgress = 0.0;
    _emergencyTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _emergencyHoldProgress += 0.1 / 15.0; // 15 seconds hold
        if (_emergencyHoldProgress >= 1.0) {
          timer.cancel();
          _isCompleted = true;
          widget.onCompleted();
        }
      });
    });
  }

  void _stopEmergencyHold() {
    _emergencyTimer?.cancel();
    setState(() {
      _emergencyHoldProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.alarm.barcodeLabel ?? 'Registered Barcode / QR';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Viewfinder
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Scanning Overlay Frame
          SafeArea(
            child: Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          'Scan: $label',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
                        onPressed: () {
                          _controller.toggleTorch();
                          setState(() => _isTorchOn = !_isTorchOn);
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Center Reticle
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primary, width: 3),
                  ),
                  child: Center(
                    child: Container(
                      width: 240,
                      height: 2,
                      color: AppTheme.primary.withAlpha(180),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),

                const Spacer(),

                // Bottom Instruction & Emergency Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Align barcode inside the box to dismiss',
                        style: TextStyle(color: Colors.white, fontSize: 15, shadows: [
                          Shadow(blurRadius: 4, color: Colors.black),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      // Emergency hold button
                      GestureDetector(
                        onTapDown: (_) => _startEmergencyHold(),
                        onTapUp: (_) => _stopEmergencyHold(),
                        onTapCancel: () => _stopEmergencyHold(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _emergencyHoldProgress > 0
                                    ? 'Keep holding (${(15 * (1 - _emergencyHoldProgress)).toInt()}s)...'
                                    : 'Lost barcode? Hold 15s for Emergency Unlock',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              if (_emergencyHoldProgress > 0) ...[
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: _emergencyHoldProgress,
                                  color: AppTheme.primary,
                                  backgroundColor: Colors.white12,
                                ),
                              ],
                            ],
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
