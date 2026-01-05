# 📦 Hướng dẫn thêm Lottie Animation cho Empty State

## 🎨 File cần tải từ LottieFiles:

### 1. Empty Wallet Animation (Khuyến nghị)

**Tên file**: `empty_wallet.json`  
**Đặt vào**: `assets/lottie/empty_wallet.json`

**Gợi ý animation trên LottieFiles**:

- Tìm kiếm: "empty wallet", "no money", "wallet empty"
- Style: Cute, 3D hoặc Flat design
- Màu sắc: Xanh dương, vàng, trắng (match với theme app)

**Link tham khảo**:

- https://lottiefiles.com/search?q=empty%20wallet
- https://lottiefiles.com/search?q=no%20transaction

### 2. Piggy Bank Sleep Animation (Tùy chọn)

**Tên file**: `piggy_bank_sleep.json`  
**Đặt vào**: `assets/lottie/piggy_bank_sleep.json`

**Gợi ý**:

- Tìm kiếm: "piggy bank sleep", "saving money cute"
- Style: Cartoon, friendly

### 3. Search No Data Animation (Tùy chọn)

**Tên file**: `search_no_data.json`  
**Đặt vào**: `assets/lottie/search_no_data.json`

## 📥 Cách tải Lottie từ LottieFiles:

1. Vào https://lottiefiles.com
2. Tìm kiếm animation bạn thích
3. Click vào animation
4. Click nút **"Download"** → Chọn **"Lottie JSON"**
5. Đổi tên file thành tên gợi ý ở trên
6. Copy file vào folder `assets/lottie/`

## 🎯 Sau khi có file Lottie:

Code đã được chuẩn bị sẵn trong `dashboard_screen.dart`.  
Chỉ cần:

1. Đặt file `empty_wallet.json` vào `assets/lottie/`
2. Uncomment dòng Lottie.asset() trong code
3. Comment dòng Icon hiện tại
4. Run `flutter pub get`
5. Reload app!

## 💡 Lưu ý:

- File Lottie nên < 100KB để load nhanh
- Chọn animation loop (lặp lại) cho vui
- Màu sắc nên match với theme xanh dương của app
