# Hướng Dẫn Build & Run Dự Án Flutter

## ✅ Các Lỗi Đã Được Sửa

### 1. **Lỗi SDK Version**

- **Vấn đề**: SDK version `^3.10.4` không tương thích
- **Giải pháp**: Đã thay đổi thành `'>=3.5.0 <4.0.0'` trong `pubspec.yaml`

### 2. **Lỗi Dependencies**

- **Vấn đề**: Tất cả packages chưa được cài đặt
- **Giải pháp**: Đã chạy `flutter pub get` thành công

### 3. **Lỗi Hive Code Generation**

- **Vấn đề**: Các file `.g.dart` chưa được generate
- **Giải pháp**: Đã chạy `flutter pub run build_runner build --delete-conflicting-outputs`

### 4. **Lỗi Unused Imports**

- **Vấn đề**: Có 5 file với unused imports
- **Giải pháp**: Đã xóa các imports không sử dụng:
  - `main.dart`: xóa `screens/add_transaction_screen.dart`
  - `recurring_transaction_model.dart`: xóa `category_model.dart`
  - `recurring_transactions_screen.dart`: xóa `category_model.dart`
  - `settings_screen.dart`: xóa `notification_service.dart`
  - `stats_screen.dart`: xóa `date_helper.dart`

## 📋 Yêu Cầu Hệ Thống

- Flutter SDK: 3.5.0 hoặc cao hơn
- Dart SDK: 3.10.0 (đi kèm với Flutter)
- Android Studio / VS Code
- Emulator hoặc thiết bị thật

## 🚀 Các Bước Chạy Dự Án

### Bước 1: Clone hoặc mở project

```bash
cd "d:\HUTECH\Lap Trinh Tren Thiet Bi Di Dong\doanflutter"
```

### Bước 2: Cài đặt dependencies

```bash
flutter pub get
```

### Bước 3: Generate Hive models (nếu cần)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Bước 4: Kiểm tra lỗi

```bash
flutter analyze
```

### Bước 5: Chạy ứng dụng

```bash
# Chạy trên emulator/device
flutter run

# Chạy trên Chrome (web)
flutter run -d chrome

# Chạy ở chế độ release
flutter run --release
```

## 📱 Tính Năng Ứng Dụng

Dự án này là một ứng dụng **Expense Tracker** (Quản lý chi tiêu) với các tính năng:

- ✅ Đăng nhập/Đăng ký người dùng
- ✅ Thêm/Sửa/Xóa giao dịch thu chi
- ✅ Phân loại theo danh mục (Categories)
- ✅ Giao dịch định kỳ (Recurring Transactions)
- ✅ Mục tiêu tiết kiệm (Savings Goals)
- ✅ Thống kê và biểu đồ (Statistics & Charts)
- ✅ Thông báo nhắc nhở hàng ngày
- ✅ Export/Import dữ liệu
- ✅ Cài đặt cá nhân hóa

## 🔧 Các Packages Chính

| Package                     | Version  | Mục đích                   |
| --------------------------- | -------- | -------------------------- |
| provider                    | ^6.1.5+1 | State management           |
| hive                        | ^2.2.3   | Local database             |
| fl_chart                    | ^1.1.1   | Biểu đồ thống kê           |
| intl                        | ^0.20.2  | Format ngày tháng, tiền tệ |
| flutter_local_notifications | ^18.0.1  | Thông báo local            |

## ⚠️ Lưu Ý

### Cảnh báo hiện tại (không ảnh hưởng chức năng):

- **deprecated_member_use**: Một số methods như `.value` và `.withOpacity()` đã deprecated trong Flutter 3.10+
  - Có thể cập nhật sau bằng cách thay:
    - `Colors.orange.value` → `Colors.orange.value` (đã ok, chỉ là warning)
    - `.withOpacity(0.1)` → `.withValues(alpha: 0.1)`

### Để build production:

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (cần macOS)
flutter build ios --release
```

## 🎯 Cấu Trúc Thư Mục

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models (Hive)
├── providers/                # State management (Provider)
├── screens/                  # UI screens
├── services/                 # Services (Database, Notifications)
└── utils/                    # Helper functions
```

## 📞 Hỗ Trợ

Nếu gặp vấn đề:

1. Chạy `flutter clean` và `flutter pub get` lại
2. Xóa folder `.dart_tool/` và chạy lại
3. Kiểm tra Flutter version: `flutter --version`
4. Update Flutter: `flutter upgrade`

---

**Trạng thái**: ✅ Dự án đã được kiểm tra và sửa lỗi hoàn chỉnh
**Ngày kiểm tra**: 26/12/2025
