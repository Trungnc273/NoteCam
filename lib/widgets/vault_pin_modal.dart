import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';

class VaultPinModal extends StatefulWidget {
  final VoidCallback onSuccess;

  const VaultPinModal({super.key, required this.onSuccess});

  @override
  State<VaultPinModal> createState() => _VaultPinModalState();
}

class _VaultPinModalState extends State<VaultPinModal>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _pinError = false;
  int _correctAttempts = 0; // Track consecutive correct attempts
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handlePinKey(String key) {
    if (key == '⌫') {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
          _pinError = false;
        });
      }
      return;
    }

    if (_pin.length >= 4) return;

    setState(() {
      _pin += key;
    });

    if (_pin.length == 4) {
      _verifyPin();
    }
  }

  Future<void> _verifyPin() async {
    final appState = context.read<AppState>();
    
    // Wait for AppState to be initialized
    if (!appState.isInitialized) {
      await appState.init();
    }
    
    final correctPin = appState.vaultPin;
    
    if (_pin == correctPin) {
      // Correct PIN
      setState(() {
        _correctAttempts++;
        _pinError = false;
      });
      
      if (_correctAttempts >= 2) {
        // Success after 2 correct attempts
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            widget.onSuccess();
          }
        });
      } else {
        // First correct attempt - ask to enter again
        // Show success feedback briefly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đúng! Nhập lại lần nữa để xác nhận',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
        
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _pin = '';
            });
          }
        });
      }
    } else {
      // Wrong PIN - reset attempts
      setState(() {
        _correctAttempts = 0;
        _pinError = true;
      });
      _shakeController.forward(from: 0);
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _pin = '';
            _pinError = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3F3F46),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          Row(
            children: [
              const Icon(LucideIcons.lock, size: 15, color: Color(0xFF9CA3AF)),
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
                icon: const Icon(Icons.close, size: 18),
                color: const Color(0xFF71717A),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _correctAttempts == 0
                  ? 'Nhập mã PIN để truy cập'
                  : 'Nhập lại để xác nhận (${_correctAttempts}/2)',
              style: const TextStyle(
                color: Color(0xFF71717A),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // PIN dots
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final offset = _pinError
                  ? ((_shakeController.value * 7) % 1) * 20 - 10
                  : 0.0;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _pinError
                        ? const Color(0xFFEF4444)
                        : (isFilled ? Colors.white : Colors.transparent),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _pinError
                          ? const Color(0xFFEF4444)
                          : (isFilled ? Colors.white : const Color(0xFF52525B)),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          // Error/Status message
          SizedBox(
            height: 20,
            child: _pinError
                ? const Text(
                    'Mã PIN không đúng',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11,
                    ),
                  )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .slideY(begin: -0.2, end: 0, duration: 200.ms)
                : _correctAttempts > 0
                    ? Text(
                        'Lần ${_correctAttempts}/2',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 11,
                        ),
                      )
                    : const SizedBox(),
          ),
          const SizedBox(height: 12),
          // Numpad
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
                  onTap: () => _handlePinKey(key),
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
        ],
      ),
    );
  }
}
