import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'app.dart';
import 'core/models/behavior_type.dart';
import 'core/models/pet_state.dart';
import 'data/database.dart';
import 'render/pet_painter.dart';
import 'services/audio_service.dart';
import 'services/purchase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FlutterGemma.initialize(
      inferenceEngines: [const LiteRtLmEngine()],
    );
  } catch (_) {
    // The conversational fallback remains available if native LLM loading
    // is unavailable on an older or low-memory Android device.
  }
  await Database.init();
  AudioService.init();
  await MobileAds.instance.initialize();
  await PurchaseService.init();
  runApp(const ProviderScope(child: RafiqApp()));
}

@pragma('vm:entry-point')
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Database.isReady) await Database.init();
  runApp(const _FloatingPetApp());
}

class _FloatingPetApp extends StatefulWidget {
  const _FloatingPetApp();

  @override
  State<_FloatingPetApp> createState() => _FloatingPetAppState();
}

class _FloatingPetAppState extends State<_FloatingPetApp>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  PetState? _pet;
  static const MethodChannel _channel = MethodChannel('rafiq/overlay');

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _loadPet();
    _channel.setMethodCallHandler((call) async => null);
  }

  Future<void> _loadPet() async {
    final pet = await Database.getPet();
    if (mounted) setState(() => _pet = pet);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pet == null) return const SizedBox.shrink();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            return CustomPaint(
              painter: PetPainter(
                pet: _pet!,
                behavior: BehaviorType.idle,
                animationTime: _animController.value * 60,
                scale: 0.8,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}
