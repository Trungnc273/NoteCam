import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  int get notesCount => _notes.length;

  NotesProvider() {
    loadNotes();
  }

  // Load all notes from storage
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = StorageService.getAllNotes();
    } catch (e) {
      debugPrint('Error loading notes: $e');
      _notes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get single note by ID
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create new note
  Future<Note> createNote({
    String title = '',
    String body = '',
    String tag = 'Cá nhân',
    bool starred = false,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      tag: tag,
      starred: starred,
      createdAt: now,
      updatedAt: now,
    );

    await StorageService.saveNote(note);
    await loadNotes();

    return note;
  }

  // Update existing note
  Future<void> updateNote(Note note) async {
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    await StorageService.updateNote(note.id, updatedNote);
    await loadNotes();
  }

  // Delete note
  Future<void> deleteNote(String id) async {
    await StorageService.deleteNote(id);
    await loadNotes();
  }

  // Toggle star
  Future<void> toggleStar(String id) async {
    final note = getNoteById(id);
    if (note != null) {
      final updated = note.copyWith(
        starred: !note.starred,
        updatedAt: DateTime.now(),
      );
      await StorageService.updateNote(id, updated);
      await loadNotes();
    }
  }

  // Search notes
  List<Note> searchNotes(String query) {
    if (query.isEmpty) return _notes;

    final lowerQuery = query.toLowerCase();
    return _notes
        .where((note) =>
            note.title.toLowerCase().contains(lowerQuery) ||
            note.body.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // Get notes by tag
  List<Note> getNotesByTag(String tag) {
    return _notes.where((note) => note.tag == tag).toList();
  }

  // Get starred notes
  List<Note> getStarredNotes() {
    return _notes.where((note) => note.starred).toList();
  }
}
