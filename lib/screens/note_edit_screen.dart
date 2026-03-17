import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';

class NoteEditScreen extends StatefulWidget {
  final String noteId;

  const NoteEditScreen({super.key, required this.noteId});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late bool _starred;
  late String _tag;
  Note? _currentNote;
  bool _isNewNote = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  void _loadNote() {
    final notesProvider = context.read<NotesProvider>();
    
    // Try to load existing note
    _currentNote = notesProvider.getNoteById(widget.noteId);
    
    if (_currentNote != null) {
      // Existing note found
      _isNewNote = false;
      _titleController = TextEditingController(text: _currentNote!.title);
      _bodyController = TextEditingController(text: _currentNote!.body);
      _starred = _currentNote!.starred;
      _tag = _currentNote!.tag;
    } else {
      // Note not found, treat as new
      _isNewNote = true;
      _titleController = TextEditingController();
      _bodyController = TextEditingController();
      _starred = false;
      _tag = 'Cá nhân';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    
    // Don't save empty notes when creating new
    if (_isNewNote && title.isEmpty && body.isEmpty) return;

    final notesProvider = context.read<NotesProvider>();

    if (_currentNote != null) {
      // Update existing note
      final updatedNote = _currentNote!.copyWith(
        title: title.isEmpty ? 'Không có tiêu đề' : title,
        body: body,
        tag: _tag,
        starred: _starred,
      );
      await notesProvider.updateNote(updatedNote);
    }
  }

  Future<void> _deleteNote() async {
    if (_currentNote == null || _isNewNote) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        title: const Text(
          'Xóa ghi chú?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bạn có chắc muốn xóa ghi chú này không?',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<NotesProvider>().deleteNote(_currentNote!.id);
      if (mounted) context.go('/notepad');
    }
  }

  Future<void> _handleBack() async {
    await _saveNote();
    if (mounted) context.go('/notepad');
  }

  Color _getTagColor(String tag) {
    final colors = {
      'Công việc': const Color(0xFF3B82F6),
      'Cá nhân': const Color(0xFF10B981),
      'Dự án': const Color(0xFFA855F7),
      'Kế hoạch': const Color(0xFFF97316),
      'Nhật ký': const Color(0xFFEC4899),
    };
    return colors[tag] ?? const Color(0xFF71717A);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF09090B),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF18181B)),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft),
                      color: Colors.white,
                      onPressed: _handleBack,
                    ),
                    const Text(
                      'Ghi chú',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _starred ? Icons.star : Icons.star_border,
                        color: _starred
                            ? const Color(0xFFEAB308)
                            : const Color(0xFF52525B),
                      ),
                      iconSize: 18,
                      onPressed: () {
                        setState(() => _starred = !_starred);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      color: const Color(0xFF9CA3AF),
                      iconSize: 18,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: const Color(0xFF18181B),
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  title: const Text(
                                    'Xóa ghi chú',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _deleteNote();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Tag
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTagColor(_tag).withOpacity(0.1),
                        border: Border.all(
                          color: _getTagColor(_tag).withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _tag,
                        style: TextStyle(
                          color: _getTagColor(_tag),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tiêu đề...',
                        hintStyle: TextStyle(
                          color: Color(0xFF3F3F46),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),

                    // Meta
                    Text(
                      _currentNote != null
                          ? 'Chỉnh sửa lần cuối · ${_currentNote!.updatedAt.day}/${_currentNote!.updatedAt.month}/${_currentNote!.updatedAt.year}'
                          : 'Ghi chú mới',
                      style: const TextStyle(
                        color: Color(0xFF3F3F46),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Body
                    TextField(
                      controller: _bodyController,
                      style: const TextStyle(
                        color: Color(0xFFD4D4D8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Bắt đầu ghi chú...',
                        hintStyle: TextStyle(
                          color: Color(0xFF3F3F46),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      minLines: 15,
                    ),
                  ],
                ),
              ),

              // Formatting toolbar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFF18181B)),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.bold),
                      color: const Color(0xFF71717A),
                      iconSize: 16,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.italic),
                      color: const Color(0xFF71717A),
                      iconSize: 16,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.list),
                      color: const Color(0xFF71717A),
                      iconSize: 16,
                      onPressed: () {},
                    ),
                    const Spacer(),
                    Text(
                      '${_bodyController.text.length} ký tự',
                      style: const TextStyle(
                        color: Color(0xFF3F3F46),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
