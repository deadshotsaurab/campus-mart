# 🏪 Campus Mart – Setup Guide

A full-featured OLX-like campus marketplace built with Flutter + Firebase.

## Features
- 🔐 Email/Password + Google Sign-In Authentication
- 🏠 Home feed with category filter & search
- 📦 Post listings with up to 5 images
- 💬 Real-time chat between buyer & seller
- ❤️ Wishlist / save listings
- 👤 Profile with your own listings

---

## 🔥 Firebase Setup (REQUIRED)

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add Project** → Name it `campus-mart`
3. Follow the prompts (Analytics is optional)

### Step 2: Enable Services
- **Authentication** → Sign-in methods → Enable **Email/Password** and **Google**
- **Firestore Database** → Create database → Start in **test mode**
- **Storage** → Get started → Start in **test mode**

### Step 3: Add Android App
1. In Firebase Console → Project Settings → **Add app** → Android
2. Package name: `com.campusmart.campus_mart`
3. Download `google-services.json`
4. Replace `android/app/google-services.json` with the downloaded file

### Step 4: Install FlutterFire CLI & Configure
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=campus-mart
```
This generates `lib/firebase_options.dart`.

### Step 5: Update main.dart
Replace `await Firebase.initializeApp();` with:
```dart
import 'firebase_options.dart';
// ...
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

---

## ▶️ Run the App

```bash
flutter pub get
flutter run
```

---

## 📁 Project Structure

```
lib/
├── app/          # Theme, Router, App widget
├── features/
│   ├── auth/     # Login, Register, Splash, Onboarding
│   ├── home/     # Home feed with search & categories
│   ├── listing/  # Create & view listings
│   ├── chat/     # Real-time chat
│   └── profile/  # User profile & my listings
└── shared/       # Widgets, validators
```

---

## 🛡️ Firestore Security Rules (Production)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == uid;
    }
    match /listings/{lid} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.sellerId;
    }
    match /chats/{chatId} {
      allow read, write: if request.auth.uid in resource.data.participants;
      match /messages/{msgId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```
