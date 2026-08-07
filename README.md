# FlowDay

FlowDay is a simple Flutter application for organizing daily tasks, featuring email/password authentication and data synchronization through Firebase.

The goal of the project is to serve as a functional portfolio app, ready to evolve with new features without changing its core foundation.

## Features

* Sign up and login with Firebase Authentication.
* Password recovery via email.
* Create, edit, and delete tasks.
* Real-time task listing with Cloud Firestore.
* Calendar-based task visualization.
* Profile with options to sign out and delete the account.
* Account deletion also removes the user's document and tasks.
* Basic validation to prevent tasks without a title.
* User-friendly empty states for first-time use.

## Tech Stack

* Flutter
* Provider
* Firebase Authentication
* Cloud Firestore

## Data Structure

Tasks are stored in Firestore using the following structure:

```text
users/{uid}/tasks/{taskId}
```

Each user has their own document under `users/{uid}`, and their tasks are isolated within the `tasks` subcollection.

## Security and Privacy

* The app uses Firebase Authentication as its primary authentication mechanism.
* Account deletion requires password reauthentication before removing data.
* When an account is deleted, the app removes the user's tasks and the `users/{uid}` document.
* Firestore security rules are not versioned in this repository and must be configured directly in the Firebase Console.

## How to Run

1. Install the dependencies:

```bash
flutter pub get
```

2. Run the app:

```bash
flutter run
```

## Status

The project is currently in its early stages, with a focus on simplicity, stability, and presentation as a portfolio project.
