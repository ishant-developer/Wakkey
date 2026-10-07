import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/alarm_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Profile Card (matching mockup: Ishant Kumar)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFF2979FF),
                  child: Text(
                    'IK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ishant-developer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Developer Account',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu items container
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.alarm_rounded,
                  title: 'Alarm Settings',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.extension_rounded,
                  title: 'Mission Settings',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.nightlight_round,
                  title: 'Sleep Tracking',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Sounds & Vibration',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.brightness_4_outlined,
                  title: 'Theme',
                  trailingText: 'Dark',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.screen_lock_portrait_rounded,
                  title: 'Lock Screen & Permissions',
                  trailingText: 'Configure',
                  onTap: () => _showPermissionsSheet(context),
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () => _showPermissionsSheet(context),
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  trailingText: 'v1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Wakkey',
                      applicationVersion: '1.0.0',
                      applicationLegalese: 'Built by ishant-developer',
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.logout_rounded,
                  title: 'Log Out',
                  titleColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  showChevron: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Built by ishant-developer footer attribution
          const Center(
            child: Text(
              'Built by ishant-developer',
              style: TextStyle(
                color: Color(0xFF2979FF),
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? trailingText,
    Color? titleColor,
    Color? iconColor,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(icon, color: iconColor ?? Colors.white70, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(width: 6),
            ],
            if (showChevron)
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 54, color: Color(0xFF262C36));
  }

  void _showPermissionsSheet(BuildContext context) {
    final alarmService = Provider.of<AlarmService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Lock Screen & Alarm Reliability',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ensure these settings are enabled so Wakkey displays missions over your lock screen and rings reliably:',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.screen_lock_portrait_rounded, color: Color(0xFF60A5FA), size: 24),
                  ),
                  title: const Text('Display Over Other Apps', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: const Text('Required to show missions over lock screen', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  trailing: ElevatedButton(
                    onPressed: () => alarmService.requestOverlayPermission(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('ENABLE'),
                  ),
                ),
                const Divider(color: Color(0xFF262C36)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fullscreen_rounded, color: Color(0xFF60A5FA), size: 24),
                  ),
                  title: const Text('Full Screen Alarms (Android 14+)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: const Text('Allows alarm to turn on display immediately', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  trailing: ElevatedButton(
                    onPressed: () => alarmService.requestFullScreenIntentPermission(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('CHECK'),
                  ),
                ),
                const Divider(color: Color(0xFF262C36)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '💡 Xiaomi / Samsung / OnePlus Tip: In your phone settings > Wakkey > Battery, select "No Restrictions / Unrestricted". On Xiaomi / MIUI, also enable "Show on Lock screen" in Other Permissions.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.4),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
