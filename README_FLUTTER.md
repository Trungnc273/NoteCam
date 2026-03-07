# NoteCam — Flutter Mobile App

> Ứng dụng ghi chú có không gian ẩn (Vault) được chuyển đổi từ React sang Flutter

---

## Tổng quan

**NoteCam** là ứng dụng mobile Flutter được chuyển đổi từ dự án React prototype. Ứng dụng mô phỏng một app ghi chú bình thường nhưng có **không gian ẩn (Vault)** để lưu trữ ảnh, video và ghi âm riêng tư một cách bảo mật.

---

## Tech Stack

| Công nghệ | Phiên bản | Mục đích |
|---|---|---|
| Flutter | 3.10+ | Mobile framework |
| Dart | 3.10+ | Programming language |
| Provider | ^6.1.2 | State management |
| GoRouter | ^14.6.2 | Navigation |
| Flutter Animate | ^4.5.0 | Animations |
| Lucide Icons | ^1.2.0 | Icon set |
| Cached Network Image | ^3.3.1 | Image caching |

---

## Cấu trúc dự án

```
lib/
├── main.dart                    # Entry point, routing setup
├── models/
│   └── note.dart               # Note model & mock data
├── providers/
│   └── app_state.dart          # Global state management
├── screens/
│   ├── splash_screen.dart      # Màn khởi động
│   ├── onboarding_screen.dart  # Màn giới thiệu
│   ├── fake_notepad_screen.dart# Giao diện ngụy trang
│   ├── note_edit_screen.dart   # Màn soạn/chỉnh sửa ghi chú
│   ├── vault_screen.dart       # Không gian ẩn
│   ├── settings_screen.dart    # Cài đặt ứng dụng
│   └── black_screen.dart       # Chế độ màn hình đen
└── widgets/
    └── vault_pin_modal.dart    # Modal nhập PIN
```

---

## Tính năng chính

### 1. Vault Access — 3 cách mở khóa

#### Cách 1 — Keyword "hidden"
- Gõ "hidden" vào thanh tìm kiếm → Hiện card Vault
- Tap vào card → Nhập PIN "2580" → Vào Vault

#### Cách 2 — Mã số "2580" + Enter
- Gõ "2580" vào thanh tìm kiếm → Enter
- Modal PIN xuất hiện → Nhập "2580" → Vào Vault

#### Cách 3 — Triple Tap trên Black Screen
- Chạm 3 lần liên tiếp (trong 800ms)
- Flash trắng → Vào Vault trực tiếp

### 2. Fake Notepad
- Hiển thị 5 ghi chú mock với tag màu, star, preview
- Search bar hoạt động bình thường
- Không có dấu hiệu Vault ẩn

### 3. Vault Screen
- 3 tab: Ảnh (grid 3 cột), Video (list), Ghi âm (list)
- Tap để preview full screen
- Header có nút Settings và Back

### 4. Settings Screen
- **Giao diện**: Haptic feedback, Đổi chế độ (Notepad/Black)
- **Hành động nhanh**: Tùy chỉnh phím tắt cho Chụp ảnh, Quay video, Ghi âm
- **Conflict detection**: Cảnh báo khi gán trùng thao tác
- **Bảo mật**: Đổi PIN, Panic Mode
- **Thông tin**: Version info

### 5. Black Screen Mode
- Màn hình đen hoàn toàn
- Hint text mờ: "Tap 3 times to open Vault"
- Ripple effect khi tap

---

## PIN mặc định

```
2580
```

---

## Cài đặt & Chạy

### 1. Cài đặt dependencies

```bash
cd NoteCam
flutter pub get
```

### 2. Chạy ứng dụng

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Hoặc chọn device cụ thể
flutter devices
flutter run -d <device_id>
```

### 3. Build APK (Android)

```bash
flutter build apk --release
```

### 4. Build iOS

```bash
flutter build ios --release
```

---

## So sánh React vs Flutter

| Tính năng | React (Web) | Flutter (Mobile) |
|---|---|---|
| Animation | Framer Motion | Flutter Animate |
| Navigation | Manual state | GoRouter |
| State Management | useState/useCallback | Provider |
| Styling | Tailwind CSS | Material Design + Custom |
| Icons | Lucide React | Lucide Icons Flutter |
| Image Loading | Native | Cached Network Image |

---

## Lưu ý

- Đây là **UI prototype**, không có backend thực tế
- Dữ liệu ghi chú, ảnh, video, audio đều là mock
- PIN và settings được lưu trong memory, sẽ reset khi restart app
- Để lưu trữ persistent, cần tích hợp SharedPreferences hoặc Hive

---

## Các bước tiếp theo (nếu phát triển thực tế)

1. Tích hợp SharedPreferences để lưu settings
2. Tích hợp Camera/Gallery picker cho Vault
3. Tích hợp Audio recorder
4. Mã hóa dữ liệu thực tế (AES-256)
5. Biometric authentication (Face ID / Fingerprint)
6. Cloud backup (Firebase Storage)
7. Thêm tests (unit tests, widget tests)

---

## Cấu trúc Navigation

```
/splash → /onboarding → /notepad (hoặc /black-screen)
                          ├─► /note-edit/:id
                          ├─► /vault
                          │     └─► /settings
                          └─► /black-screen → /vault
```

---

## Màu sắc chính

```dart
Background: Color(0xFF09090B)  // Zinc-950
Card: Color(0xFF18181B)        // Zinc-900
Border: Color(0xFF27272A)      // Zinc-800
Text Primary: Colors.white
Text Secondary: Color(0xFF71717A)  // Zinc-500
Text Tertiary: Color(0xFF52525B)   // Zinc-600
Accent: Colors.white
Error: Color(0xFFEF4444)       // Red-500
```

---

## License

Demo project - No real functionality
