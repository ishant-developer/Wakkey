import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sleep_sound_service.dart';
import '../theme/app_theme.dart';

class SleepDashboardScreen extends StatefulWidget {
  const SleepDashboardScreen({super.key});

  @override
  State<SleepDashboardScreen> createState() => _SleepDashboardScreenState();
}

class _SleepDashboardScreenState extends State<SleepDashboardScreen> {
  String _activeTab = 'Overview';

  @override
  Widget build(BuildContext context) {
    final sleepService = Provider.of<SleepSoundService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Sleep',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.nightlight_outlined, color: Colors.white, size: 24),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Segmented Tab Filter (Overview, Trends, History)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF262C36)),
            ),
            child: Row(
              children: ['Overview', 'Trends', 'History'].map((tab) {
                final isSelected = _activeTab == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),

          // Glowing Circular Sleep Dial (matching mockup: 7h 12m)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 210,
                  height: 210,
                  child: CircularProgressIndicator(
                    value: 0.72,
                    strokeWidth: 14,
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2979FF)),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.nightlight_round, color: Color(0xFF2979FF), size: 28),
                    const SizedBox(height: 6),
                    const Text(
                      '7h 12m',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Total Sleep',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Bedtime & Wake up 2-column cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF262C36)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.bed_rounded, color: Color(0xFF38BDF8), size: 22),
                      SizedBox(height: 10),
                      Text(
                        '11:48 PM',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bedtime',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF262C36)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.wb_sunny_rounded, color: Color(0xFFFBBF24), size: 22),
                      SizedBox(height: 10),
                      Text(
                        '7:00 AM',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Wake up',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sleep Quality Card (matching mockup: Good smiley)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF262C36)),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF064E3B),
                  radius: 18,
                  child: Icon(Icons.sentiment_satisfied_alt_rounded, color: Color(0xFF34D399), size: 22),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Quality',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    Text(
                      'Good',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Ambient Sleep Sounds Section
          const Text(
            'Sleep Ambience & Noise',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),

          ...sleepService.sounds.map((s) {
            final isPlaying = sleepService.currentSoundId == s['id'] && sleepService.isPlaying;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPlaying ? const Color(0xFF2563EB) : const Color(0xFF262C36),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: isPlaying ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                    child: Icon(
                      s['id'] == 'rain'
                          ? Icons.water_drop_rounded
                          : (s['id'] == 'ocean' ? Icons.waves_rounded : Icons.air_rounded),
                      color: isPlaying ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                  title: Text(
                    s['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(s['desc']!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  trailing: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: isPlaying ? const Color(0xFF2563EB) : Colors.white70,
                      size: 32,
                    ),
                    onPressed: () => sleepService.playSound(s['id']!),
                  ),
                  onTap: () => sleepService.playSound(s['id']!),
                ),
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
