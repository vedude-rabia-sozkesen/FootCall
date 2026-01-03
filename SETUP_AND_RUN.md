# FootCall - Setup and Run Guide

## 📋 Brief Project Overview and Motivation

**FootCall** is a mobile application designed to help amateur football players and teams easily organize and manage **halısaha (indoor soccer)** matches. The app provides a centralized platform where users can discover teams, create match requests, manage matches, and stay updated with real-time information.

### Motivation
The project was developed to solve the common problem of organizing indoor soccer matches among amateur players and teams. Traditional methods of organizing matches (phone calls, messaging apps) are inefficient and lack structure. FootCall provides a streamlined solution with:
- Real-time match updates
- Team discovery and management
- Automated match request workflows
- User-friendly interface with dark/light theme support

### Key Features
- **Authentication**: Firebase Authentication with email/password
- **Real-time Data**: Cloud Firestore streams for live updates
- **Match Management**: Create, view, filter, and update matches
- **Team Management**: Discover teams, view team details, join teams
- **Search**: Search for players and teams by name
- **State Management**: Provider pattern for scalable state management
- **Theme Support**: Dark and light mode with persistent preferences

---

## 🚀 Step-by-Step Setup and Run Instructions

### Prerequisites

1. **Flutter SDK**: Version 3.2.0 or higher (SDK constraint: `>=3.2.0 <4.0.0`)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter --version`
   - Ensure Flutter is in your PATH

2. **Dart SDK**: Included with Flutter (no separate installation needed)

3. **Firebase Account**: 
   - Create a Firebase project at https://console.firebase.google.com
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Configure Firestore security rules (see `firestore.rules` file)

4. **Development Environment**:
   - Android Studio / VS Code with Flutter extensions
   - Android SDK (for Android development)
   - Xcode (for iOS development on macOS)

### Firebase Configuration

1. **Create Firebase Project**:
   - Go to https://console.firebase.google.com
   - Click "Add project" and follow the setup wizard
   - Note your project ID

2. **Enable Authentication**:
   - In Firebase Console, go to Authentication → Sign-in method
   - Enable "Email/Password" provider

3. **Enable Cloud Firestore**:
   - In Firebase Console, go to Firestore Database
   - Click "Create database"
   - Start in test mode (rules will be updated from `firestore.rules`)
   - Choose a location for your database

4. **Configure Firestore Security Rules**:
   - In Firebase Console, go to Firestore Database → Rules
   - Copy the contents of `firestore.rules` from the project root
   - Paste and publish the rules

5. **Get Firebase Configuration**:
   - In Firebase Console, go to Project Settings (gear icon)
   - Scroll down to "Your apps" section
   - If no app exists, click "Add app" → Select Flutter
   - Follow the instructions to register your app
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

6. **Generate Firebase Options** (if needed):
   - Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
   - Run: `flutterfire configure`
   - This will generate/update `lib/firebase/firebase_options.dart`

### Installation Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/vedude-rabia-sozkesen/FootCall.git
   cd FootCall
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
   This will install all required packages:
   - `firebase_core`, `firebase_auth`, `cloud_firestore`
   - `provider` (state management)
   - `shared_preferences` (local storage)
   - `google_fonts`, `intl`, `uuid`

3. **Verify Flutter Setup**:
   ```bash
   flutter doctor
   ```
   Ensure all required components are installed and configured.

4. **Verify Firebase Configuration**:
   - Check that `lib/firebase/firebase_options.dart` exists
   - Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in place
   - Ensure Firebase project is properly configured in Firebase Console

### Running the Application

#### For Android:

1. **Connect Device or Start Emulator**:
   ```bash
   # List available devices
   flutter devices
   
   # Start Android emulator (if using)
   # Or connect a physical device via USB with USB debugging enabled
   ```

2. **Run the App**:
   ```bash
   flutter run
   ```
   Or specify a device:
   ```bash
   flutter run -d <device-id>
   ```

#### For iOS (macOS only):

1. **Open iOS Simulator or Connect Device**:
   ```bash
   # List available devices
   flutter devices
   
   # Open iOS Simulator
   open -a Simulator
   ```

2. **Install CocoaPods Dependencies** (first time only):
   ```bash
   cd ios
   pod install
   cd ..
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

#### Build for Release:

**Android APK**:
```bash
flutter build apk --release
```

**Android App Bundle**:
```bash
flutter build appbundle --release
```

**iOS** (requires macOS and Xcode):
```bash
flutter build ios --release
```

### Troubleshooting

**Issue: Firebase not initialized**
- Ensure `firebase_options.dart` is properly generated
- Verify Firebase project configuration
- Check that `google-services.json` / `GoogleService-Info.plist` is in the correct location

**Issue: Dependencies not found**
- Run `flutter pub get` again
- Delete `pubspec.lock` and run `flutter pub get`
- Run `flutter clean` and then `flutter pub get`

**Issue: Build errors**
- Run `flutter clean`
- Run `flutter pub get`
- For Android: Check `android/app/build.gradle` for proper configuration
- For iOS: Run `cd ios && pod install && cd ..`

**Issue: Authentication not working**
- Verify Email/Password is enabled in Firebase Console
- Check Firestore security rules allow authentication
- Ensure `firebase_options.dart` has correct project configuration

---

## 🧪 How to Run Tests

### Running All Tests

```bash
flutter test
```

This will run all test files in the `test/` directory.

### Running Specific Test Files

```bash
flutter test test/path/to/test_file.dart
```

### Running Tests with Coverage

```bash
flutter test --coverage
```

Coverage report will be generated in `coverage/lcov.info`.

### Test Structure

Tests should be placed in the `test/` directory with the naming convention:
- `*_test.dart` for unit tests
- `*_widget_test.dart` for widget tests
- `*_integration_test.dart` for integration tests

### Example Test Commands

```bash
# Run all tests
flutter test

# Run tests with verbose output
flutter test --verbose

# Run tests and generate coverage
flutter test --coverage

# Run a specific test file
flutter test test/services/auth_service_test.dart
```

**Note**: Currently, the project may not have comprehensive test coverage. It is recommended to add tests for:
- Service layer methods (authentication, Firestore operations)
- Provider state management
- Critical business logic
- Widget functionality

---

## ⚠️ Known Limitations and Bugs

### Known Limitations

1. **Delete Operations**:
   - Delete operations for matches and players are not fully implemented
   - Users cannot delete matches they created
   - Users cannot delete their player accounts

2. **Repository Pattern**:
   - Some legacy code still uses the old repository pattern (`MatchRepository`, `PlayerRepository`, `RequestRepository`)
   - These repositories use static data instead of Firestore streams
   - Migration to full Firestore integration is recommended

3. **Error Handling**:
   - Some pages may not have comprehensive error handling for all edge cases
   - Network error handling could be improved in some areas

4. **Loading States**:
   - Not all providers have comprehensive loading state management
   - Some UI components may not show loading indicators during async operations

5. **Optimistic Updates**:
   - UI updates are not optimistic (changes reflect after server confirmation)
   - This may cause slight delays in UI responsiveness

### Known Bugs

1. **BuildContext Usage**:
   - Some warnings about using `BuildContext` across async gaps
   - These are non-critical but should be fixed for best practices
   - Location: `create_match_request_page.dart`, `home_page.dart`, `my_player.dart`, `team_chat_page.dart`

2. **Deprecated Methods**:
   - Some deprecated methods are still in use (e.g., `withOpacity`, form field `value`)
   - These should be updated to use newer APIs
   - Non-critical but will cause warnings

3. **Unused Imports**:
   - Some files have unused imports that should be cleaned up
   - These don't affect functionality but should be removed

4. **Unused Variables**:
   - Some local variables are declared but not used
   - These should be removed or utilized

5. **Null Safety Warnings**:
   - Some unnecessary null checks and assertions
   - These are safe but indicate code that could be simplified

### Workarounds

- **For delete operations**: Currently, matches and players cannot be deleted through the UI. This is a known limitation that will be addressed in future updates.

- **For repository pattern**: The app still functions correctly, but some features may not have real-time updates. Full migration to Firestore streams is recommended.

- **For BuildContext warnings**: These are warnings only and don't affect functionality. They can be fixed by checking `mounted` before using `BuildContext` after async operations.

### Future Improvements

1. Implement delete operations for matches and players
2. Complete migration from repository pattern to Firestore streams
3. Add comprehensive test coverage
4. Improve error handling across all pages
5. Add optimistic UI updates for better user experience
6. Clean up deprecated method usage
7. Remove unused imports and variables
8. Add loading states to all async operations

---

## 📚 Additional Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Firebase Documentation**: https://firebase.google.com/docs
- **Provider Package**: https://pub.dev/packages/provider
- **Cloud Firestore**: https://firebase.google.com/docs/firestore

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Firebase Console for configuration issues
3. Verify Flutter and Firebase setup with `flutter doctor`
4. Check GitHub issues for known problems

---

**Last Updated**: Based on current codebase state
**Flutter Version**: 3.2.0 or higher
**Dart SDK**: Included with Flutter

