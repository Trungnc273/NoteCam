import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../widgets/vault_pin_modal.dart';
import '../models/note.dart';

class FakeNotepadScreen extends StatefulWidget {
  const FakeNotepadScreen({super.key});

  @override
  State<FakeNotepadScreen> createState() => _FakeNotepadScreenState();
}

class _FakeNotepadScreenState extends State<FakeNotepadScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _showNewNoteSheet = false;

  static const String secretKeyword = 'hidden';
  static const String vaultCode = '2580';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isHiddenKeyword =>
      _searchText.trim().toLowerCase() == secretKeyword;

  void _handleSearchSubmit() {
    if (_searchText.trim() == vaultCode) {
      _showVaultPinModal();
    }
  }

  void _showVaultPinModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VaultPinModal(
        onSuccess: () {
          Navigator.pop(context);
          _searchController.clear();
          setState(() => _searchText = '');
          context.go('/vault');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final notes = _searchText.isEmpty
        ? notesProvider.notes
        : notesProvider.searchNotes(_searchText);
    
    final visibleNotes = _isHiddenKeyword ? [] : notes;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ghi chú',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${notesProvider.notesCount} ghi chú',
                            style: const TextStyle(
                              color: Color(0xFF52525B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF27272A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.settings, size: 18),
                              color: const Color(0xFF9CA3AF),
                              padding: EdgeInsets.zero,
                              onPressed: () => context.go('/app-settings'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              color: Colors.black,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() => _showNewNoteSheet = true);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isHiddenKeyword
                            ? const Color(0xFF52525B)
                            : const Color(0xFF27272A),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.search,
                          size: 15,
                          color: _isHiddenKeyword
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF52525B),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => _searchText = value);
                            },
                            onSubmitted: (_) => _handleSearchSubmit(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm ghi chú...',
                              hintStyle: TextStyle(
                                color: Color(0xFF52525B),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchText.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchText = '');
                            },
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFF52525B),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Notes list
            Expanded(
              child: notesProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF52525B),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                      children: [
                        // Hidden Vault option
                        if (_isHiddenKeyword) ...[
                          _buildSectionDivider('Kết quả ẩn'),
                          const SizedBox(height: 8),
                          _buildVaultCard(),
                          const SizedBox(height: 16),
                        ],

                        // Regular notes
                        ...visibleNotes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final note = entry.value;
                          return _buildNoteCard(note, index);
                        }),

                        // Empty state
                        if (_searchText.isNotEmpty &&
                            !_isHiddenKeyword &&
                            visibleNotes.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Text(
                                'Không tìm thấy ghi chú',
                                style: TextStyle(
                                  color: Color(0xFF3F3F46),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                        // Empty state when no notes at all
                        if (notesProvider.notesCount == 0 &&
                            _searchText.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.note_add_outlined,
                                    size: 48,
                                    color: Color(0xFF3F3F46),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Chưa có ghi chú nào',
                                    style: TextStyle(
                                      color: Color(0xFF52525B),
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Nhấn + để tạo ghi chú mới',
                                    style: TextStyle(
                                      color: Color(0xFF3F3F46),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),

            // Bottom hint
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text(
                'Ghi chú của bạn được bảo mật',
                style: TextStyle(
                  color: Color(0xFF27272A),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
      // New Note Bottom Sheet
      bottomSheet: _showNewNoteSheet ? _buildNewNoteSheet() : null,
    );
  }

  Widget _buildNewNoteSheet() {
    final tags = ['Công việc', 'Cá nhân', 'Dự án', 'Kế hoạch', 'Nhật ký'];
    String selectedTag = 'Cá nhân';

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF18181B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: Color(0xFF27272A))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ghi chú mới',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: const Color(0xFF52525B),
                    iconSize: 20,
                    onPressed: () {
                      setState(() => _showNewNoteSheet = false);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Chọn danh mục',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  final isSelected = tag == selectedTag;
                  return GestureDetector(
                    onTap: () {
                      setSheetState(() => selectedTag = tag);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF27272A)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3F3F46)
                              : const Color(0xFF27272A),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF71717A),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final router = GoRouter.of(context);
                    final notesProvider = context.read<NotesProvider>();
                    
                    final newNote = await notesProvider.createNote(tag: selectedTag);
                    
                    if (mounted) {
                      setState(() => _showNewNoteSheet = false);
                      router.go('/note-edit/${newNote.id}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tạo ghi chú',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF27272A), height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF52525B),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF27272A), height: 1)),
      ],
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(begin: -0.1, end: 0, duration: 250.ms);
  }

  Widget _buildVaultCard() {
    return Material(
      color: const Color(0xFF18181B),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _showVaultPinModal,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF27272A)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27272A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3F3F46)),
                    ),
                    child: const Icon(
                      LucideIcons.lock,
                      size: 18,
                      color: Color(0xFFD4D4D8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Vault',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF27272A),
                                border: Border.all(
                                    color: const Color(0xFF3F3F46)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'RIÊNG TƯ',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Nội dung được mã hoá và ẩn khỏi ghi chú thường',
                          style: TextStyle(
                            color: Color(0xFF71717A),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: Color(0xFF52525B),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFF27272A)),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      LucideIcons.shieldCheck,
                      size: 11,
                      color: Color(0xFF52525B),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Yêu cầu xác thực mã PIN để truy cập',
                      style: TextStyle(
                        color: Color(0xFF52525B),
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
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .scale(begin: const Offset(0.97, 0.97), duration: 250.ms);
  }

  Widget _buildNoteCard(Note note, int index) {
    final tagColors = {
      'Công việc': const Color(0xFF3B82F6),
      'Cá nhân': const Color(0xFF10B981),
      'Dự án': const Color(0xFFA855F7),
      'Kế hoạch': const Color(0xFFF97316),
      'Nhật ký': const Color(0xFFEC4899),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.go('/note-edit/${note.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF27272A)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (note.starred)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.star,
                          size: 11,
                          color: Color(0xFFEAB308),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      note.timeAgo,
                      style: const TextStyle(
                        color: Color(0xFF52525B),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.more_vert,
                      size: 14,
                      color: Color(0xFF3F3F46),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '# ${note.tag}',
                  style: TextStyle(
                    color: tagColors[note.tag] ?? const Color(0xFF71717A),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 250.ms, delay: (index * 50).ms)
          .slideY(begin: 0.1, end: 0, duration: 250.ms, delay: (index * 50).ms),
    );
  }
}
