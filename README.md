# FootCall

FootCall is a mobile application designed to help amateur football players and teams easily organize and manage **halısaha (indoor soccer)** matches. The app focuses on connecting teams, managing match workflows, and providing real-time updates through Firebase.

**“Find your match. Call your game.” — FootCall**

---

## 🚀 Overview & Motivation

FootCall provides a centralized platform where users can:
- Discover existing teams and matches
- Create and manage match requests between teams
- View match details and real-time updates
- Manage authentication-based access to application features

**Motivation:**
Organizing amateur football matches often involves chaotic messaging groups and unreliable scheduling. FootCall was created to provide a structured environment where teams can find opponents easily, match admins can update scores in real-time, and players can manage their sports identity in one place.

---

## 🛠 Setup & Installation

### Prerequisites
- **Flutter SDK:** `>=3.2.0 <4.0.0`
- **Firebase Account:** A project set up on the [Firebase Console](https://console.firebase.google.com/).

### Step-by-Step Instructions

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/mehmetfatihpaksoy/FootCallNew.git
    cd FootCallNew
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration:**
    - Register your Android/iOS app in the Firebase Console.
    - Download and place `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`.
    - *Alternatively:* Use the FlutterFire CLI (`flutterfire configure`) to generate the `lib/firebase_options.dart` file.

4.  **Run the App:**
    ```bash
    flutter run
    ```

---

## 🧪 Testing Methodology

To ensure application stability and maintainability, two primary testing layers have been implemented:

### 1. Unit Testing: PrefsService
The `PrefsService` class was tested to ensure that user preferences (dark mode, last selected tab) are correctly saved to and retrieved from local storage.
- **Scope:** Tested theme mode persistence, tab index tracking, and data clearing functions.
- **Methodology:** The `SharedPreferences` dependency was mocked using `setMockInitialValues` to create an in-memory test environment, ensuring fast and isolated tests without relying on actual device storage.

### 2. Widget Testing: AppBottomNavBar
The `AppBottomNavBar` component was tested for both visual correctness and interaction behavior.
- **Scope:** Verified that the widget renders correctly and navigates to the expected routes upon user interaction.
- **Technical Improvements:**
    - **Key-Based Discovery:** Instead of fragile text-based lookups, unique `Key` identifiers were used to locate widgets with precision.
    - **Navigation Simulation:** The test environment was wrapped in a `MaterialApp` with defined routes, and transitions were validated asynchronously using `tester.pumpAndSettle()`.

**To run all tests:**
```bash
flutter test
```

---

## ✨ Key Features

### Authentication & Access Control
- User authentication with Firebase Authentication
- Logged-out users are restricted to login and signup screens
- Logged-in users can access main application features

### Match Management
- Real-time match listing using Firestore streams
- Match status updates (scheduled, played, canceled)
- Admin-only actions for match updates (based on team ownership)
- Match creation requests between teams

### Team Management
- Team listing with real-time updates
- Team detail pages
- Team-based authorization for match-related actions

### UI & State Handling
- Loading, empty, and error states implemented across main screens
- Real-time UI updates when Firestore data changes
- Dark and light theme support using SharedPreferences
- Bottom navigation for main sections of the app

---

## 🏗 Technical Stack

- **Flutter** — UI framework
- **Firebase Authentication** — User authentication
- **Cloud Firestore** — Real-time database
- **Provider** — State management
- **SharedPreferences** — Persistent local settings (theme, tab state)

---

## 🚧 Known Limitations
- **Chat Media:** Currently, only text-based messages are supported in team chats.
- **Offline Mode:** The app requires an active internet connection; offline persistence is functional but limited.
- **Localization:** The interface is currently available primarily in English.
- **Team Size:** There is no hard limit on the number of players that can join a single team.
- **Result Verification:** Match results are managed by team admins; there is no global administrator for centralized result verification.
- **Scheduling Conflicts:** The system allows a team to be scheduled for multiple matches at the same date and time without conflict warnings.

---

## 📂 Project Structure Highlights

- `lib/pages/` — UI screens (home, matches, teams, authentication)
- `lib/providers/` — State management (auth, matches, teams, settings)
- `lib/services/` — Firebase and Shared Preferences service abstractions
- `lib/models/` — Data models (Match, Team, Player)

---

## 👥 Team Members

- **Berk Karaduman (29428)** — Firebase setup, application infrastructure, SharedPreferences
- **Vedude Rabia Sözkesen (32182)** — Provider architecture and state management
- **Elif Tuana Doğan (31914)** — Firestore security rules, testing, deployment, and documentation
- **Mehmet Fatih Paksoy (32519)** — Authentication flows and UI implementation
- **Ömer Ersoy (32572)** — Firestore data models, services, and CRUD operations
- **Arda Dinç (31256)** — UI integration, real-time data display, navigation guard implementation  
