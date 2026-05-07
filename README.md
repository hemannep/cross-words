# Crossword Game

A modern Flutter crossword puzzle game built with the same architecture and theme as your Sudoku game.

## Features

- 🎮 **7 Difficulty Levels**: Newbie → Easy → Regular → Hard → Expert → Professional → Extreme
- 📅 **Daily Challenges** with Firebase backend (auto-generated each day)
- 🔥 **Streak Counter** to track consecutive days played
- 🔓 **Progressive Unlock System** — complete games to unlock harder levels
- ▶️ **Continue Game** — resume an unfinished puzzle
- 💡 **Hints & Reveal Word** powered by rewarded ads
- ❤️ **Extra Chances** — watch a rewarded ad to get more mistakes (up to 3 times)
- 📱 **Ads Integration**: Banner, Interstitial, and Rewarded
- 🎨 **Same green theme** as your Sudoku game

## Project Structure

```
crossword_game/
├── main.dart                          # Entry point + splash screen
├── firebase_options.dart              # Firebase config (REPLACE with your own)
├── pubspec.yaml
│
├── Ads/
│   ├── ad_unit_ids.dart              # Test/Prod ad IDs
│   ├── banner_ads.dart
│   ├── interstitial_ads.dart
│   └── rewared_ads.dart
│
├── utils/
│   ├── crossword_generator.dart      # Puzzle generation + word bank
│   ├── game_progress.dart            # Player progress tracking
│   ├── game_state.dart               # Main game state (Provider)
│   └── daily_challenge_service.dart  # Firebase daily challenges
│
├── widgets/
│   ├── crossword_board.dart          # Grid renderer
│   ├── clue_bar.dart                 # Active clue display
│   ├── letter_keyboard.dart          # QWERTY keyboard
│   └── bottom_actions.dart           # Undo/Erase/Reveal/Hint
│
└── screens/
    ├── Home Screen/
    │   ├── home_screen.dart
    │   ├── streak_counter.dart
    │   ├── continue_control.dart
    │   └── daily_challenge_widget.dart
    ├── Difficulty Screen/
    │   ├── difficulty_screen.dart
    │   ├── difficulty_card.dart
    │   ├── difficulty_header.dart
    │   └── difficulty_dialog.dart
    └── Game Screen/
        ├── game_screen.dart
        ├── game_header.dart
        ├── board_display.dart
        └── pause_overlay.dart
```

## Setup

### 1. Create the Flutter project

```bash
flutter create crosswordgame
cd crosswordgame
```

Then drop the contents of this folder into your `lib/` directory and replace `pubspec.yaml`.

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Add Poppins font (optional)

Download Poppins from [Google Fonts](https://fonts.google.com/specimen/Poppins) and place these files in `assets/fonts/`:
- Poppins-Regular.ttf
- Poppins-Medium.ttf
- Poppins-SemiBold.ttf
- Poppins-Bold.ttf

### 4. Configure Firebase

Run:
```bash
flutterfire configure
```

This will replace `firebase_options.dart` with your project's credentials. Make sure to enable **Cloud Firestore** in the Firebase Console.

Firestore security rules (basic):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /dailyCrosswordChallenges/{document=**} {
      allow read: if true;
      allow write: if true; // Tighten for production
    }
  }
}
```

### 5. Configure AdMob

Open `Ads/ad_unit_ids.dart` and:
- Test IDs are active by default (safe for development)
- Uncomment the production IDs (replace `ca-app-pub-6682242848319169/...`) when releasing

#### Android setup

In `android/app/src/main/AndroidManifest.xml`, inside `<application>`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```
Replace with your real App ID for production.

#### iOS setup

In `ios/Runner/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```

### 6. Run

```bash
flutter run
```

## Difficulty Unlock Requirements

| Difficulty | Unlocks After |
|---|---|
| Newbie | Available from start |
| Easy | 3 Newbie games |
| Regular | 7 Easy games |
| Hard | 13 Regular games |
| Expert | 20 Hard games |
| Professional | 25 Expert games |
| Extreme | 30 Professional games |

Players can also tap **"Unlock All"** to watch a rewarded ad and unlock everything for 24 hours.

## Game Mechanics

- **Score**: Starts at 100, decreases on mistakes (-5), hints (-15), reveal word (-30)
- **Mistakes**: Max 5 per game; rewarded ad grants +3 more (up to 3 times)
- **Auto-advance**: Typing a letter moves to the next cell automatically
- **Direction toggle**: Tap an active cell again to switch between Across/Down
- **Cycle clues**: Use chevron arrows in the clue bar to navigate

## Theme

Matches your Sudoku game:
- Primary: `Colors.green`
- Font: Poppins
- Rounded corners: 12-20px
- Soft shadows + gradient accents

## Ad Strategy

- **Banner**: Always at bottom of Home & Game screens
- **Interstitial**: Every 3 undo/erase actions, every 2 game starts
- **Rewarded**: Hints, Reveal Word, Continue After Loss, Resume Game, Unlock All
# cross-words
