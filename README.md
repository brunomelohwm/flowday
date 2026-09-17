# FlowDay

A Flutter app for organizing daily tasks, with email/password authentication and real-time sync via Firebase.

Built as a functional portfolio project — designed to evolve with new features without changing its core foundation.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

---

## 📱 Screenshots

| Login | Tasks | New Task | Profile |
|-------|-------|----------|---------|
| ![Login](assets/screenshots/login.png) | ![Tasks](assets/screenshots/tasks.png) | ![New Task](assets/screenshots/new_task.png) | ![Profile](assets/screenshots/profile.png) |

> Replace the paths above with your actual screenshots.

---

## ✨ Features

- Sign up and login with Firebase Authentication
- Password recovery via email
- Create, edit, and delete tasks
- Real-time task listing with Cloud Firestore
- Calendar-based task visualization
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

**Why Provider (and not BLoC/Cubit)?**
Provider was chosen for simplicity given this app's scope. For larger apps with more complex state and business logic, I use BLoC/Cubit with Clean Architecture — as in my professional experience.

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
- Firestore security rules are configured directly in the Firebase Console (not versioned in this repo)

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
4. This generates `firebase_options.dart` and adds the platform config files

### 4. Run the app

flutter run

---

## 📌 Status

Functional portfolio project with active development.

---

## 📫 Contact

- LinkedIn: [bruno-melo-76a853250](https://www.linkedin.com/in/bruno-melo-76a853250/)
- Email: brunomelohwm@gmail.com
