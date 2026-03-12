import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;
  List<File> _vaultPhotos = [];
  List<File> _vaultVideos = [];
  List<File> _vaultRecordings = [];
  String _vaultPath = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentTab = _tabController.index);
    });
    _loadVaultPhotos();
    _loadVaultVideos();
    _loadVaultRecordings();
  }

  Future<void> _loadVaultPhotos() async {
    if (_vaultPath.isEmpty) {
      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        _vaultPath = '${appDir.path}/Vault';
      }
    }
    
    if (_vaultPath.isEmpty) return;
    
    final photosDir = Directory(_vaultPath);
    if (await photosDir.exists()) {
      final files = photosDir.listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
          .toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      if (mounted) {
        setState(() => _vaultPhotos = files);
      }
    }
  }

  Future<void> _loadVaultVideos() async {
    if (_vaultPath.isEmpty) {
      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        _vaultPath = '${appDir.path}/Vault';
      }
    }
    
    if (_vaultPath.isEmpty) return;
    
    final videosDir = Directory('$_vaultPath/Videos');
    if (await videosDir.exists()) {
      final files = videosDir.listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.mp4') || f.path.endsWith('.mkv'))
          .toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      if (mounted) {
        setState(() => _vaultVideos = files);
      }
    }
  }

  Future<void> _loadVaultRecordings() async {
    if (_vaultPath.isEmpty) {
      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        _vaultPath = '${appDir.path}/Vault';
      }
    }
    
    if (_vaultPath.isEmpty) return;
    
    final recordingsDir = Directory('$_vaultPath/Recordings');
    if (await recordingsDir.exists()) {
      final files = recordingsDir.listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.m4a') || f.path.endsWith('.mp3') || f.path.endsWith('.aac'))
          .toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      if (mounted) {
        setState(() => _vaultRecordings = files);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadVaultPhotos();
    _loadVaultVideos();
    _loadVaultRecordings();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                    onPressed: () => context.go('/notepad'),
                  ),
                  const Spacer(),
                  const Icon(LucideIcons.lock,
                      size: 13, color: Color(0xFF71717A)),
                  const SizedBox(width: 8),
                  const Text(
                    'Vault',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.settings),
                    color: const Color(0xFF9CA3AF),
                    iconSize: 19,
                    onPressed: () => context.go('/settings'),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _buildTab('Ảnh', 0),
                  const SizedBox(width: 24),
                  _buildTab('Video', 1),
                  const SizedBox(width: 24),
                  _buildTab('Ghi âm', 2),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: const Color(0xFF18181B),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPhotosTab(),
                  _buildVideosTab(),
                  _buildAudiosTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _currentTab == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF52525B),
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          if (isActive)
            Container(
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    if (_vaultPhotos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.imageOff, size: 48, color: Color(0xFF3F3F46)),
            SizedBox(height: 16),
            Text(
              'Chưa có ảnh nào',
              style: TextStyle(color: Color(0xFF52525B), fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Ảnh chụp sẽ được lưu vào đây',
              style: TextStyle(color: Color(0xFF3F3F46), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _vaultPhotos.length,
      itemBuilder: (context, index) {
        final photo = _vaultPhotos[index];
        return GestureDetector(
          onTap: () {
            _showPhotoPreview(photo);
          },
          child: Image.file(
            photo,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF18181B),
                child: const Icon(LucideIcons.image, color: Color(0xFF3F3F46)),
              );
            },
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms, delay: (index * 50).ms)
            .scale(
                begin: const Offset(0.95, 0.95),
                duration: 200.ms,
                delay: (index * 50).ms);
      },
    );
  }

  void _showPhotoPreview(File photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(photo),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    if (_vaultVideos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.video, size: 48, color: Color(0xFF3F3F46)),
            SizedBox(height: 16),
            Text(
              'Chưa có video nào',
              style: TextStyle(color: Color(0xFF52525B), fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Video quay sẽ được lưu vào đây',
              style: TextStyle(color: Color(0xFF3F3F46), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vaultVideos.length,
      itemBuilder: (context, index) {
        final video = _vaultVideos[index];
        return _buildVideoCard(video, index);
      },
    );
  }

  Widget _buildVideoCard(File video, int index) {
    final fileName = video.path.split('/').last;
    final fileSize = video.lengthSync();
    final sizeStr = _formatFileSize(fileSize);
    return Material(
      color: const Color(0xFF18181B),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => OpenFile.open(video.path),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF27272A)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16)),
                    child: Container(
                      width: 80,
                      height: 64,
                      color: const Color(0xFF27272A),
                      child: const Icon(
                        LucideIcons.video,
                        color: Color(0xFF52525B),
                        size: 24,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16)),
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.play,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '--:--',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sizeStr,
                        style: const TextStyle(
                          color: Color(0xFF71717A),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms, delay: (index * 50).ms)
        .slideY(begin: 0.1, end: 0, duration: 200.ms, delay: (index * 50).ms);
  }

  Widget _buildAudiosTab() {
    if (_vaultRecordings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.mic, size: 48, color: Color(0xFF3F3F46)),
            SizedBox(height: 16),
            Text(
              'Chưa có ghi âm nào',
              style: TextStyle(color: Color(0xFF52525B), fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Ghi âm sẽ được lưu vào đây',
              style: TextStyle(color: Color(0xFF3F3F46), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vaultRecordings.length,
      itemBuilder: (context, index) {
        final audio = _vaultRecordings[index];
        return _buildAudioCard(audio, index);
      },
    );
  }

  Widget _buildAudioCard(File audio, int index) {
    final fileName = audio.path.split('/').last;
    final fileSize = audio.lengthSync();
    final sizeStr = _formatFileSize(fileSize);
    final date = '${audio.lastModifiedSync().day} thg ${audio.lastModifiedSync().month}';
    return Material(
      color: const Color(0xFF18181B),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => OpenFile.open(audio.path),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF27272A)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF27272A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.mic,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Waveform
                    Row(
                      children: List.generate(24, (i) {
                        final heights = [
                          3.0,
                          6.0,
                          12.0,
                          8.0,
                          14.0,
                          10.0,
                          5.0,
                          16.0,
                          9.0,
                          7.0,
                          13.0,
                          11.0,
                          4.0,
                          8.0,
                          15.0,
                          6.0,
                          10.0,
                          12.0,
                          7.0,
                          5.0,
                          9.0,
                          13.0,
                          8.0,
                          4.0
                        ];
                        final filled = i < (index + 1) * 5 + 6;
                        return Container(
                          width: 2,
                          height: heights[i],
                          margin: const EdgeInsets.only(right: 2),
                          decoration: BoxDecoration(
                            color: filled
                                ? const Color(0xFF71717A)
                                : const Color(0xFF27272A),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '--:-- · $date · $sizeStr',
                      style: const TextStyle(
                        color: Color(0xFF52525B),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF27272A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.play,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms, delay: (index * 50).ms)
        .slideY(begin: 0.1, end: 0, duration: 200.ms, delay: (index * 50).ms);
  }
}
