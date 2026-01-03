# FootCall

FootCall is a mobile application designed to help amateur football players and teams easily organize and manage **halısaha (indoor soccer)** matches. The app focuses on connecting teams, managing match workflows, and providing real-time updates through Firebase.

---

## Overview

FootCall provides a centralized platform where users can:

- Discover existing teams and matches  
- Create and manage match requests between teams  
- View match details and real-time updates  
- Manage authentication-based access to application features  

The application is built with **Flutter** and uses **Firebase** for authentication, data storage, and real-time synchronization. State management is handled using the **Provider** architecture to ensure scalable and maintainable UI updates.

---

## Key Features

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

## Technical Stack

- **Flutter** — UI framework  
- **Firebase Authentication** — User authentication  
- **Cloud Firestore** — Real-time database  
- **Provider** — State management  
- **SharedPreferences** — Persistent local settings (theme, state)  

---

## Project Structure Highlights

- `lib/screens/` — UI screens (home, matches, teams, authentication)  
- `lib/providers/` — State management (auth, matches, teams, settings)  
- `lib/services/` — Firebase service abstractions  
- `lib/models/` — Data models   

---

## Team Members

- **Berk Karaduman (29428)** — Firebase setup, application infrastructure, SharedPreferences  
- **Vedude Rabia Sözkesen (32182)** — Provider architecture and state management  
- **Elif Tuana Doğan (31914)** — Firestore security rules, testing, deployment, and documentation  
- **Mehmet Fatih Paksoy (32519)** — Authentication flows and UI implementation  
- **Ömer Ersoy (32572)** — Firestore data models, services, and CRUD operations  
- **Arda Dinç (31256)** — UI integration, real-time data display, navigation guard implementation  

---

## Project Motto

**“Find your match. Call your game.” — FootCall**
