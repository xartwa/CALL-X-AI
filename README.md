# Call Center Admin

A clean Flutter web admin starter with as few moving parts as possible.

## Tech stack
- Flutter stable (Dart 3, null safety)
- State management: `flutter_bloc`
- Navigation: `go_router`
- Networking: `dio`
- Local storage: `shared_preferences`
- SVG assets: `flutter_svg`

## Project layout
- `lib/main.dart` – app entrypoint and simple dependency setup
- `lib/app.dart` – `MaterialApp.router` with BLoC-driven theme mode
- `lib/routes.dart` – all routes and the single shell layout
- `lib/pages/` – dashboard, agents and settings placeholder screens
- `lib/widgets/app_shell.dart` – navigation rail + theme toggle
- `lib/constants/` – shared values like API base URL and strings
- `lib/services/` – tiny helpers for `Dio` and saved preferences
- `lib/theme/` – theme data plus `AppTypography.scale` to resize every text style

## Getting started
1. Fetch dependencies: `flutter pub get`
2. Launch the web app: `flutter run -d chrome`

### Text scale
سایز همهٔ متن‌ها از `lib/theme/app_typography.dart` کنترل می‌شود؛ فقط مقدار `AppTypography.scale` را بالا یا پایین ببرید.

### ترجمهٔ ساده
تمام متن‌ها داخل `lib/constants/app_strings.dart` قرار دارند. برای اضافه کردن زبان جدید کافی است یک `AppStringsBundle` تازه به `_bundles` اضافه کنید یا از `AppStrings.registerBundle` استفاده کنید.
