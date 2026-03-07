import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/fake_notepad_screen.dart';
import 'screens/note_edit_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/black_screen.dart';
import 'providers/app_state.dart';
import 'providers/notes_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar to transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize storage
  await StorageService.init();
  
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

class NoteCamApp extends StatelessWidget {
  const NoteCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/notepad',
          builder: (context, state) => const FakeNotepadScreen(),
        ),
        GoRoute(
          path: '/note-edit/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '0';
            return NoteEditScreen(noteId: id);
          },
        ),
        GoRoute(
          path: '/vault',
          builder: (context, state) => const VaultScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/black-screen',
          builder: (context, state) => const BlackScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'NoteCam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
