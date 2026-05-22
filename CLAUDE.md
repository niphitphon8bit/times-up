# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Times Up** is an iOS alarm app that forces users to complete physical exercises (push-ups or squats) to dismiss the alarm. Built with SwiftUI, SwiftData, and Apple's Vision framework for real-time pose detection.

- **Platform:** iPhone only, iOS 17.0+
- **Language:** Swift 5.9
- **Build system:** XcodeGen (`project.yml` → generates `TimesUp.xcodeproj`)
- **No external dependencies** — uses only Apple frameworks

## Build Commands

```bash
# Regenerate Xcode project from project.yml (run after modifying project.yml)
xcodegen generate

# Build from CLI (requires a simulator to be available)
xcodebuild -project TimesUp.xcodeproj -scheme TimesUp -destination 'platform=iOS Simulator,name=iPhone 15' build

# Open in Xcode (preferred workflow)
open TimesUp.xcodeproj
```

There is no test target — all verification is done by running the app on a simulator or device.

## Architecture

The app follows MVVM. The flow from alarm creation to exercise dismissal:

```
AlarmListView
  └─→ AlarmListViewModel
        ├─→ SwiftData (ModelContext) — persists Alarm objects
        └─→ NotificationService — schedules/cancels daily local notifications

AppDelegate (UNUserNotificationCenterDelegate)
  └─→ posts "alarmTriggered" NSNotification when notification fires

AlarmListView (observes "alarmTriggered")
  └─→ presents ChallengeView fullscreen

ChallengeView
  └─→ ChallengeViewModel
        ├─→ AVCaptureSession + CameraPreviewView — live camera input
        ├─→ PoseDetectionService — Vision VNDetectHumanBodyPoseRequest (runs on processing queue)
        ├─→ ExerciseDetector (PushUpDetector | SquatDetector) — state machine rep counting
        └─→ AudioService — loops alarm sound until exercise complete
```

### Key Design Points

**Exercise detection pipeline:** Camera frames → Vision pose landmarks → joint angle computation → state machine (up/down phases) → rep count. Angles are smoothed over a 5-frame window; 3 consecutive frames required to confirm a state change.

- `PushUpDetector`: elbow angle < 90° = down, > 150° = up
- `SquatDetector`: knee angle < 100° = squat, > 160° = standing

**State management:** ViewModels use `@Observable` (Swift 5.9 macro, not the older `@StateObject`/`ObservableObject` pattern).

**Alarm persistence:** `Alarm` is a SwiftData `@Model` with UUID, time (Date), `ExerciseType` enum, required rep count, enabled flag, and optional label.

**Emergency dismiss:** 10-second long press on the challenge screen skips the exercise requirement.

## Key Files

| File | Purpose |
|------|---------|
| `TimesUp/App/TimesUpApp.swift` | App entry, SwiftData container setup, notification delegate wiring |
| `TimesUp/Models/Alarm.swift` | SwiftData model |
| `TimesUp/Models/ExerciseType.swift` | Enum: `.pushUps` / `.squats` |
| `TimesUp/ViewModels/ChallengeViewModel.swift` | Orchestrates camera, pose detection, rep counting |
| `TimesUp/Services/PoseDetectionService.swift` | Vision framework wrapper; computes joint angles |
| `TimesUp/ExerciseDetection/PushUpDetector.swift` | Push-up state machine |
| `TimesUp/ExerciseDetection/SquatDetector.swift` | Squat state machine |
| `TimesUp/Services/NotificationService.swift` | Schedules repeating daily UNNotifications |
| `TimesUp/Services/AudioService.swift` | Loops alarm audio via AVAudioPlayer |
| `project.yml` | XcodeGen spec — edit this instead of modifying the .xcodeproj directly |

## Adding a New Exercise Type

1. Add a case to `ExerciseType` in `Models/ExerciseType.swift` (icon + instructions)
2. Create a new detector in `ExerciseDetection/` conforming to the `ExerciseDetector` protocol
3. Wire the new case into `ChallengeViewModel` where `ExerciseDetector` is instantiated
