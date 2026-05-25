# PAC E-Library Mobile Application

<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" />
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" />
<img src="https://img.shields.io/badge/Laravel-12-red?logo=laravel" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" />
<img src="https://img.shields.io/badge/License-MIT-yellow" />

# PAC E-Library

Mobile Digital Library Application for the Police Academy of Cambodia.

Built with Flutter + Laravel API.

</div>

---

# 📱 Overview

PAC E-Library is a modern digital library mobile application developed for the Police Academy of Cambodia. The system allows users to browse books, read PDF documents, save reading progress, manage favorites, receive recommendations, and access educational resources anytime and anywhere.

The mobile application connects to a Laravel backend API and supports multilingual interfaces, dark mode, and responsive mobile design.

---

# ✨ Features

## 🔐 Authentication

- Login
- Logout
- Secure token authentication
- Account verification
- Persistent login session

---

## 📚 Library System

- Browse all books
- Category filtering
- Book recommendations
- Popular books
- New releases
- Continue reading
- Favorite books

---

## 🔍 Search System

- Smart search
- Search suggestions
- Search by:
  - Title
  - Author
  - Category
  - Tags
- Trending books

---

## 📖 PDF Reader

- Read PDF books online
- Continue reading
- Save reading progress
- Zoom in/out
- Fast page navigation
- Dark mode support

---

## 📝 PDF Annotations

- Highlight text
- Add comments
- Store annotations
- Annotation history

---

## ❤️ Favorites

- Add favorite books
- Remove favorite books
- Favorite list management

---

## 👤 User Profile

- View user information
- Update profile
- Upload profile photo
- Reading history

---

## 🌐 Localization

Supported languages:

- English 🇺🇸
- Khmer 🇰🇭

---

## 🎨 UI Features

- Material 3 UI
- Responsive layout
- Dark mode
- Smooth animations
- Mobile-friendly interface

---

# 🏗️ Project Structure

```bash
lib/
│
├── main.dart
│
├── models/
│   ├── auth_models.dart
│   ├── library_models.dart
│   ├── search_models.dart
│   ├── profile_models.dart
│   └── pdf_models.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── library_screen.dart
│   ├── search_screen.dart
│   ├── library_detail_screen.dart
│   ├── pdf_reader_screen.dart
│   ├── favorite_screen.dart
│   └── profile_screen.dart
│
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── library_service.dart
│   ├── search_service.dart
│   ├── pdf_service.dart
│   └── profile_service.dart
│
├── utils/
│   ├── app_constants.dart
│   ├── app_theme.dart
│   ├── app_routes.dart
│   ├── library_utils.dart
│   └── search_utils.dart
│
├── widgets/
│   ├── book_card.dart
│   ├── loading_widget.dart
│   ├── custom_app_bar.dart
│   ├── cached_net_image.dart
│   ├── section_header.dart
│   └── error_widget.dart
│
└── l10n/
    ├── app_en.arb
    └── app_km.arb
```

---

# ⚙️ Technology Stack

## Frontend

- Flutter 3.x
- Dart
- Material 3

## Backend

- Laravel 12
- MySQL
- Laravel Sanctum Authentication

## API Communication

- REST API
- JSON responses
- Bearer token authentication

---

# 📦 Packages

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_localizations:
    sdk: flutter

  http: ^1.2.2
  intl: ^0.19.0
  provider: ^6.1.2
  cached_network_image: ^3.4.1
  flutter_secure_storage: ^9.2.2
  syncfusion_flutter_pdfviewer: ^26.2.14
```

---

# 🔌 API Endpoints

# Authentication

```http
POST /api/signin
POST /api/signout
GET  /api/verify/account
```

---

# Books

```http
GET /api/items
GET /api/items/{id}
GET /api/books/{id}/views/count
```

---

# Favorites

```http
GET    /api/my-favorite-books
POST   /api/books/{id}/favorite
DELETE /api/books/{id}/favorite
GET    /api/books/{id}/favorite/check
```

---

# PDF Progress

```http
POST /api/pdf-progress
GET  /api/pdf-progress/show
GET  /api/pdf-progress/pdf-progress-list
```

---

# User Profile

```http
GET   /api/users/profile
PATCH /api/users/profile
PATCH /api/update/photo
```

---

# 🚀 Installation

# 1. Clone Repository

```bash
git clone https://github.com/your-username/pac-e-library-mobile.git
```

---

# 2. Open Project

```bash
cd pac-e-library-mobile
```

---

# 3. Install Dependencies

```bash
flutter pub get
```

---

# 4. Configure API URL

Edit:

```dart
lib/utils/app_constants.dart
```

Example:

```dart
class AppConstants {
  static const String baseUrl = 'http://10.0.2.2:8080';
}
```

Production:

```dart
class AppConstants {
  static const String baseUrl = 'https://your-domain.com';
}
```

---

# 5. Run Application

```bash
flutter run
```

---

# 📱 Android Emulator API URL

If Laravel backend runs on local computer:

```dart
http://10.0.2.2:8080
```

---

# 💻 Web/Desktop API URL

```dart
http://127.0.0.1:8080
```

---

# 🌍 Production API URL

```dart
https://your-domain.com
```

---

# 🔐 Authentication Flow

```text
User Login
    ↓
Laravel API Validation
    ↓
Return Bearer Token
    ↓
Store Token Securely
    ↓
Access Protected APIs
```

---

# 📖 PDF Reading Flow

```text
Open Book
    ↓
Load PDF
    ↓
Track Current Page
    ↓
Save Progress
    ↓
Continue Reading
```

---

# 🧠 Recommendation System

Books are recommended based on:

- Favorite books
- Reading history
- User interests
- Popular books
- Tags
- Trending books

---

# 🌐 Localization

Localization files are stored in:

```bash
lib/l10n/
```

Example:

```json
{
  "library": "Library",
  "search": "Search"
}
```

---

# 🎨 Theme Support

Supports:

- Light Theme
- Dark Theme
- System Theme

---

# 🔒 Security Features

- Secure token storage
- Bearer authentication
- HTTPS support
- Session validation
- Protected APIs

---

# 📸 Application Screens

## Login Screen

- User authentication

## Library Screen

- Browse and discover books

## Search Screen

- Search books and suggestions

## Book Detail Screen

- Book information and actions

## PDF Reader Screen

- Read PDF books and annotations

## Favorite Screen

- User favorite books

## Profile Screen

- User profile and settings

---

# 🛠️ Development Requirements

## Flutter

```bash
Flutter 3.22+
```

---

## Dart

```bash
Dart 3.x
```

---

## Android SDK

```bash
Android SDK 34
```

---

## iOS

```bash
iOS 13+
```

---

# 📦 Build APK

```bash
flutter build apk --release
```

APK Output:

```bash
build/app/outputs/flutter-apk/app-release.apk
```

---

# 📦 Build App Bundle

```bash
flutter build appbundle --release
```

AAB Output:

```bash
build/app/outputs/bundle/release/app-release.aab
```

---

# 🍎 Build iOS

```bash
flutter build ios --release
```

---

# 🧹 Common Commands

## Clean Project

```bash
flutter clean
```

---

## Get Packages

```bash
flutter pub get
```

---

## Analyze Project

```bash
flutter analyze
```

---

## Run Project

```bash
flutter run
```

---

# 📚 Future Improvements

- Offline reading
- Download books
- Push notifications
- Audio books
- AI recommendations
- Reading analytics
- QR code login
- Chat system
- Admin dashboard

---

# 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push branch
5. Create pull request

---

# 📄 License

This project is licensed under the MIT License.

---

# 👮 Police Academy of Cambodia

Digital E-Library Platform for modern education and knowledge management.

---

# 👨‍💻 Developer

PAC E-Library Mobile Team

Built with ❤️ using Flutter + Laravel.

---

# ⭐ Support

If you like this project:

- Star this repository ⭐
- Fork this project 🍴
- Share with others 🚀

---
