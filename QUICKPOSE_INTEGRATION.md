# QuickPose SDK Integration

This document explains the QuickPose SDK integration for exercise tracking in the Svasthya app.

## Integration Overview

We've implemented QuickPose integration using Flutter platform channels, allowing communication between Flutter and native Android code.

### Current Implementation Status

✅ **Completed:**
- Exercise tiles made fully clickable (anywhere on the tile)
- "Add to Patient's Exercises" button replaced with "Start Exercise"
- Complete exercise tracking page with camera preview
- Platform channel infrastructure for QuickPose SDK
- Real-time exercise tracking updates via event channel
- Camera permissions and initialization
- Exercise results display and feedback system

🚧 **In Progress:**
- Native QuickPose Android SDK integration (currently simulated)

### Architecture

1. **Flutter Service Layer** (`lib/services/quickpose_service.dart`)
   - Manages communication with platform channels
   - Handles exercise tracking lifecycle
   - Provides real-time updates stream

2. **Exercise Tracking Page** (`lib/pages/exercise_tracking_page.dart`)
   - Camera preview and UI
   - Real-time tracking display
   - Exercise results presentation

3. **Android Platform Channel** (`android/.../QuickPosePlugin.kt`)
   - Native Android plugin implementation
   - Method channel for SDK operations
   - Event channel for real-time updates

### SDK Key Configuration

The QuickPose SDK key is configured in the service:
```dart
static const String _sdkKey = '01K4DKC13739EYV3FC1PGAD5P9';
```

### Supported Exercise Types

- Push-ups
- Squats
- Lunges
- Planks
- Bicep curls
- General fitness exercises

### Next Steps for Full SDK Integration

1. **Add QuickPose Android SDK dependency** to `android/app/build.gradle`:
   ```gradle
   implementation 'ai.quickpose:quickpose-android-sdk:1.x.x'
   ```

2. **Replace simulation code** in `QuickPosePlugin.kt` with actual SDK calls:
   - Initialize SDK with provided key
   - Configure pose detection for specific exercises
   - Process real-time pose data
   - Calculate repetitions and form accuracy

3. **Add ProGuard rules** if needed for release builds

4. **Test with physical device** for camera and pose detection

### Usage Flow

1. User browses exercises in `PrescriptionExercisesPage`
2. Taps anywhere on exercise tile
3. Navigates to `ExerciseTrackingPage`
4. Camera initializes and QuickPose SDK starts
5. User performs exercise with real-time feedback
6. Results displayed when exercise session ends

### Platform Channel API

**Method Channel:** `quickpose_flutter`
- `initialize(sdkKey)` - Initialize SDK
- `startTracking(exerciseType, exerciseName)` - Start exercise tracking
- `stopTracking()` - Stop current session
- `getResults()` - Get exercise results
- `dispose()` - Clean up resources

**Event Channel:** `quickpose_flutter/updates`
- Real-time tracking updates with repetitions, accuracy, and feedback

### Error Handling

The implementation includes comprehensive error handling for:
- Camera permission issues
- SDK initialization failures
- Tracking session errors
- Platform channel communication errors