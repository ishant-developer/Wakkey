import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sleep_sound_service.dart';
import '../theme/app_theme.dart';

class SleepSoundsScreen extends StatelessWidget {
  const SleepSoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sleepService = Provider.of<SleepSoundService>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Sleep Ambience & White Noise'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.nightlight_round, color: AppTheme.accent, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fall Asleep Faster',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sleepService.isPlaying
                            ? 'Currently playing • ${sleepService.timerMinutesRemaining ?? "No"} timer'
                            : 'Select ambient sound to relax and sleep peacefully.',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sleep Timer Options
          if (sleepService.isPlaying) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sleep Timer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [15, 30, 45, 60].map((mins) {
                      final isSelected = sleepService.timerMinutesRemaining == mins;
                      return ChoiceChip(
                        label: Text('${mins}m'),
                        selected: isSelected,
                        selectedColor: AppTheme.accent,
                        backgroundColor: AppTheme.surfaceLight,
                        onSelected: (_) => sleepService.setTimer(mins),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => sleepService.stopSound(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      child: const Text('Stop Audio'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          const Text(
            'Ambient Sound Library (Free)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 14),

          // Sounds List
          ...sleepService.sounds.map((s) {
            final isCurrent = sleepService.currentSoundId == s['id'] && sleepService.isPlaying;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isCurrent ? AppTheme.surfaceLight : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrent ? AppTheme.accent : const Color(0xFF30363D),
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: isCurrent ? AppTheme.accent : AppTheme.surfaceLight,
                  child: Icon(
                    s['id'] == 'rain'
                        ? Icons.water_drop_rounded
                        : (s['id'] == 'ocean' ? Icons.waves_rounded : Icons.air_rounded),
                    color: isCurrent ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
                title: Text(
                  s['title']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? AppTheme.accent : Colors.white,
                  ),
                ),
                subtitle: Text(s['desc']!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                trailing: IconButton(
                  icon: Icon(
                    isCurrent ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    color: isCurrent ? AppTheme.accent : Colors.white70,
                    size: 36,
                  ),
                  onPressed: () => sleepService.playSound(s['id']!),
                ),
                onTap: () => sleepService.playSound(s['id']!),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
