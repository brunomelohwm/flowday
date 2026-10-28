# FlowDay

A Flutter app for organizing daily tasks, with email/password authentication and real-time sync via Firebase.

Built as a functional portfolio project — designed to evolve with new features without changing its core foundation.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

---

## ✨ Features

- Sign up and login with Firebase Authentication
- Password recovery via email
- Create, edit, and delete tasks
- Track tasks as to do, in progress, or done
- Real-time task listing with Cloud Firestore
- Calendar-based task visualization with inclusive multi-day ranges
- Profile with sign out and account deletion
- Account deletion removes user document and all tasks (with password reauthentication)
- Basic validation to prevent tasks without a title
- User-friendly empty states for first-time use

---

## 🛠 Tech Stack

- **Flutter** — UI and app logic
- **Provider** — State management
- **Firebase Authentication** — Auth
- **Cloud Firestore** — Real-time database
- **Mocktail** — Controller tests against repository contracts
- **Firebase Emulator** — Local Firestore ownership rules tests

**Why Provider (and not BLoC/Cubit)?**
Provider was chosen for simplicity given this app's scope. For larger apps with more complex state and business logic, I use BLoC/Cubit with Clean Architecture — as in my professional experience.

### Architecture

The app keeps Provider and `ChangeNotifier` for presentation state. `AuthController` and `TaskController` depend on repository contracts; Firebase Auth and Firestore adapters isolate SDK access, and Firestore timestamp conversion stays in the data mapper. This lets controller tests use Mocktail without connecting to Firebase.

Tasks have `todo`, `inProgress`, and `done` states. Older Firestore documents without a status remain `todo`. Calendar ranges include both start and end dates; tasks with one date appear on that date, and undated tasks stay out of the calendar.

---

## 🗂 Data Structure

Tasks are stored in Firestore under:

users/{uid}/tasks/{taskId}

Each user has their own document at `users/{uid}`, and tasks are isolated in the `tasks` subcollection.

---

## 🔒 Security and Privacy

- Firebase Authentication as the primary auth mechanism
- Account deletion requires password reauthentication before removing data
- When an account is deleted, the user's tasks and the `users/{uid}` document are removed
- Firestore ownership rules are versioned in [`firestore.rules`](firestore.rules)
- Emulator tests verify anonymous denial, owner access, and cross-user denial for profiles and tasks

### Firestore rules tests

Requirements: Node.js 20 or newer, npm, and Java 21 or newer for the Firestore Emulator. From the repository root, run:

```sh
npm --prefix firebase-tests run test:rules
```

The test command starts only the Firestore Emulator with the `demo-flowday-rules` project ID, so it does not use Firebase credentials or connect to the production project. It checks profile reads and writes, task reads and writes, and task collection listing for anonymous users, the owner, and a different user. These tests verify document ownership only; the rules do not validate field schemas or ensure a stored task `userId` matches its document path.

---

## 🚀 How to Run

### 1. Clone the repository

git clone https://github.com/brunomelohwm/flowday.git
cd flowday

### 2. Install dependencies

flutter pub get

### 3. Configure Firebase

1. Create a project in the [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** (Email/Password) and **Cloud Firestore**
3. Run `flutterfire configure` and select your project
4. This generates `lib/firebase_options.dart` and Android Firebase configuration. These local files are ignored by Git and must not be committed.

### 4. Run the app

flutter run -d DEVICE_ID

Replace `DEVICE_ID` with an Android device ID from `flutter devices`.

### Quality checks

Run the same checks used by GitHub Actions:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test test/widgets/task_load_feedback_test.dart
flutter test test/views/task_card_widget_test.dart
flutter test test/views/profile_view_test.dart
npm ci --prefix firebase-tests
npm --prefix firebase-tests run test:rules
flutter build apk --debug
```

The workflow runs on pushes to `main` and `codex/flowday-portfolio`, and on pull requests. It creates temporary demo Firebase client files for analysis and Android packaging; they contain no project credentials and are not committed. The Android build is a debug APK check; it does not produce a signed release.

---

## 📌 Status

Functional portfolio project with active development.

---

## 📫 Contact

- LinkedIn: [bruno-melo-76a853250](https://www.linkedin.com/in/bruno-melo-76a853250/)
- Email: brunomelohwm@gmail.com
