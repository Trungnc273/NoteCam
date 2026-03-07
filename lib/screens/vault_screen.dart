import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  final List<Map<String, String>> _photos = [
    {
      'id': '1',
      'src':
          'https://images.unsplash.com/photo-1542396420-486f9e21bb44?w=300&q=80',
      'label': 'Phong cảnh'
    },
    {
      'id': '2',
      'src':
          'https://images.unsplash.com/photo-1610348308369-48cc9ee983ea?w=300&q=80',
      'label': 'Đêm thành phố'
    },
    {
      'id': '3',
      'src':
          'https://images.unsplash.com/photo-1747727350761-a607eae63dc0?w=300&q=80',
      'label': 'Kiến trúc'
    },
    {
      'id': '4',
      'src':
          'https://images.unsplash.com/photo-1644562105417-45623040bb5e?w=300&q=80',
      'label': 'Rừng mù'
    },
    {
      'id': '5',
      'src':
          'https://images.unsplash.com/photo-1509028090362-e25ea4fef045?w=300&q=80',
      'label': 'Biển hoàng hôn'
    },
    {
      'id': '6',
      'src':
          'https://images.unsplash.com/photo-1682334288172-88e43f2d7d59?w=300&q=80',
      'label': 'Núi tuyết'
    },
  ];

  final List<Map<String, String>> _videos = [
    {
      'id': '1',
      'label': 'Video_20240228_001.mp4',
      'duration': '2:34',
      'size': '128 MB',
      'thumb':
          'https://images.unsplash.com/photo-1610348308369-48cc9ee983ea?w=300&q=80'
    },
    {
      'id': '2',
      'label': 'Video_20240215_003.mp4',
      'duration': '1:07',
      'size': '56 MB',
      'thumb':
          'https://images.unsplash.com/photo-1542396420-486f9e21bb44?w=300&q=80'
    },
    {
      'id': '3',
      'label': 'Clip_buoi_sang.mp4',
      'duration': '0:45',
      'size': '34 MB',
      'thumb':
          'https://images.unsplash.com/photo-1644562105417-45623040bb5e?w=300&q=80'
    },
  ];

  final List<Map<String, String>> _audios = [
    {
      'id': '1',
      'label': 'Recording_001.m4a',
      'duration': '5:21',
      'date': '28 thg 2',
      'size': '4.2 MB'
    },
    {
      'id': '2',
      'label': 'Recording_002.m4a',
      'duration': '1:45',
      'date': '20 thg 2',
      'size': '1.4 MB'
    },
    {
      'id': '3',
      'label': 'Ghi_am_phong_hop.m4a',
      'duration': '12:38',
      'date': '15 thg 2',
      'size': '9.8 MB'
    },
    {
      'id': '4',
      'label': 'Note_voice_07.m4a',
      'duration': '0:52',
      'date': '8 thg 2',
      'size': '0.7 MB'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return GestureDetector(
          onTap: () {
            // TODO: Implement photo preview
          },
          child: CachedNetworkImage(
            imageUrl: photo['src']!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: const Color(0xFF18181B),
            ),
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

  Widget _buildVideosTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return _buildVideoCard(video, index);
      },
    );
  }

  Widget _buildVideoCard(Map<String, String> video, int index) {
    return Material(
      color: const Color(0xFF18181B),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          // TODO: Implement video preview
        },
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
                    child: CachedNetworkImage(
                      imageUrl: video['thumb']!,
                      width: 80,
                      height: 64,
                      fit: BoxFit.cover,
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
                      child: Text(
                        video['duration']!,
                        style: const TextStyle(
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
                        video['label']!,
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
                        video['size']!,
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _audios.length,
      itemBuilder: (context, index) {
        final audio = _audios[index];
        return _buildAudioCard(audio, index);
      },
    );
  }

  Widget _buildAudioCard(Map<String, String> audio, int index) {
    return Material(
      color: const Color(0xFF18181B),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          // TODO: Implement audio preview
        },
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
                      audio['label']!,
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
                      '${audio['duration']} · ${audio['date']} · ${audio['size']}',
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
