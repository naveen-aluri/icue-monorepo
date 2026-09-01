# iCue Super Admin

A Flutter application for iCue Super Admin management and administration.

## Getting Started

### Prerequisites

- Flutter SDK (^3.12.2 or compatible)
- Dart SDK
- Android SDK / Xcode (for iOS)

### Installation & Dependencies

```bash
flutter pub get
```

## Code Generation

When modifying dependency injection (`injectable`) or other generated files, run `build_runner`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Running the App

### Development Flavor (`dev`)

```bash
flutter run --flavor dev
```

### Production Flavor (`prod`)

```bash
flutter run --flavor prod
```

## Building Releases

> **Important**: This project uses Gradle product flavors (`dev` and `prod`). You must specify the `--flavor` flag when generating builds.

### Development Builds (`dev`)

Generate DEV APK:

```bash
flutter build apk --flavor dev
```

Generate DEV App Bundle:

```bash
flutter build appbundle --flavor dev
```

### Production Builds (`prod`)

Generate PROD APK:

```bash
flutter build apk --flavor prod
```

Generate PROD App Bundle:

```bash
flutter build appbundle --flavor prod
```
