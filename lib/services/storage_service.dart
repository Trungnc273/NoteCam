import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class StorageService {
  static const String notesBoxName = 'notes';
  static const String settingsBoxName = 'settings';

  // Hive boxes
  static Box<Note>? _notesBox;

  // Secure storage for PIN
  static const _secureStorage = FlutterSecureStorage();

  // SharedPreferences
  static SharedPreferences? _prefs;

  // Initialize all storage
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }

    // Open boxes
    _notesBox = await Hive.openBox<Note>(notesBoxName);

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();

    // Initialize with mock data if empty
    if (_notesBox!.isEmpty) {
      await _initializeMockData();
    }
  }

  static Future<void> _initializeMockData() async {
    final mockNotes = getMockNotes();
    for (final note in mockNotes) {
      await _notesBox!.put(note.id, note);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // NOTES CRUD
  // ═══════════════════════════════════════════════════════════

  static Box<Note> get notesBox {
    if (_notesBox == null || !_notesBox!.isOpen) {
      throw Exception('Notes box is not initialized');
    }
    return _notesBox!;
  }

  static List<Note> getAllNotes() {
    return notesBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static Note? getNote(String id) {
    return notesBox.get(id);
  }

  static Future<void> saveNote(Note note) async {
    await notesBox.put(note.id, note);
  }

  static Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  static Future<void> updateNote(String id, Note note) async {
    await notesBox.put(id, note);
  }

  static List<Note> searchNotes(String query) {
    if (query.isEmpty) return getAllNotes();

    final lowerQuery = query.toLowerCase();
    return notesBox.values
        .where((note) =>
            note.title.toLowerCase().contains(lowerQuery) ||
            note.body.toLowerCase().contains(lowerQuery))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // ═══════════════════════════════════════════════════════════
  // SETTINGS (SharedPreferences)
  // ═══════════════════════════════════════════════════════════

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPreferences is not initialized');
    }
    return _prefs!;
  }

  // Onboarding
  static bool hasCompletedOnboarding() {
    return prefs.getBool('onboarding_completed') ?? false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    await prefs.setBool('onboarding_completed', value);
  }

  // Haptic Feedback
  static bool getHapticFeedback() {
    return prefs.getBool('haptic_feedback') ?? true;
  }

  static Future<void> setHapticFeedback(bool value) async {
    await prefs.setBool('haptic_feedback', value);
  }

  // Display Mode
  static String getDisplayMode() {
    return prefs.getString('display_mode') ?? 'notepad';
  }

  static Future<void> setDisplayMode(String mode) async {
    await prefs.setString('display_mode', mode);
  }

  // Quick Actions
  static String getPhotoAction() {
    return prefs.getString('photo_action') ?? 'Volume Up – 1 lần';
  }

  static Future<void> setPhotoAction(String action) async {
    await prefs.setString('photo_action', action);
  }

  static String getVideoAction() {
    return prefs.getString('video_action') ?? 'Volume Up – 2 lần';
  }

  static Future<void> setVideoAction(String action) async {
    await prefs.setString('video_action', action);
  }

  static String getAudioAction() {
    return prefs.getString('audio_action') ?? 'Nhấn giữ 2 giây';
  }

  static Future<void> setAudioAction(String action) async {
    await prefs.setString('audio_action', action);
  }

  // ═══════════════════════════════════════════════════════════
  // VAULT PIN (Secure Storage)
  // ═══════════════════════════════════════════════════════════

  static Future<String> getVaultPin() async {
    return await _secureStorage.read(key: 'vault_pin') ?? '2580';
  }

  static Future<void> setVaultPin(String pin) async {
    await _secureStorage.write(key: 'vault_pin', value: pin);
  }

  // ═══════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════

  static Future<void> dispose() async {
    await _notesBox?.close();
  }

  static Future<void> clearAllData() async {
    await _notesBox?.clear();
    await prefs.clear();
    await _secureStorage.deleteAll();
    await clearVaultFiles();
  }

  static Future<void> clearVaultFiles() async {
    try {
      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        final vaultPath = '${appDir.path}/Vault';
        final vaultDir = Directory(vaultPath);
        
        if (await vaultDir.exists()) {
          // Delete all files and subdirectories in Vault
          await vaultDir.delete(recursive: true);
        }
      }
    } catch (e) {
      debugPrint('Error clearing vault files: $e');
    }
  }
}
