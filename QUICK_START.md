# 🚀 Quick Start Guide - NoteCam

## ✅ Đã Hoàn Thành

File `note.g.dart` đã được generate thành công! App đã sẵn sàng để chạy.

---

## 🎯 Cách Chạy App

### Option 1: Android Emulator (Khuyến nghị)

```bash
# 1. Khởi động emulator
flutter emulators --launch Pixel_3a

# 2. Đợi emulator khởi động xong (30-60 giây)

# 3. Chạy app
flutter run
```

### Option 2: Windows Desktop

**Yêu cầu:** Phải bật Developer Mode trên Windows

1. Mở Settings: `start ms-settings:developers`
2. Bật "Developer Mode"
3. Restart máy nếu cần
4. Chạy app:
```bash
flutter run -d windows
```

### Option 3: Web Browser (Có hạn chế)

⚠️ **Lưu ý:** Một số tính năng có thể không hoạt động đầy đủ trên web (như secure storage)

```bash
flutter run -d chrome
```

---

## 🔧 Nếu Gặp Lỗi

### Lỗi: "part 'note.g.dart' not found"

**Giải pháp:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Lỗi: "Building with plugins requires symlink support"

**Giải pháp:** Bật Developer Mode trên Windows
1. Run: `start ms-settings:developers`
2. Enable "Developer Mode"
3. Restart máy

### Lỗi: "No devices found"

**Giải pháp:** Khởi động emulator
```bash
flutter emulators --launch Pixel_3a
```

---

## 📱 Kiểm Tra Devices

```bash
# Xem danh sách devices đang kết nối
flutter devices

# Xem danh sách emulators có sẵn
flutter emulators
```

---

## 🧪 Testing Features

Sau khi app chạy thành công:

1. **Create Note**: Tap nút "+" → Chọn tag → Tạo ghi chú
2. **Edit Note**: Tap vào note → Chỉnh sửa → Tap back (auto-save)
3. **Delete Note**: Mở note → Tap "..." → Xóa ghi chú
4. **Search**: Nhập text vào search bar
5. **Star Note**: Mở note → Tap icon star

---

## 📚 Documentation

- **BUILD_INSTRUCTIONS.md**: Chi tiết build instructions
- **IMPLEMENTATION_COMPLETE.md**: Implementation checklist
- **STORAGE_IMPLEMENTATION.md**: Storage architecture
- **MIGRATION_GUIDE.md**: React to Flutter migration

---

## ✅ Current Status

- ✅ Dependencies installed
- ✅ Hive adapters generated (`note.g.dart`)
- ✅ All code files ready
- ⏳ Waiting for device/emulator to run

**Next Step:** Chạy `flutter run` sau khi emulator khởi động!
