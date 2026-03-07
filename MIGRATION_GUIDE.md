# Migration Guide: React to Flutter

Tài liệu này giải thích cách dự án NoteCam được chuyển đổi từ React sang Flutter.

---

## Tổng quan chuyển đổi

### React (Web Prototype) → Flutter (Mobile App)

| Khía cạnh | React | Flutter |
|---|---|---|
| **Language** | TypeScript | Dart |
| **UI Framework** | React Components | Flutter Widgets |
| **State Management** | useState, useCallback | Provider |
| **Navigation** | Manual state switching | GoRouter |
| **Styling** | Tailwind CSS v4 | Material Design + Custom Widgets |
| **Animation** | Framer Motion (motion/react) | Flutter Animate |
| **Icons** | Lucide React | Lucide Icons Flutter |

---

## Chi tiết chuyển đổi từng phần

### 1. State Management

**React (useState + Context):**
```typescript
const [navState, setNavState] = useState<NavState>({
  screen: "splash",
});

const navigate = useCallback((screen: string, opts?: { noteId?: number }) => {
  setNavState({ screen: screen as ScreenName, ...opts });
}, []);
```

**Flutter (Provider):**
```dart
class AppState extends ChangeNotifier {
  bool _hapticFeedback = true;
  String _displayMode = 'notepad';
  
  void setHapticFeedback(bool value) {
    _hapticFeedback = value;
    notifyListeners();
  }
}

// Usage
final appState = context.watch<AppState>();
```

---

### 2. Navigation

**React (Manual State):**
```typescript
<AnimatePresence mode="wait">
  {screen === "splash" && <SplashScreen onNavigate={navigate} />}
  {screen === "vault" && <VaultScreen onNavigate={navigate} />}
</AnimatePresence>
```

**Flutter (GoRouter):**
```dart
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/vault', builder: (context, state) => const VaultScreen()),
  ],
);

// Navigate
context.go('/vault');
```

---

### 3. Animation

**React (Framer Motion):**
```typescript
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  exit={{ opacity: 0 }}
  transition={{ duration: 0.3 }}
>
  {children}
</motion.div>
```

**Flutter (Flutter Animate):**
```dart
Container(
  child: Text('Hello'),
)
  .animate()
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.2, end: 0, duration: 300.ms)
```

---

### 4. Styling

**React (Tailwind CSS):**
```typescript
<div className="bg-zinc-950 rounded-2xl p-4 border border-zinc-800">
  <span className="text-white text-sm font-medium">Title</span>
</div>
```

**Flutter (Material + Custom):**
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color(0xFF09090B),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFF27272A)),
  ),
  child: const Text(
    'Title',
    style: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
)
```

---

### 5. Modal / Bottom Sheet

**React (AnimatePresence + Portal):**
```typescript
<AnimatePresence>
  {showModal && (
    <>
      <motion.div className="absolute inset-0 bg-black/75" />
      <motion.div
        className="absolute bottom-0 bg-zinc-900 rounded-t-3xl"
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
      >
        {content}
      </motion.div>
    </>
  )}
</AnimatePresence>
```

**Flutter (showModalBottomSheet):**
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => Container(
    decoration: const BoxDecoration(
      color: Color(0xFF18181B),
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: content,
  ),
);
```

---

### 6. Search & Filter

**React:**
```typescript
const [searchText, setSearchText] = useState('');

const filteredNotes = NOTES.filter(
  (n) =>
    searchText === '' ||
    n.title.toLowerCase().includes(searchText.toLowerCase())
);
```

**Flutter:**
```dart
final TextEditingController _searchController = TextEditingController();
String _searchText = '';

List<Note> get _filteredNotes {
  if (_searchText.isEmpty) return mockNotes;
  return mockNotes
      .where((note) =>
          note.title.toLowerCase().contains(_searchText.toLowerCase()))
      .toList();
}
```

---

### 7. Gesture Detection

**React (onClick, onTap):**
```typescript
<div onClick={handleTap}>
  Click me
</div>
```

**Flutter (GestureDetector / InkWell):**
```dart
// Simple tap
GestureDetector(
  onTap: handleTap,
  child: Container(child: Text('Tap me')),
)

// With ripple effect
InkWell(
  onTap: handleTap,
  borderRadius: BorderRadius.circular(16),
  child: Container(child: Text('Tap me')),
)
```

---

### 8. Image Loading

**React (Native img tag):**
```typescript
<img src={photo.src} alt={photo.label} className="w-full h-full object-cover" />
```

**Flutter (CachedNetworkImage):**
```dart
CachedNetworkImage(
  imageUrl: photo.src,
  fit: BoxFit.cover,
  placeholder: (context, url) => Container(
    color: const Color(0xFF18181B),
  ),
)
```

---

### 9. Conditional Rendering

**React:**
```typescript
{isHiddenKeyword && (
  <div>Vault Card</div>
)}

{items.map((item, i) => (
  <div key={item.id}>{item.title}</div>
))}
```

**Flutter:**
```dart
if (_isHiddenKeyword) ...[
  _buildVaultCard(),
],

...items.map((item) => _buildItemCard(item)),
```

---

### 10. Form Input

**React (Controlled Component):**
```typescript
const [title, setTitle] = useState('');

<input
  value={title}
  onChange={(e) => setTitle(e.target.value)}
  placeholder="Tiêu đề..."
/>
```

**Flutter (TextEditingController):**
```dart
final _titleController = TextEditingController();

TextField(
  controller: _titleController,
  decoration: const InputDecoration(
    hintText: 'Tiêu đề...',
  ),
)

// Don't forget to dispose
@override
void dispose() {
  _titleController.dispose();
  super.dispose();
}
```

---

## Các thay đổi quan trọng

### 1. Lifecycle

**React:**
- `useEffect` cho side effects
- `useState` cho local state
- `useCallback` cho memoized functions

**Flutter:**
- `initState()` - Khởi tạo
- `dispose()` - Cleanup
- `setState()` - Update UI
- `didUpdateWidget()` - Props changed

### 2. Async Operations

**React:**
```typescript
useEffect(() => {
  const timer = setTimeout(() => {
    navigate('onboarding');
  }, 2600);
  return () => clearTimeout(timer);
}, []);
```

**Flutter:**
```dart
@override
void initState() {
  super.initState();
  Future.delayed(const Duration(milliseconds: 2600), () {
    if (mounted) {
      context.go('/onboarding');
    }
  });
}
```

### 3. Responsive Design

**React (Tailwind breakpoints):**
```typescript
<div className="w-full md:w-1/2 lg:w-1/3">
```

**Flutter (MediaQuery):**
```dart
final width = MediaQuery.of(context).size.width;
final isTablet = width > 600;

Container(
  width: isTablet ? width / 2 : width,
)
```

---

## Performance Considerations

### React
- Virtual DOM diffing
- Memoization với `useMemo`, `useCallback`
- Code splitting với dynamic imports

### Flutter
- Widget tree rebuilding
- `const` constructors để tránh rebuild
- `ListView.builder` cho danh sách dài
- `AnimatedBuilder` để tách animation logic

---

## Testing

### React
```typescript
import { render, screen } from '@testing-library/react';

test('renders note title', () => {
  render(<NoteCard note={mockNote} />);
  expect(screen.getByText('Họp 10h sáng')).toBeInTheDocument();
});
```

### Flutter
```dart
testWidgets('renders note title', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(home: NoteCard(note: mockNote)),
  );
  expect(find.text('Họp 10h sáng'), findsOneWidget);
});
```

---

## Kết luận

Việc chuyển đổi từ React sang Flutter đòi hỏi:

1. **Tư duy khác biệt**: Từ component-based sang widget-based
2. **State management**: Từ hooks sang Provider/Riverpod
3. **Styling**: Từ CSS/Tailwind sang Material Design
4. **Navigation**: Từ manual state sang declarative routing
5. **Platform-specific**: Xử lý iOS/Android differences

Tuy nhiên, logic nghiệp vụ và UX flow vẫn giữ nguyên, giúp quá trình migration dễ dàng hơn.
