import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _showModeChange = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/notepad');
      },
      child: Scaffold(
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
                        _buildInfoSection(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
              if (_showModeChange) _buildModeChangeModal(appState),
            ],
          ),
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
            onPressed: () => context.go('/notepad'),
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
                title: 'Chế độ hiển thị',
                subtitle: appState.displayMode == 'notepad'
                    ? 'Fake Notepad (Ghi chú giả)'
                    : 'Black Screen (Màn hình đen)',
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

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'THÔNG TIN',
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
          child: _buildSettingRow(
            icon: LucideIcons.info,
            title: 'Về ứng dụng',
            subtitle: 'NoteCam v1.0.0',
            trailing: const Icon(
              LucideIcons.chevronRight,
              size: 15,
              color: Color(0xFF52525B),
            ),
            onTap: () {},
          ),
        ),
      ],
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
                icon: LucideIcons.fileText,
                title: 'Fake Notepad',
                subtitle: 'Hiện như ứng dụng ghi chú bình thường',
                description: 'App sẽ mở với giao diện ghi chú giả. Tìm kiếm "hidden" để vào Vault.',
                value: 'notepad',
                currentValue: appState.displayMode,
                onTap: () {
                  appState.setDisplayMode('notepad');
                  setState(() => _showModeChange = false);
                },
              ),
              const SizedBox(height: 12),
              _buildModeOption(
                icon: LucideIcons.square,
                title: 'Black Screen',
                subtitle: 'Màn hình đen hoàn toàn',
                description: 'App sẽ mở với màn hình đen. Chạm 3 lần nhanh để mở Vault.',
                value: 'black-screen',
                currentValue: appState.displayMode,
                onTap: () {
                  appState.setDisplayMode('black-screen');
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
    required String description,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Color(0xFF71717A),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        description,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 10,
                          height: 1.4,
                        ),
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
