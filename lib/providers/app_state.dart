import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  bool _hapticFeedback = true;
  String _displayMode = 'notepad'; // 'notepad' or 'black'
  
  // Quick actions
  String _photoAction = 'Volume Up – 1 lần';
  String _videoAction = 'Volume Up – 2 lần';
  String _audioAction = 'Hold 2s';
  
  String _vaultPin = '2580';
  bool _isInitialized = false;

  bool get hapticFeedback => _hapticFeedback;
  String get displayMode => _displayMode;
  String get photoAction => _photoAction;
  String get videoAction => _videoAction;
  String get audioAction => _audioAction;
  String get vaultPin => _vaultPin;
  bool get isInitialized => _isInitialized;

  // Initialize from storage
  Future<void> init() async {
    try {
      _hapticFeedback = StorageService.getHapticFeedback();
      _displayMode = StorageService.getDisplayMode();
      _photoAction = StorageService.getPhotoAction();
      _videoAction = StorageService.getVideoAction();
      _audioAction = StorageService.getAudioAction();
      _vaultPin = await StorageService.getVaultPin();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing AppState: $e');
    }
  }

  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    await StorageService.setHapticFeedback(value);
    notifyListeners();
  }

  Future<void> setDisplayMode(String mode) async {
    _displayMode = mode;
    await StorageService.setDisplayMode(mode);
    notifyListeners();
  }

  Future<void> setPhotoAction(String action) async {
    _photoAction = action;
    await StorageService.setPhotoAction(action);
    notifyListeners();
  }

  Future<void> setVideoAction(String action) async {
    _videoAction = action;
    await StorageService.setVideoAction(action);
    notifyListeners();
  }

  Future<void> setAudioAction(String action) async {
    _audioAction = action;
    await StorageService.setAudioAction(action);
    notifyListeners();
  }

  Future<void> setVaultPin(String pin) async {
    _vaultPin = pin;
    await StorageService.setVaultPin(pin);
    notifyListeners();
  }

  // Check for action conflicts
  bool hasConflicts() {
    final actions = [_photoAction, _videoAction, _audioAction];
    final nonDisabled = actions.where((a) => a != 'Tắt').toList();
    return nonDisabled.length != nonDisabled.toSet().length;
  }

  List<String> getConflictingActions() {
    final conflicts = <String>[];
    if (_photoAction != 'Tắt' && _videoAction != 'Tắt' && _photoAction == _videoAction) {
      conflicts.addAll(['photo', 'video']);
    }
    if (_photoAction != 'Tắt' && _audioAction != 'Tắt' && _photoAction == _audioAction) {
      conflicts.addAll(['photo', 'audio']);
    }
    if (_videoAction != 'Tắt' && _audioAction != 'Tắt' && _videoAction == _audioAction) {
      conflicts.addAll(['video', 'audio']);
    }
    return conflicts.toSet().toList();
  }
}
