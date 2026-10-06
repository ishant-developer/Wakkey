# ⏰ Wakkey - Smart Habit Alarm

> **Built by [ishant-developer](https://github.com/ishant-developer)**

**Wakkey** is a smart, discipline-focused alarm and sleep routine application built with Flutter for personal productivity. Designed to overcome morning fatigue and build strong wake-up habits without paywalls, ads, or subscriptions.

---

## 🌟 Key Features

### 1. 🎯 Extreme Wake-Up Missions
Never fall asleep again. To dismiss an alarm, complete your chosen wake-up mission:
- 🧮 **Math Mission**: Solve arithmetic equations under pressure.
  - Difficulties: **Easy** (`12 + 19`), **Normal** (`14 × 6 + 12`), **Hard** (`28 × 14 + 65`), **Genius** (`(45 × 12) - 89`).
  - Configurable problem count (1 to 10 problems) with responsive on-screen numpad.
- 📳 **Shake Mission**: Vigorously shake your phone (20 to 100 shakes) tracked in real-time via hardware accelerometer with haptic feedback.
- 📷 **Barcode / QR Code Mission**: Force yourself out of bed to scan an item in another room (e.g. bathroom toothpaste, kitchen cereal, or book). Includes a 15-second emergency bypass hold.
- 🧠 **Memory Tiles Puzzle**: Flip and match cards to awaken cognitive synapses.
- ⌨️ **Affirmation Typing Mission**: Accurately type motivational morning affirmations without typos.
- 🚶 **Steps / Squats Mission**: Detect physical vertical movement pulses to get blood pumping.

### 2. 🛡️ Wake-Up Check (Anti-Sleep Guard)
A smart accountability feature: After successfully completing a mission and turning off the alarm, Wakkey sets an anti-sleep timer (3, 5, 10, or 15 mins). If you don't tap **"I'M WIDE AWAKE"**, the alarm sounds again to ensure you don't fall back asleep!

### 3. 🔊 Loud Audio & Gentle Wake
- Built-in audio library:
  - 🚨 **Loud Piercing Siren**
  - ⏰ **Classic Digital Beeps**
  - 🎺 **Military Wake-Up Horn**
  - 🔔 **Gentle Morning Chimes**
- **Gentle Wake**: Gradually ramps up volume from 10% to 100% over several minutes.
- **Strict Snooze Control**: Set maximum allowed snoozes (0 for strict no-snooze mode, 1, 3, or unlimited).

### 4. 🌙 Sleep Ambience & White Noise
- Built-in sleep sound generator:
  - 🌧️ **Heavy Rain**
  - 🌊 **Ocean Waves**
  - 💨 **White Noise**
- Integrated sleep timer (15m, 30m, 45m, 60m) with auto-stop.

### 5. 🏋️ Mission Practice & Calibration
### 5. 🔒 Background, App-Closed & Lock Screen Execution
- Uses Android native **`AlarmManager.setAlarmClock()`** (Android's highest-priority alarm API that bypasses Doze mode).
- **Runs when app is completely closed / killed**: The native Android `AlarmReceiver` wakes the system and initiates foreground audio playback.
- **Turns screen on and displays over Lock Screen**: Native `setShowWhenLocked(true)` and `setTurnScreenOn(true)` turn on the display and bring up the full-screen mission without requiring passcode unlock first.
- **Survives device reboot**: Armed with `BOOT_COMPLETED` receiver to reschedule alarms when your device powers back on.

---

## 📱 How to Install on Your Android Phone

The APK has been compiled and is ready for your phone:

### Release APK (Optimized, 70.1 MB):
```
D:\Wakkey\build\app\outputs\flutter-apk\app-release.apk
```

### Installation Steps:
1. **Via USB Cable**: Connect your phone to your PC, copy `app-release.apk` to your phone's `Downloads` folder, and tap it to install.
2. **Via ADB**:
   ```powershell
   adb install D:\Wakkey\build\app\outputs\flutter-apk\app-release.apk
   ```
3. **Via Cloud / Sharing**: Send the APK to your phone via Google Drive, Telegram, or WhatsApp and tap **Install**.

> **Important for Android Phones (Samsung, Xiaomi, OnePlus, Pixel, etc.)**:
> In your phone's **App Info / Settings > Wakkey**:
> 1. Set **Battery** to **Unrestricted** (prevents aggressive OS battery killer from terminating exact alarms).
> 2. Allow **"Display over other apps"** or **"Show on lock screen"**.

---

## 🛠️ Running the Project in Development

```powershell
# Run on connected phone or emulator
flutter run

# Run all unit and widget tests
flutter test

# Run analyzer
flutter analyze
```

---

## 📁 Project Architecture
```
lib/
├── models/
│   └── alarm_model.dart            # Alarm state, missions, snooze & wake-up check
├── services/
│   ├── alarm_service.dart          # Audio looping, precision scheduler, wake-up guard
│   └── sleep_sound_service.dart    # Ambient sleep sound player & sleep timer
├── screens/
│   ├── home_screen.dart            # Countdown banner, alarm cards, navigation
│   ├── alarm_edit_screen.dart      # Time picker, mission config, barcode register
│   ├── alarm_ringing_screen.dart   # Lock-screen wakeup UI, snooze guard, mission router
│   ├── wake_up_check_screen.dart   # Anti-sleep guard confirmation screen
│   ├── sleep_sounds_screen.dart    # White noise & relaxation player
│   ├── practice_screen.dart        # Practice missions anytime
│   └── missions/
│       ├── math_mission_screen.dart
│       ├── shake_mission_screen.dart
│       ├── barcode_mission_screen.dart
│       ├── memory_mission_screen.dart
│       ├── typing_mission_screen.dart
│       └── step_mission_screen.dart
├── theme/
│   └── app_theme.dart              # Modern dark aesthetic
└── main.dart                       # App entry point & provider bootstrap
```
