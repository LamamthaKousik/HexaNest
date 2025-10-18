# Matru Mitra - Offline-First EHR Companion App

![Matru Mitra Logo](https://img.shields.io/badge/Matru%20Mitra-EHR%20Companion-red?style=for-the-badge&logo=health-and-safety)

An **offline-first Electronic Health Record (EHR) companion app** designed specifically for **ASHA and PHC workers** in low-internet rural areas of India. Built for **HackVerse 1.0 2025**.

## 🎯 Project Overview

Matru Mitra is a digital health record assistant that:
- Tracks **maternal and child health**, **immunization**, and **disease surveillance**
- Works seamlessly **offline-first** with local data storage
- **Auto-syncs** once network connectivity returns
- Provides **comprehensive reports** to supervisors for better health insights

## 🚀 Key Features

### 📱 Core Functionality
- **Patient Registration**: Complete patient data capture with validation
- **Offline Data Storage**: Local Hive database for reliable data persistence
- **Sync Simulation**: Background sync imitation with status indicators
- **Dashboard Analytics**: Real-time statistics and health insights
- **Patient Management**: Search, filter, and view patient records
- **Reports & Charts**: Visual analytics using fl_chart

### 🏥 Healthcare Focus
- **Maternal Health Tracking**: Pregnancy status monitoring
- **Child Health Records**: Immunization and growth tracking
- **Village-wise Organization**: Geographic data organization
- **Health ID Integration**: Unique patient identification
- **Visit History**: Comprehensive patient interaction logs

### 🔧 Technical Features
- **Material 3 Design**: Modern, accessible UI components
- **Offline-First Architecture**: Works without internet connectivity
- **State Management**: Riverpod for efficient state handling
- **Local Database**: Hive for fast, reliable data storage
- **Form Validation**: Comprehensive input validation
- **Responsive Design**: Optimized for various screen sizes

## 🛠️ Tech Stack

- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **State Management**: Riverpod
- **Local Database**: Hive
- **Charts**: fl_chart
- **UI**: Material 3 Design System
- **Architecture**: Offline-first with sync simulation

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  fl_chart: ^0.66.0
  intl: ^0.19.0
  uuid: ^4.2.1

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart 3.0 or higher
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd matrumitra
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Demo Credentials
- **Email**: `asha@matrumitra.com`
- **Password**: `asha123`

## 📱 App Screens

### 1. Splash Screen
- App logo and tagline
- Smooth animations
- Auto-navigation to login

### 2. Login Screen
- Dummy authentication
- Pre-filled demo credentials
- Material 3 design

### 3. Dashboard
- Quick statistics overview
- Main navigation grid
- Sync status indicator
- Recent activity feed

### 4. Patient Registration
- Comprehensive form with validation
- Health ID duplicate checking
- Offline data storage
- Real-time form validation

### 5. Patient List
- Search and filter functionality
- Sync status badges
- Patient detail modals
- Village-wise organization

### 6. Reports & Analytics
- Key statistics cards
- Sync status pie chart
- Pregnancy status bar chart
- Village distribution analysis

## 🎨 Design System

### Color Palette
- **Primary Red**: `#FF6B6B` (Care & Compassion)
- **Baby Blue**: `#89CFF0` (Trust & Calmness)
- **Success Green**: `#48BB78`
- **Warning Orange**: `#ED8936`
- **Error Red**: `#F56565`

### Typography
- **Headlines**: Bold, clear hierarchy
- **Body Text**: Readable, accessible
- **Captions**: Subtle, informative

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── patient_model.dart    # Patient data model
├── providers/
│   └── patient_provider.dart # State management
├── screens/
│   ├── splash_screen.dart    # App launch screen
│   ├── login_screen.dart     # Authentication
│   ├── dashboard_screen.dart # Main dashboard
│   ├── register_patient_screen.dart # Patient registration
│   ├── patient_list_screen.dart # Patient management
│   └── reports_screen.dart   # Analytics & reports
├── utils/
│   ├── colors.dart           # App color scheme
│   └── constants.dart        # App constants
└── widgets/
    └── custom_card.dart      # Reusable UI components
```

## 🔄 Offline-First Architecture

### Data Flow
1. **Local Storage**: All data stored in Hive database
2. **Sync Simulation**: Background sync with 2-second delay
3. **Status Tracking**: Visual indicators for sync status
4. **Conflict Resolution**: Last-write-wins strategy

### Sync Process
- **Automatic**: Triggers when sync button pressed
- **Visual Feedback**: Loading states and progress indicators
- **Error Handling**: Graceful failure with user notification
- **Status Updates**: Real-time sync status changes

## 📊 Features in Detail

### Patient Registration
- **Required Fields**: Name, Age, Gender, Village, Health ID, Pregnancy Status
- **Optional Fields**: Phone, Address, Notes
- **Validation**: Real-time form validation
- **Duplicate Prevention**: Health ID uniqueness checking

### Dashboard Analytics
- **Total Patients**: Complete patient count
- **Sync Status**: Synced vs Pending counts
- **Maternal Health**: Pregnant women tracking
- **Quick Actions**: Fast navigation to key features

### Reports & Charts
- **Pie Charts**: Sync status distribution
- **Bar Charts**: Pregnancy status breakdown
- **Progress Bars**: Village-wise patient distribution
- **Summary Cards**: Key metrics at a glance

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## 🚀 Deployment

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

## 🔮 Future Enhancements

### Planned Features
- **Multi-language Support**: Hindi, Telugu, and other regional languages
- **GPS Integration**: Village location tagging
- **Photo Capture**: Patient photo documentation
- **Backup & Restore**: Data export/import functionality
- **Offline Maps**: Village navigation support
- **Push Notifications**: Appointment reminders
- **Biometric Authentication**: Enhanced security

### Technical Improvements
- **Real Backend Integration**: Replace sync simulation
- **Cloud Storage**: AWS/Azure integration
- **Advanced Analytics**: Machine learning insights
- **API Integration**: Government health databases
- **Performance Optimization**: Faster data processing

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏆 Hackathon Information

- **Event**: HackVerse 1.0 2025
- **Category**: Healthcare Technology
- **Target Users**: ASHA Workers, PHC Staff, Rural Healthcare Providers

## 📞 Support

For support, email `support@matrumitra.com` or create an issue in the repository.

## 🙏 Acknowledgments

- **ASHA Workers**: For their invaluable feedback and requirements
- **Rural Healthcare Providers**: For their insights into offline-first needs
- **Flutter Community**: For excellent documentation and support
- **HackVerse 1.0**: For providing the platform to showcase this solution

---

**Built with ❤️ for better healthcare in rural India**