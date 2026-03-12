import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/fake_notepad_screen.dart';
import 'screens/note_edit_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/black_screen.dart';
import 'providers/app_state.dart';
import 'providers/notes_provider.dart';
import 'services/storage_service.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  await StorageService.init();
  
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Camera init error: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..init()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: const NoteCamApp(),
    ),
  );
}

class NoteCamApp extends StatefulWidget {
  const NoteCamApp({super.key});

  @override
  State<NoteCamApp> createState() => _NoteCamAppState();
}

class _NoteCamAppState extends State<NoteCamApp> {
  static const EventChannel _volumeChannel = EventChannel('volume_button_channel');

  CameraController? _cameraController;
  FlutterSoundRecorder? _audioRecorder;

  bool _isProcessing = false;
  bool _isRecordingVideo = false;
  bool _isRecordingAudio = false;
  StreamSubscription? _volumeSubscription;
  String? _vaultPath;

  @override
  void initState() {
    super.initState();
    _initVaultPath();
    _volumeSubscription = _volumeChannel.receiveBroadcastStream().listen(_handleVolumeButton);
  }

  Future<void> _initVaultPath() async {
    final appDir = await getExternalStorageDirectory();
    if (appDir != null) {
      _vaultPath = '${appDir.path}/Vault';
    }
  }

  void _handleVolumeButton(dynamic event) {
    debugPrint('=== VOLUME EVENT: $event ===');
    if (event == 'VOLUME_BOTH') {
      _triggerAudio();
    } else if (event == 'VOLUME_UP') {
      if (_isRecordingVideo || _isRecordingAudio) return;
      _triggerPhoto();
    } else if (event == 'VOLUME_DOWN') {
      if (_isRecordingAudio) return;
      _triggerVideo();
    }
  }

  Future<void> _triggerPhoto() async {
    debugPrint('=== TRIGGER PHOTO ===');
    if (_isProcessing || _isRecordingVideo) {
      debugPrint('=== PHOTO SKIPPED: busy ===');
      return;
    }
    _isProcessing = true;
    try {
      await _takeHiddenPicture();
    } catch (e) {
      debugPrint('Photo trigger error: $e');
    }
    _isProcessing = false;
  }

  Future<void> _triggerVideo() async {
    debugPrint('=== TRIGGER VIDEO ===');
    if (_isProcessing) {
      debugPrint('=== VIDEO SKIPPED: busy ===');
      return;
    }
    try {
      if (_isRecordingVideo) {
        await _stopVideoRecording();
      } else {
        await _startVideoRecording();
      }
    } catch (e) {
      debugPrint('Video trigger error: $e');
    }
  }

  Future<void> _triggerAudio() async {
    debugPrint('=== TRIGGER AUDIO ===');
    if (_isRecordingVideo) {
      debugPrint('=== AUDIO SKIPPED: video in progress ===');
      return;
    }
    try {
      if (_isRecordingAudio) {
        await _stopAudioRecording();
      } else {
        await _startAudioRecording();
      }
    } catch (e) {
      debugPrint('Audio trigger error: $e');
    }
  }

  Future<void> _startAudioRecording() async {
    if (_vaultPath == null) return;
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('=== MICROPHONE PERMISSION DENIED ===');
        return;
      }

      _audioRecorder = FlutterSoundRecorder();
      await _audioRecorder!.openRecorder();

      final vaultDir = Directory('$_vaultPath/Recordings');
      if (!await vaultDir.exists()) {
        await vaultDir.create(recursive: true);
      }

      final fileName = 'REC${DateTime.now().millisecondsSinceEpoch}.aac';
      final path = '${vaultDir.path}/$fileName';

      await _audioRecorder!.startRecorder(toFile: path, codec: Codec.aacADTS);
      _isRecordingAudio = true;
      debugPrint('=== BAT DAU GHI AM: $path ===');
    } catch (e) {
      debugPrint('=== LOI GHI AM: $e ===');
      _isRecordingAudio = false;
      await _audioRecorder?.closeRecorder();
      _audioRecorder = null;
    }
  }

  Future<void> _stopAudioRecording() async {
    if (_audioRecorder == null || !_isRecordingAudio) return;
    try {
      final path = await _audioRecorder!.stopRecorder();
      debugPrint('=== DA LUU GHI AM: $path ===');
    } catch (e) {
      debugPrint('=== LOI DUNG GHI AM: $e ===');
    } finally {
      await _audioRecorder?.closeRecorder();
      _audioRecorder = null;
      _isRecordingAudio = false;
    }
  }

  Future<void> _takeHiddenPicture() async {
    if (cameras.isEmpty || _vaultPath == null) return;

    try {
      _cameraController = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(FlashMode.off);
      
      final XFile file = await _cameraController!.takePicture();
      
      final vaultDir = Directory('$_vaultPath');
      if (!await vaultDir.exists()) {
        await vaultDir.create(recursive: true);
      }
      
      final fileName = 'CAP${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = '${vaultDir.path}/$fileName';
      
      await File(file.path).copy(newPath);
      await File(file.path).delete();
      
      debugPrint('=== DA CHUP ANH VAO VAULT: $newPath ===');
    } catch (e) {
      debugPrint('=== LOI CHUP ANH: $e ===');
    } finally {
      try {
        await _cameraController?.dispose();
      } catch (e) {
        debugPrint('Dispose error: $e');
      }
      _cameraController = null;
    }
  }

  Future<void> _startVideoRecording() async {
    if (cameras.isEmpty || _vaultPath == null) return;

    try {
      _cameraController = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: true);
      await _cameraController!.initialize();
      await _cameraController!.startVideoRecording();
      
      _isRecordingVideo = true;
      debugPrint('=== BAT DAU QUAY VIDEO ===');
    } catch (e) {
      debugPrint('=== LOI BAT DAU QUAY VIDEO: $e ===');
      _isRecordingVideo = false;
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_cameraController == null || !_isRecordingVideo) return;

    try {
      final XFile file = await _cameraController!.stopVideoRecording();
      
      final vaultDir = Directory('$_vaultPath/Videos');
      if (!await vaultDir.exists()) {
        await vaultDir.create(recursive: true);
      }
      
      final fileName = 'VID${DateTime.now().millisecondsSinceEpoch}.mp4';
      final newPath = '${vaultDir.path}/$fileName';
      
      await File(file.path).copy(newPath);
      await File(file.path).delete();
      
      debugPrint('=== DA LUU VIDEO VAO VAULT: $newPath ===');
    } catch (e) {
      debugPrint('=== LOI LUU VIDEO: $e ===');
    } finally {
      try {
        await _cameraController?.dispose();
      } catch (e) {
        debugPrint('Dispose error: $e');
      }
      _cameraController = null;
      _isRecordingVideo = false;
    }
  }

  @override
  void dispose() {
    _volumeSubscription?.cancel();
    _cameraController?.dispose();
    _audioRecorder?.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/notepad',
          builder: (context, state) => const FakeNotepadScreen(),
        ),
        GoRoute(
          path: '/note-edit/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '0';
            return NoteEditScreen(noteId: id);
          },
        ),
        GoRoute(
          path: '/vault',
          builder: (context, state) => const VaultScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/black-screen',
          builder: (context, state) => const BlackScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'NoteCam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
