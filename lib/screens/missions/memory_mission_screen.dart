import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/alarm_model.dart';
import '../../theme/app_theme.dart';

class MemoryMissionScreen extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback onCompleted;

  const MemoryMissionScreen({
    super.key,
    required this.alarm,
    required this.onCompleted,
  });

  @override
  State<MemoryMissionScreen> createState() => _MemoryMissionScreenState();
}

class _MemoryCard {
  final int id;
  final IconData icon;
  bool isFaceUp = false;
  bool isMatched = false;

  _MemoryCard({
    required this.id,
    required this.icon,
  });
}

class _MemoryMissionScreenState extends State<MemoryMissionScreen> {
  final List<IconData> _allIcons = [
    Icons.wb_sunny_rounded,
    Icons.alarm_rounded,
    Icons.coffee_rounded,
    Icons.fitness_center_rounded,
    Icons.rocket_launch_rounded,
    Icons.lightbulb_rounded,
  ];

  late List<_MemoryCard> _cards;
  int? _firstSelectedIndex;
  bool _isBusy = false;
  int _matchesFound = 0;
  late int _totalPairs;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    _totalPairs = 6;
    final iconsToUse = _allIcons.take(_totalPairs).toList();
    final deck = <_MemoryCard>[];

    int id = 0;
    for (final icon in iconsToUse) {
      deck.add(_MemoryCard(id: id++, icon: icon));
      deck.add(_MemoryCard(id: id++, icon: icon));
    }
    deck.shuffle();
    _cards = deck;
  }

  void _onCardTap(int index) {
    if (_isBusy || _cards[index].isFaceUp || _cards[index].isMatched) return;

    HapticFeedback.lightImpact();
    setState(() {
      _cards[index].isFaceUp = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _isBusy = true;
      final firstIdx = _firstSelectedIndex!;
      final secondIdx = index;
      _firstSelectedIndex = null;

      if (_cards[firstIdx].icon == _cards[secondIdx].icon) {
        // Matched!
        HapticFeedback.mediumImpact();
        setState(() {
          _cards[firstIdx].isMatched = true;
          _cards[secondIdx].isMatched = true;
          _matchesFound++;
          _isBusy = false;
        });

        if (_matchesFound >= _totalPairs) {
          widget.onCompleted();
        }
      } else {
        // Did not match -> flip back after 700ms
        Timer(const Duration(milliseconds: 700), () {
          if (mounted) {
            setState(() {
              _cards[firstIdx].isFaceUp = false;
              _cards[secondIdx].isFaceUp = false;
              _isBusy = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Memory Mission', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_matchesFound / $_totalPairs Pairs',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Find matching pairs to wake up your mind!',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final showFront = card.isFaceUp || card.isMatched;

                    return GestureDetector(
                      onTap: () => _onCardTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: card.isMatched
                              ? AppTheme.secondary.withAlpha(50)
                              : (showFront ? AppTheme.surfaceLight : AppTheme.cardColor),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: card.isMatched
                                ? AppTheme.secondary
                                : (showFront ? AppTheme.primary : const Color(0xFF30363D)),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: showFront
                              ? Icon(
                                  card.icon,
                                  size: 40,
                                  color: card.isMatched ? AppTheme.secondary : AppTheme.primary,
                                )
                              : const Icon(
                                  Icons.question_mark_rounded,
                                  size: 32,
                                  color: AppTheme.textMuted,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
