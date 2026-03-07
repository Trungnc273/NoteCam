# Storage Implementation Guide

## Tổng quan

NoteCam sử dụng 3 loại storage khác nhau cho các mục đích khác nhau:

1. **Hive** - Lưu trữ ghi chú (notes)
2. **SharedPreferences** - Lưu trữ settings
3. **Flutter Secure Storage** - Lưu trữ PIN (encrypted)

---

## 1. Hive - Notes Storage

### Tại sao dùng Hive?
- ✅ Nhanh hơn SQLite
- ✅ Không cần SQL
- ✅ Type-safe với code generation
- ✅ Hỗ trợ encryption
- ✅ Cross-platform (mobile + web)

### Cấu trúc Note Model

```dart
@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) String body;
  @HiveField(3) String tag;
  @HiveField(4) bool starred;
  @HiveField(5) DateTime createdAt;
  @HiveField(6) DateTime updatedAt;
}
```

### CRUD Operations

```dart
// Create
final note = Note(id: '1', title: 'Test', ...);
await StorageService.saveNote(note);

// Read
final note = StorageService.getNote('1');
final allNotes = StorageService.getAllNotes();

// Update
note.title = 'Updated';
await StorageService.updateNote('1', note);

// Delete
await StorageService.deleteNote('1');

// Search
final results = StorageService.searchNotes('keyword');
```

---

## 2. SharedPreferences - Settings Storage

### Tại sao dùng SharedPreferences?
- ✅ Đơn giản cho key-value storage
- ✅ Tốt cho settings nhỏ
- ✅ Native support trên iOS/Android

### Settings được lưu

```dart
// Haptic Feedback
bool haptic = StorageService.getHapticFeedback();
await StorageService.setHapticFeedback(true);

// Display Mode
String mode = StorageService.getDisplayMode(); // 'notepad' | 'black'
await StorageService.setDisplayMode('notepad');

// Quick Actions
String photoAction = StorageService.getPhotoAction();
await StorageService.setPhotoAction('Volume Up – 1 lần');
```

---

## 3. Flutter Secure Storage - PIN Storage

### Tại sao dùng Secure Storage?
- ✅ Encrypted storage
- ✅ Sử dụng Keychain (iOS) / KeyStore (Android)
- ✅ An toàn cho sensitive data

### PIN Operations

```dart
// Get PIN
String pin = await StorageService.getVaultPin();

// Set PIN
await StorageService.setVaultPin('2580');
```

---

## Provider Architecture

### NotesProvider

Quản lý state của notes và sync với Hive:

```dart
class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  
  // Load from storage
  Future<void> loadNotes() async {
    _notes = StorageService.getAllNotes();
    notifyListeners();
  }
  
  // Create note
  Future<Note> createNote({...}) async {
    final note = Note(...);
    await StorageService.saveNote(note);
    await loadNotes(); // Refresh
    return note;
  }
  
  // Update note
  Future<void> updateNote(Note note) async {
    await StorageService.updateNote(note.id, note);
    await loadNotes(); // Refresh
  }
}
```

### AppState Provider

Quản lý settings và sync với SharedPreferences:

```dart
class AppState extends ChangeNotifier {
  bool _hapticFeedback = true;
  
  Future<void> init() async {
    _hapticFeedback = StorageService.getHapticFeedback();
    notifyListeners();
  }
  
  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    await StorageService.setHapticFeedback(value);
    notifyListeners();
  }
}
```

---

## Usage trong Screens

### FakeNotepadScreen

```dart
class FakeNotepadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final notes = notesProvider.notes;
    
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(note: note);
      },
    );
  }
}
```

### NoteEditScreen

```dart
class NoteEditScreen extends StatefulWidget {
  final String noteId;
  
  @override
  Widget build(BuildContext context) {
    final notesProvider = context.read<NotesProvider>();
    
    // Get existing note or create new
    final note = noteId == '0' 
      ? null 
      : notesProvider.getNoteById(noteId);
    
    // Save on change
    void _saveNote() async {
      if (noteId == '0') {
        await notesProvider.createNote(
          title: _titleController.text,
          body: _bodyController.text,
        );
      } else {
        await notesProvider.updateNote(
          note!.copyWith(
            title: _titleController.text,
            body: _bodyController.text,
          ),
        );
      }
    }
  }
}
```

### SettingsScreen

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    return Switch(
      value: appState.hapticFeedback,
      onChanged: (value) {
        appState.setHapticFeedback(value);
      },
    );
  }
}
```

---

## Data Flow

```
User Action
    ↓
Screen (UI)
    ↓
Provider (State Management)
    ↓
StorageService (Abstraction Layer)
    ↓
Hive / SharedPreferences / Secure Storage
    ↓
Disk Storage
```

---

## Initialization Flow

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize storage
  await StorageService.init();
  
  // 2. Create providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..init()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: const NoteCamApp(),
    ),
  );
}
```

---

## Best Practices

### 1. Always await storage operations
```dart
// ❌ Bad
StorageService.saveNote(note);

// ✅ Good
await StorageService.saveNote(note);
```

### 2. Refresh provider after storage changes
```dart
Future<void> updateNote(Note note) async {
  await StorageService.updateNote(note.id, note);
  await loadNotes(); // Refresh UI
}
```

### 3. Handle errors gracefully
```dart
try {
  await StorageService.saveNote(note);
} catch (e) {
  debugPrint('Error saving note: $e');
  // Show error to user
}
```

### 4. Use copyWith for immutability
```dart
final updated = note.copyWith(
  title: 'New Title',
  updatedAt: DateTime.now(),
);
```

---

## Migration từ Mock Data

### Before (Mock Data)
```dart
final List<Note> mockNotes = [
  Note(id: 1, title: 'Test', ...),
];
```

### After (Hive Storage)
```dart
// Initialize with mock data if empty
if (StorageService.notesBox.isEmpty) {
  final mockNotes = getMockNotes();
  for (final note in mockNotes) {
    await StorageService.saveNote(note);
  }
}
```

---

## Testing

### Unit Tests
```dart
test('should save and retrieve note', () async {
  await StorageService.init();
  
  final note = Note(id: '1', title: 'Test', ...);
  await StorageService.saveNote(note);
  
  final retrieved = StorageService.getNote('1');
  expect(retrieved?.title, 'Test');
});
```

### Widget Tests
```dart
testWidgets('should display notes from provider', (tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => NotesProvider(),
      child: MaterialApp(home: FakeNotepadScreen()),
    ),
  );
  
  await tester.pumpAndSettle();
  expect(find.text('Họp 10h sáng'), findsOneWidget);
});
```

---

## Performance Tips

1. **Lazy Loading**: Chỉ load notes khi cần
2. **Pagination**: Nếu có nhiều notes (>1000)
3. **Debounce**: Delay save khi user đang typing
4. **Background Save**: Save trong background thread

---

## Future Enhancements

1. **Encryption**: Encrypt notes box cho privacy
2. **Sync**: Cloud sync với Firebase/Supabase
3. **Backup**: Export/Import notes
4. **Search Index**: Full-text search với Hive
5. **Attachments**: Lưu ảnh/file đính kèm
