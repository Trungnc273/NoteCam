# 🚀 Chạy App Trên Android

## ✅ Đã Sửa Tất Cả Lỗi

- ✅ Thêm import `Note` model vào `fake_notepad_screen.dart`
- ✅ Xóa biến `_shakeSearch` không sử dụng
- ✅ Xóa hàm `_createNewNote` không sử dụng
- ✅ Sửa lỗi `use_build_context_synchronously`
- ✅ Xóa biến `_previewItem` không sử dụng
- ✅ File `note.g.dart` đã được generate
- ✅ Code đã clean và không có lỗi

---

## 📱 Cách Chạy Trên Android Studio

### Bước 1: Mở Project trong Android Studio

1. Mở Android Studio
2. File → Open → Chọn folder `NoteCam`
3. Đợi Android Studio index project

### Bước 2: Khởi động Android Emulator

**Option A: Từ Android Studio**
1. Click vào AVD Manager (icon điện thoại ở toolbar)
2. Chọn emulator (Pixel 3a hoặc bất kỳ device nào)
3. Click nút Play để khởi động

**Option B: Từ Terminal**
```bash
flutter emulators --launch Pixel_3a
```

### Bước 3: Chạy App

**Option A: Từ Android Studio**
1. Đợi emulator khởi động xong (màn hình home hiện ra)
2. Chọn device từ dropdown ở toolbar
3. Click nút Run (icon play màu xanh) hoặc nhấn Shift+F10

**Option B: Từ Terminal**
```bash
cd NoteCam
flutter run
```

---

## 🔧 Nếu Gặp Lỗi

### Lỗi: "part 'note.g.dart' not found"

**Giải pháp:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Lỗi: "Gradle build failed"

**Giải pháp:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Lỗi: "No devices found"

**Giải pháp:** Khởi động emulator
```bash
flutter emulators
flutter emulators --launch Pixel_3a
```

### Emulator chạy chậm

**Giải pháp:**
1. Đảm bảo Intel HAXM hoặc AMD Hypervisor đã được cài đặt
2. Trong AVD Manager, edit emulator và tăng RAM/Storage
3. Enable Hardware acceleration trong BIOS

---

## 📋 Checklist Trước Khi Chạy

- [x] Flutter SDK đã cài đặt
- [x] Android Studio đã cài đặt
- [x] Android SDK đã cài đặt
- [x] Emulator đã được tạo
- [x] Dependencies đã được cài (`flutter pub get`)
- [x] File `note.g.dart` đã được generate
- [x] Code không có lỗi

---

## 🎯 Sau Khi App Chạy

### Test các tính năng:

1. **Splash Screen** → Tự động chuyển sang Onboarding
2. **Onboarding** → Swipe qua các màn hình → Tap "Bắt đầu"
3. **Notepad Screen** → Màn hình chính với danh sách notes
4. **Create Note**:
   - Tap nút "+" ở góc trên
   - Chọn tag (Công việc, Cá nhân, etc.)
   - Tap "Tạo ghi chú"
   - Nhập title và body
   - Tap back → Note tự động save
5. **Edit Note**:
   - Tap vào note trong danh sách
   - Chỉnh sửa nội dung
   - Tap back → Changes tự động save
6. **Delete Note**:
   - Mở note
   - Tap icon "..." ở góc trên
   - Chọn "Xóa ghi chú"
7. **Search**:
   - Nhập text vào search bar
   - Kết quả filter real-time
8. **Star Note**:
   - Mở note
   - Tap icon star
9. **Vault** (Hidden feature):
   - Nhập "hidden" vào search bar
   - Tap vào Vault card
   - Nhập PIN: 1234

---

## 📱 Build APK (Optional)

Để build APK file để cài trên thiết bị thật:

```bash
flutter build apk --release
```

File APK sẽ được tạo tại:
```
NoteCam/build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎉 Hoàn Tất!

App đã sẵn sàng để chạy trên Android. Mọi lỗi đã được sửa và code đã được tối ưu hóa.

**Lưu ý:** App này được thiết kế cho mobile (Android/iOS), không phải web hoặc desktop.
