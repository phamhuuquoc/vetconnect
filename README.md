# vetconnect

Flutter app for pet owners, veterinarians, and clinic administrators.

See [implemented features and remaining integrations](docs/feature-status.md).

## Account roles

The app supports regular users, doctors, and admins using Firebase Auth and
Firestore rules. See [setup, permissions and tests](docs/roles.md), including
deploying rules and provisioning the first admin before using the new APK.

## Languages

Vietnamese and English can be switched from Profile or the compact language
button on the login screen. The device remembers the choice. See
[localization setup](docs/localization.md).

## Android build

Use JDK 17 and an Android SDK with API 36 and NDK 28.2.13676358 installed. The current
`android/gradle.properties` points to `D:\jdk17`; adjust this path to your
local JDK installation when building on another machine.

```powershell
flutter pub get
flutter build apk --debug
flutter build apk --release
```

APKs are written to `build/app/outputs/flutter-apk/`. Without
`android/key.properties`, release builds use the debug signing key for local
installation only. Do not publish these builds to a store.

For distribution, create the git-ignored `android/key.properties` with
`storeFile`, `storePassword`, `keyAlias`, and `keyPassword`. `storeFile` is an
absolute keystore path (use forward slashes on Windows), or a path relative to
`android/app`. Keep the keystore and credentials out of version control.
An incomplete properties file fails the build instead of falling back to debug
signing.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
