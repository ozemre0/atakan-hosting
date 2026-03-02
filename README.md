# Atakan Hosting Management System

A modern and user-friendly hosting management system. Built with Flutter, this cross-platform application allows you to easily manage your customers, hosting services, domain registrations, and SSL certificates.

## Features

### 📊 Dashboard
- Overview and statistics
- Summary of active and expired services
- List of services expiring soon
- Quick access links

### 👥 Customer Management
- Add, edit, and delete customers
- Customer details and service history
- Customer number, contact information, and tax information management
- Search and sorting features

### 🌐 Service Management
- **Hosting Services**: FTP credentials, start/end dates, payment tracking
- **Domain Registrations**: Domain name, NS records, expiration tracking
- **SSL Certificates**: SSL certificate management and expiration tracking
- Service status filtering (Active/Passive/Expired)
- Detailed service information and editing

### ⚙️ Settings
- API configuration
- Theme selection (Light/Dark/System)
- Language selection (Turkish/English)
- Admin password management

### 🎨 User Experience
- Modern and clean interface
- Responsive design (mobile, tablet, desktop)
- Dark mode support
- Multi-language support (Turkish/English)
- Fast and smooth navigation

## 📱 Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🛠️ Technologies

- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **Riverpod** - State management
- **GoRouter** - Routing and navigation
- **Dio** - HTTP client
- **SharedPreferences** - Local data storage
- **Flutter Localizations** - Multi-language support

## 📋 Requirements
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code / IntelliJ IDEA
- Git

## ☁️ Backend Worker (Cloudflare Workers)
The project includes a Cloudflare Worker backend located in `worker/atakan_worker.js`. This worker provides the REST API for the Flutter application.

### Worker Features
- RESTful API endpoints
- SQLite database (Cloudflare D1)
- Authentication with token-based system
- CORS support
- CSV,Excel export functionality
- Automatic schema creation

## 📦 Build
### Android
```bash
flutter build apk
# or
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

### Windows
```bash
flutter build windows
```

## 📄 License
This is a private project. All rights reserved.

## 👤 Developer
**Emre Oz**
- GitHub: [@ozemre0](https://github.com/ozemre0)
