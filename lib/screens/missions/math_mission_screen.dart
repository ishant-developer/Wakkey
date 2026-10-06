import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/alarm_model.dart';
import '../../theme/app_theme.dart';

class MathMissionScreen extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback onCompleted;

  const MathMissionScreen({
    super.key,
    required this.alarm,
    required this.onCompleted,
  });

  @override
  State<MathMissionScreen> createState() => _MathMissionScreenState();
}

class _MathMissionScreenState extends State<MathMissionScreen> {
  int _currentProblemIndex = 0;
  late int _totalProblems;
  late String _equation;
  late int _correctAnswer;
  String _inputAnswer = '';
  final Random _random = Random();
  bool _isWrong = false;

  @override
  void initState() {
    super.initState();
    _totalProblems = widget.alarm.missionCount;
    _generateProblem();
  }

  void _generateProblem() {
    _inputAnswer = '';
    _isWrong = false;

    switch (widget.alarm.missionDifficulty) {
      case MissionDifficulty.easy:
        final a = _random.nextInt(30) + 10;
        final b = _random.nextInt(30) + 5;
        if (_random.nextBool()) {
          _equation = '$a + $b';
          _correctAnswer = a + b;
        } else {
          final maxVal = max(a, b);
          final minVal = min(a, b);
          _equation = '$maxVal - $minVal';
          _correctAnswer = maxVal - minVal;
        }
        break;

      case MissionDifficulty.normal:
        final a = _random.nextInt(15) + 3;
        final b = _random.nextInt(12) + 2;
        final c = _random.nextInt(25) + 5;
        if (_random.nextBool()) {
          _equation = '($a × $b) + $c';
          _correctAnswer = (a * b) + c;
        } else {
          final prod = a * b;
          _equation = '$prod - $c';
          _correctAnswer = prod - c;
        }
        break;

      case MissionDifficulty.hard:
        final a = _random.nextInt(40) + 12;
        final b = _random.nextInt(15) + 6;
        final c = _random.nextInt(50) + 15;
        _equation = '($a × $b) + $c';
        _correctAnswer = (a * b) + c;
        break;

      case MissionDifficulty.genius:
        final a = _random.nextInt(50) + 20;
        final b = _random.nextInt(30) + 10;
        final c = _random.nextInt(90) + 25;
        _equation = '($a × $b) - $c';
        _correctAnswer = (a * b) - c;
        break;
    }
    setState(() {});
  }

  void _onKeypadTap(String val) {
    HapticFeedback.lightImpact();
    setState(() {
      _isWrong = false;
      if (val == 'C') {
        if (_inputAnswer.isNotEmpty) {
          _inputAnswer = _inputAnswer.substring(0, _inputAnswer.length - 1);
        }
      } else if (val == 'ENTER') {
        _checkAnswer();
      } else {
        if (_inputAnswer.length < 6) {
          _inputAnswer += val;
        }
      }
    });
  }

  void _checkAnswer() {
    final parsed = int.tryParse(_inputAnswer);
    if (parsed == _correctAnswer) {
      HapticFeedback.mediumImpact();
      if (_currentProblemIndex + 1 >= _totalProblems) {
        widget.onCompleted();
      } else {
        setState(() {
          _currentProblemIndex++;
        });
        _generateProblem();
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _isWrong = true;
        _inputAnswer = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentProblemIndex) / _totalProblems;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Math Mission', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentProblemIndex + 1} / $_totalProblems',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surfaceLight,
              color: AppTheme.primary,
              minHeight: 6,
            ),
            const SizedBox(height: 24),

            // Equation Display Area
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isWrong ? Colors.red : const Color(0xFF30363D),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isWrong ? 'Wrong! Try again' : 'Solve to dismiss alarm',
                      style: TextStyle(
                        color: _isWrong ? Colors.redAccent : AppTheme.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _equation,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 52,
                      width: 180,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isWrong ? Colors.red : AppTheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _inputAnswer.isEmpty ? '?' : _inputAnswer,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _inputAnswer.isEmpty ? AppTheme.textMuted : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Number Pad
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    const SizedBox(height: 12),
                    _buildKeypadRow(['4', '5', '6']),
                    const SizedBox(height: 12),
                    _buildKeypadRow(['7', '8', '9']),
                    const SizedBox(height: 12),
                    _buildKeypadRow(['C', '0', 'ENTER']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) {
          final isEnter = key == 'ENTER';
          final isClear = key == 'C';
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: InkWell(
                onTap: () => _onKeypadTap(key),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isEnter
                        ? AppTheme.secondary
                        : (isClear ? AppTheme.surfaceLight : AppTheme.cardColor),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isEnter ? Colors.transparent : const Color(0xFF30363D),
                    ),
                  ),
                  child: isClear
                      ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 24)
                      : Text(
                          key,
                          style: TextStyle(
                            fontSize: isEnter ? 18 : 26,
                            fontWeight: FontWeight.bold,
                            color: isEnter ? Colors.black : Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
