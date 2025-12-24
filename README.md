# Personal Expense Manager

A personal expense management application built with Flutter, helping users track spending habits and manage budgets efficiently. Data is stored securely offline on the device.

## 🌟 Key Features

- **Transaction Recording**: Add, edit, delete daily income and expense transactions.
- **Category Management**: Customize spending categories (Food, Transport, Shopping, etc.).
- **Budget & Savings**: Set savings goals and track progress.
- **Visual Statistics**: Detailed charts on financial status (using `fl_chart`).
- **Offline Operation**: Data is stored locally, no internet connection required.
- **Modern UI**: Designed following Material Design 3 standards.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: Dart
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [Hive](https://pub.dev/packages/hive) (NoSQL, fast and lightweight)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)

## 🚀 Installation & Run

1. **Clone the project:**
   ```bash
   git clone https://github.com/TN412/doanflutter.git
   cd doanflutter
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Build installer (Android):**
   - APK: `flutter build apk --release`
   - App Bundle: `flutter build appbundle --release`

## 📂 Folder Structure

```text
lib/
├── models/          # Data models (Hive Objects)
├── providers/       # State Management
├── screens/         # UI Screens
├── services/        # Data storage logic
├── utils/           # Utilities
└── main.dart        # App entry point
```

## 👤 Author

- **GitHub**: [TN412](https://github.com/TN412)

---
*This project is developed for learning and practicing Flutter.*
