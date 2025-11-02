# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based QR Code Scanner application that supports multiple platforms (iOS, Android, Web, macOS, Linux, Windows). Currently using the default Flutter counter app template.

**SDK Requirements:** Dart SDK ^3.9.2

## Development Commands

### Running the App
```bash
# Check available devices
flutter devices

# Run on specific device
flutter run -d chrome           # Web (Chrome)
flutter run -d macos            # macOS (requires Xcode)
flutter run -d <device-id>      # iOS/Android device

# Hot reload (during development)
# Press 'r' in terminal or save files
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Build Commands
```bash
# Build for production
flutter build apk              # Android
flutter build ios              # iOS (requires macOS + Xcode)
flutter build web              # Web
flutter build macos            # macOS desktop

# Build with specific build mode
flutter build apk --release
flutter build apk --debug
flutter build apk --profile
```

### Code Quality
```bash
# Run static analysis
flutter analyze

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated
```

## iOS Development Setup

To run on iOS devices:
1. Install Xcode and command line tools: `xcode-select --install`
2. Connect iPhone via USB
3. Trust the computer on the device
4. Enable Developer Mode (iOS 16+): Settings > Privacy & Security > Developer Mode
5. Run `flutter devices` to verify device is detected

## Project Structure

- `lib/main.dart` - Application entry point with MaterialApp setup
- `test/` - Widget and unit tests
- Platform-specific folders: `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`

## Linting

The project uses `flutter_lints` package with recommended Flutter lints. Configuration in `analysis_options.yaml`.
