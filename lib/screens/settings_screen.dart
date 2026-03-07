import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showPinChange = false;
  bool _showModeChange = false;
  String? _activeAction;
  String _newPin = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final conflicts = appState.getConflictingActions();

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildInterfaceSection(appState),
                      const SizedBox(height: 20),
                      _buildQuickActionsSection(appState, conflicts),
                      const SizedBox(height: 20),
                      _buildSecuritySection(),
                      const SizedBox(height: 20),
                      _buildInfoSection(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
            if (_activeAction != null) _buildActionSelector(appState),
            if (_showPinChange) _buildPinChangeModal(appState),
            if (_showModeChange) _buildModeChangeModal(appState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF18181B))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            color: Colors.white,
            onPressed: () => context.go('/vault'),
          ),
          const SizedBox(width: 12),
          const Text(
            'Cài đặt',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterfaceSection(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'GIAO DIỆN',
            style: TextStyle(
              color: Color(0xFF52525B),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: Column(
            children: [
              _buildSettingRow(
                icon: LucideIcons.vibrate,
                title: 'Haptic Feedback',
                subtitle: 'Rung khi thao tác thành công',
                trailing: _buildToggle(
                  appState.hapticFeedback,
                  (v) => appState.setHapticFeedback(v),
                ),
              ),
              const Divider(height: 1, color: Color(0xFF27272A)),
              _buildSettingRow(
                icon: LucideIcons.smartphone,
                title: 'Đổi chế độ',
                subtitle: appState.displayMode == 'notepad'
                    ? 'Fake Notepad'
                    : 'Black Screen',
                trailing: const Icon(
                  LucideIcons.chevronRight,
                  size: 15,
                  color: Color(0xFF52525B),
                ),
                onTap: () => setState(() => _showModeChange = true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(AppState appState, List<String> conflicts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Row(
            children: [
              Text(
                'HÀNH ĐỘNG NHANH',
                style: TextStyle(
                  color: Color(0xFF52525B),
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              Spacer(),
              Text(
                'Tùy chỉnh thao tác bí mật',
                style: TextStyle(
                  color: Color(0xFF3F3F46),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: Column(
            children: [
              _buildActionRow(
                icon: LucideIcons.camera,
                title: 'Chụp ảnh',
                subtitle: appState.photoAction,
                hasConflict: conflicts.contains('photo'),
                onTap: () => setState(() => _activeAction = 'photo'),
              ),
              const Divider(height: 1, color: Color(0xFF27272A)),
              _buildActionRow(
                icon: LucideIcons.video,
                title: 'Quay video',
                subtitle: appState.videoAction,
                hasConflict: conflicts.contains('video'),
                onTap: () => setState(() => _activeAction = 'video'),
              ),
              const Divider(height: 1, color: Color(0xFF27272A)),
              _buildActionRow(
                icon: LucideIcons.mic,
                title: 'Ghi âm',
                subtitle: appState.audioAction,
                hasConflict: conflicts.contains('audio'),
                onTap: () => setState(() => _activeAction = 'audio'),
              ),
            ],
          ),
        ),
        if (conflicts.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8, left: 4, right: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7F1D1D).withOpacity(0.3),
              border: Border.all(
                color: const Color(0xFF991B1B).withOpacity(0.4),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 6,
                  color: Color(0xFFEF4444),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Có thao tác bị gán trùng. Vui lòng điều chỉnh để tránh xung đột.',
                    style: TextStyle(
                      color: Color(0xFFFCA5A5),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: -0.2, end: 0, duration: 200.ms),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'BẢO MẬT',
            style: TextStyle(
              color: Color(0xFF52525B),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: Column(
            children: [
              _buildSettingRow(
                icon: LucideIcons.lock,
                title: 'Đổi mã PIN',
                subtitle: 'Thay đổi mã bí mật',
                trailing: const Icon(
                  LucideIcons.chevronRight,
                  size: 15,
                  color: Color(0xFF52525B),
                ),
                onTap: () => setState(() => _showPinChange = true),
              ),
              const Divider(height: 1, color: Color(0xFF27272A)),
              _buildSettingRow(
                icon: LucideIcons.shield,
                title: 'Panic Mode',
                subtitle: 'Giữ 3 giây để xóa toàn bộ dữ liệu',
                trailing: const Icon(
                  LucideIcons.chevronRight,
                  size: 15,
                  color: Color(0xFF52525B),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: _buildSettingRow(
        icon: LucideIcons.info,
        title: 'Về ứng dụng',
        subtitle: 'NoteCam v1.0.0 (Demo)',
        trailing: const Icon(
          LucideIcons.chevronRight,
          size: 15,
          color: Color(0xFF52525B),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF27272A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool hasConflict,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: hasConflict
                      ? const Color(0xFF7F1D1D).withOpacity(0.6)
                      : const Color(0xFF27272A),
                  borderRadius: BorderRadius.circular(12),
                  border: hasConflict
                      ? Border.all(
                          color: const Color(0xFF991B1B).withOpacity(0.5))
                      : null,
                ),
                child: Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasConflict ? '⚠ Trùng thao tác — $subtitle' : subtitle,
                      style: TextStyle(
                        color: hasConflict
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF71717A),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.chevronRight,
                size: 15,
                color: Color(0xFF52525B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: value ? Colors.white : const Color(0xFF3F3F46),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: value ? Colors.black : const Color(0xFF9CA3AF),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionSelector(AppState appState) {
    final actionLabels = {
      'photo': 'Chụp ảnh',
      'video': 'Quay video',
      'audio': 'Ghi âm',
    };

    final photoVideoOptions = [
      'Volume Up – 1 lần',
      'Volume Up – 2 lần',
      'Volume Down – 1 lần',
      'Volume Down – 2 lần',
      'Nhấn giữ 2 giây',
      'Triple Tap màn hình',
      'Tắt',
    ];

    final audioOptions = [
      'Double press',
      'Hold 2s',
      'Triple tap',
      'Tắt',
    ];

    final options =
        _activeAction == 'audio' ? audioOptions : photoVideoOptions;
    final currentValue = _activeAction == 'photo'
        ? appState.photoAction
        : _activeAction == 'video'
            ? appState.videoAction
            : appState.audioAction;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: const Color(0xFF09090B),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF18181B))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft),
                      color: Colors.white,
                      onPressed: () => setState(() => _activeAction = null),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actionLabels[_activeAction] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'Chọn thao tác kích hoạt',
                          style: TextStyle(
                            color: Color(0xFF71717A),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF27272A)),
                      ),
                      child: Column(
                        children: options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          final isSelected = option == currentValue;
                          return Column(
                            children: [
                              if (index > 0)
                                const Divider(
                                    height: 1, color: Color(0xFF27272A)),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (_activeAction == 'photo') {
                                      appState.setPhotoAction(option);
                                    } else if (_activeAction == 'video') {
                                      appState.setVideoAction(option);
                                    } else if (_activeAction == 'audio') {
                                      appState.setAudioAction(option);
                                    }
                                    Future.delayed(
                                        const Duration(milliseconds: 200), () {
                                      if (mounted) {
                                        setState(() => _activeAction = null);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.vertical(
                                    top: index == 0
                                        ? const Radius.circular(16)
                                        : Radius.zero,
                                    bottom: index == options.length - 1
                                        ? const Radius.circular(16)
                                        : Radius.zero,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF52525B),
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Center(
                                                  child: Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            option,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFFD4D4D8),
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w500
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.circle,
                              size: 6,
                              color: Color(0xFF52525B),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Không được gán trùng thao tác cho hai hành động khác nhau',
                              style: TextStyle(
                                color: Color(0xFF52525B),
                                fontSize: 10,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildPinChangeModal(AppState appState) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF18181B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFF27272A), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3F3F46),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Đổi mã PIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: const Color(0xFF71717A),
                    onPressed: () {
                      setState(() {
                        _showPinChange = false;
                        _newPin = '';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nhập mã PIN mới (4 chữ số)',
                  style: TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _newPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isFilled ? Colors.white : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFilled ? Colors.white : const Color(0xFF52525B),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8',
                  '9',
                  '',
                  '0',
                  '⌫'
                ].map((key) {
                  if (key.isEmpty) return const SizedBox();
                  return Material(
                    color: const Color(0xFF27272A),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (key == '⌫') {
                            if (_newPin.isNotEmpty) {
                              _newPin = _newPin.substring(0, _newPin.length - 1);
                            }
                          } else if (_newPin.length < 4) {
                            _newPin += key;
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Text(
                          key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_newPin.length == 4)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        appState.setVaultPin(_newPin);
                        setState(() {
                          _showPinChange = false;
                          _newPin = '';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .slideY(begin: 0.2, end: 0, duration: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeChangeModal(AppState appState) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF18181B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFF27272A), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3F3F46),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chọn chế độ hiển thị',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Giao diện ngụy trang khi mở app',
                  style: TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildModeOption(
                icon: LucideIcons.smartphone,
                title: 'Fake Notepad',
                subtitle: 'Hiện như ứng dụng ghi chú bình thường',
                value: 'notepad',
                currentValue: appState.displayMode,
                onTap: () {
                  appState.setDisplayMode('notepad');
                  setState(() => _showModeChange = false);
                },
              ),
              const SizedBox(height: 12),
              _buildModeOption(
                icon: LucideIcons.zap,
                title: 'Black Screen',
                subtitle: 'Màn hình đen, chạm 3 lần để mở Vault',
                value: 'black',
                currentValue: appState.displayMode,
                onTap: () {
                  appState.setDisplayMode('black');
                  setState(() => _showModeChange = false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required String currentValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == currentValue;
    return Material(
      color: isSelected
          ? const Color(0xFF27272A)
          : const Color(0xFF27272A).withOpacity(0.4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.3)
                  : const Color(0xFF27272A),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3F3F46)
                      : const Color(0xFF27272A).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: isSelected ? Colors.white : const Color(0xFF71717A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFD4D4D8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : const Color(0xFF52525B),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
