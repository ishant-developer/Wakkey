import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/alarm_model.dart';
import '../../theme/app_theme.dart';

class TypingMissionScreen extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback onCompleted;

  const TypingMissionScreen({
    super.key,
    required this.alarm,
    required this.onCompleted,
  });

  @override
  State<TypingMissionScreen> createState() => _TypingMissionScreenState();
}

class _TypingMissionScreenState extends State<TypingMissionScreen> {
  final List<String> _quotes = [
    'I am wide awake and ready to conquer my goals today without delay.',
    'Discipline is choosing between what you want now and what you want most.',
    'Every morning brings new potential. I choose energy and progress.',
    'I refuse to let laziness steal my dreams. Up and moving right now!',
  ];

  late String _targetQuote;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _targetQuote = _quotes[Random().nextInt(_quotes.length)];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (value.trim() == _targetQuote.trim()) {
      HapticFeedback.heavyImpact();
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentText = _textController.text;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Typing Mission', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Type the sentence exactly as shown:',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 20),

              // Target Quote Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    children: List.generate(_targetQuote.length, (index) {
                      final char = _targetQuote[index];
                      Color color = AppTheme.textMuted;

                      if (index < currentText.length) {
                        if (currentText[index] == char) {
                          color = AppTheme.secondary;
                        } else {
                          color = Colors.redAccent;
                        }
                      }

                      return TextSpan(
                        text: char,
                        style: TextStyle(
                          color: color,
                          fontWeight: index < currentText.length ? FontWeight.bold : FontWeight.normal,
                          decoration: index < currentText.length && currentText[index] != char
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Input field
              TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: 4,
                onChanged: _onTextChanged,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Type here...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF30363D)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_textController.text.trim() == _targetQuote.trim()) {
                    widget.onCompleted();
                  } else {
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quote does not match yet! Check spelling.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text('SUBMIT & DISMISS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
