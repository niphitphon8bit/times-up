# Enhancement List

---

## Open

### Low Priority — Abstract `AVCaptureSession` away from the View layer
`ChallengeViewModel` exposes `captureSession` as `private(set) var`, which `CameraPreviewView` receives directly. This couples the View to AVFoundation and blocks UI-level testing.

**Files:** `TimesUp/ViewModels/ChallengeViewModel.swift`, `TimesUp/Views/CameraPreviewView.swift`

Revisit if UI testing becomes a goal.

---

## Done

| Task | What changed |
|---|---|
| Notification scheduling errors | `NotificationService.scheduleAlarm` now logs failures via the `add(request:completionHandler:)` callback |
| `ExerciseType` view-support data | `icon` and `instruction` moved to `TimesUp/Views/ExerciseType+ViewSupport.swift`; model is now UI-free |
| `NSNotificationCenter` alarm trigger | Replaced with `@Observable AppState`; `AppDelegate` owns the instance, injects it via `.environment`; `AlarmListView` observes with `.onChange` |
| `NSCameraUsageDescription` missing | Added to `project.yml` `info.properties` so it survives `xcodegen generate` |
| `setupCamera()` silent failure | Sets `cameraSetupFailed = true` and shows "Camera Unavailable" overlay |
| Camera preview not showing | `CameraPreviewView` rewritten with `layerClass` pattern — no zero-frame race condition |
| `requestAuthorization()` unused result | Added `@discardableResult` to `NotificationService` |
| No test target | `TimesUpTests` target added; 16 passing tests for `PoseDetectionService`, `PushUpDetector`, `SquatDetector` |
