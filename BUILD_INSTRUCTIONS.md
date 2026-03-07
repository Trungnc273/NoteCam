# Build Instructions - NoteCam Flutter

## ✅ Implementation Status

### Completed Features:
- ✅ Persistent storage với Hive + SharedPreferences + Flutter Secure Storage
- ✅ Note model với Hive annotations
- ✅ StorageService với CRUD operations
- ✅ NotesProvider cho state management
- ✅ FakeNotepadScreen sử dụng NotesProvider
- ✅ NoteEditScreen với auto-save và delete functionality
- ✅ New note creation với tag selection
- ✅ Search functionality
- ✅ Mock data initialization on first run

### Ready to Test:
- Create new notes với tag selection
- Edit và auto-save notes
- Delete notes
- Search notes by title/body
- Star/unstar notes
- Persistent storage across app restarts

---

## Bước 1: Install dependencies

```bash
cd NoteCam
flutter pub get
```

## Bước 2: Generate Hive adapters (BẮT BUỘC)

Chạy lệnh sau để generate file `note.g.dart`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

⚠️ **QUAN TRỌNG:** Phải chạy lệnh này trước khi run app, nếu không sẽ gặp lỗi "part 'note.g.dart' not found"

Hoặc nếu muốn watch mode (tự động generate khi có thay đổi):

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Bước 3: Run app

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Hoặc chọn device cụ thể
flutter devices
flutter run -d <device_id>
```

---

## Testing the Features

### 1. Create New Note
- Tap nút "+" ở góc trên bên phải
- Chọn tag (Công việc, Cá nhân, Dự án, Kế hoạch, Nhật ký)
- Tap "Tạo ghi chú"
- Nhập title và body
- Tap back button → note tự động save

### 2. Edit Note
- Tap vào note trong danh sách
- Chỉnh sửa title/body
- Tap back button → changes tự động save

### 3. Delete Note
- Mở note
- Tap icon "..." ở góc trên bên phải
- Chọn "Xóa ghi chú"
- Confirm deletion

### 4. Search Notes
- Nhập text vào search bar
- Kết quả filter theo title và body
- Clear search để xem tất cả notes

### 5. Star/Unstar Note
- Mở note
- Tap icon star ở header
- Note được đánh dấu starred

---

## Troubleshooting

### Lỗi: "part 'note.g.dart' not found"

**Giải pháp:** Chạy build_runner để generate file:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Lỗi: "Conflicting outputs"

**Giải pháp:** Thêm flag `--delete-conflicting-outputs`:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Lỗi: "MissingPluginException"

**Giải pháp:** 
1. Stop app
2. Chạy `flutter clean`
3. Chạy `flutter pub get`
4. Rebuild app

### Notes không persist sau khi restart app

**Kiểm tra:**
1. Đã chạy `flutter pub run build_runner build` chưa?
2. File `note.g.dart` đã được generate chưa?
3. Check console logs để xem có error từ Hive không

---

## Storage Structure

### Hive Boxes:
- `notes` - Lưu trữ ghi chú (Note objects)

### SharedPreferences:
- `haptic_feedback` - bool
- `display_mode` - string ('notepad' | 'black')
- `photo_action` - string
- `video_action` - string
- `audio_action` - string

### Flutter Secure Storage:
- `vault_pin` - string (encrypted)

---

## Clean Build

Nếu gặp lỗi lạ, thử clean build:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Next Steps (Optional Enhancements)

Các tính năng có thể thêm sau:
- [ ] Tag management (add/edit/delete custom tags)
- [ ] Note sorting options (by date, title, tag)
- [ ] Export/import notes
- [ ] Rich text formatting
- [ ] Attachments (images, files)
- [ ] Note sharing
- [ ] Backup/restore functionality
