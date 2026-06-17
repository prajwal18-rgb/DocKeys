# DocKeys – Government Scheme Advisor & Document Tracker

DocKeys is a Flutter app that helps users discover government schemes they are eligible for, manage required documents, and apply via official links.

- **User mode**: profile-based scheme eligibility, document tracking, personal document vault, notifications
- **Admin mode**: publish schemes, send announcements, manage notifications

---

## Quick Start (clone and run)

```bash
git clone https://github.com/Bhupendra-DS/doc-keys.git
cd doc-keys
flutter pub get
flutter run
```

**Prerequisites**: Flutter SDK 3.3+ and Android toolchain (or iOS).

The app includes a demo Firebase config (`google-services.json`) so it runs out of the box. Sign up as a new user or create `admin@dockeys.com` in Firebase for admin access.

---

## Project Setup (optional)

For your own Firebase backend:

1. Create a Firebase project and enable **Email/Password** sign-in.
2. Add an Android app with package name `com.example.dockeys`.
3. Download `google-services.json` and replace `android/app/google-services.json`.
4. Run `flutter pub get` and `flutter run`.

---

## Admin Login

- **Admin email**: `admin@dockeys.com` (create this user in Firebase to access admin features)

---

## Tech Stack

- Flutter, Provider, Go Router, Firebase Auth
- SharedPreferences, file_picker, url_launcher

---

## Troubleshooting

- **Build fails**: Run `flutter clean` and `flutter pub get`
- **Firebase errors**: Ensure `google-services.json` is in `android/app/`
