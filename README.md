# Atakan Hosting Management System

A modern and user-friendly hosting management system. Built with Flutter, this cross-platform application allows you to easily manage your customers, hosting services, domain registrations, and SSL certificates.

## 🚀 Features

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

## 🔧 Installation

1. **Clone the repository:**
```bash
git clone https://github.com/ozemre0/atakan-hosting.git
cd atakan-hosting
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Run the application:**
```bash
flutter run
```

## 🏗️ Project Structure

```
lib/
├── app/                    # Application-level code
│   ├── api/               # API client and data providers
│   ├── auth/              # Authentication
│   ├── l10n/              # Localization helpers
│   ├── router/            # Routing configuration
│   ├── settings/          # Application settings
│   ├── theme/             # Theme configuration
│   └── widgets/           # Common widgets
├── features/              # Feature-based modules
│   ├── auth/             # Login screens
│   ├── config/           # Configuration screens
│   ├── customers/        # Customer management
│   ├── dashboard/        # Dashboard screen
│   ├── services/         # Service management (hosting, domain, SSL)
│   └── settings/         # Settings screen
└── l10n/                 # Localization files
    ├── app_en.arb        # English translations
    └── app_tr.arb        # Turkish translations
```

## 🔐 Initial Setup

1. When you first open the application, you will need to set an admin username and password.
2. Configure the API Base URL (Settings > API Settings).
3. The application is ready!

## 📝 API Configuration

The application communicates with a backend API. You can configure the API Base URL from the settings screen.

API endpoints:
- `/dashboard` - Dashboard data
- `/customers` - Customer operations
- `/hostings` - Hosting service operations
- `/domains` - Domain operations
- `/ssls` - SSL certificate operations

## 🌍 Language Support

The application supports the following languages:
- 🇹🇷 Turkish
- 🇬🇧 English

Language setting can be changed from the Settings screen.

## 🎨 Theme

The application supports three theme modes:
- ☀️ Light Theme
- 🌙 Dark Theme
- 🔄 System Theme (follows device setting)

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

## 👤 Developer

**Emre Oz**
- GitHub: [@ozemre0](https://github.com/ozemre0)

## 📞 Contact

For questions or suggestions, please use GitHub Issues.

---

⭐ If you like this project, don't forget to give it a star!
