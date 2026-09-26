import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ai/learning_profile.dart';
import '../../core/constants/pet_species.dart';
import '../../core/models/pet_state.dart';
import '../../engine/behavior_engine.dart';
import '../../providers/pet_provider.dart';
import '../../render/pet_painter.dart';
import '../../render/dog_animation_controller.dart';
import '../../render/dog_scene_view.dart';
import '../../services/ad_service.dart';
import '../../services/audio_service.dart';
import '../settings/settings_screen.dart';
import 'manual_test_controls.dart';
import 'pet_status_hud.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final BehaviorEngine _engine = BehaviorEngine();
  final DogAnimationController _dogAnimationController =
      DogAnimationController();
  final ValueNotifier<String> _currentDogClip = ValueNotifier('Idle');
  final DogAudioController _dogAudio = DogAudioController();
  DogSceneStatus _dogSceneStatus = DogSceneStatus.loading;
  bool _manualControlsEnabled = false;
  String _manualMood = 'neutral';
  String _manualClip = 'Idle';
  Timer? _behaviorTimer;
  Offset _cursor = const Offset(200, 400);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _behaviorTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _behaviorTick(),
    );
  }

  void _behaviorTick() {
    final pet = ref.read(petProvider);
    if (pet == null) return;
    _dogAudio.setSpecies(pet.species);
    final decision = _engine.tick(
      pet,
      const Duration(milliseconds: 100),
      _cursor,
      learningProfile: LearningProfile.fromPet(pet),
    );
    if (_manualControlsEnabled) {
      pet.mood = _manualMood;
      pet.currentBehavior = _manualClip.toLowerCase();
      if (_currentDogClip.value != _manualClip) {
        _currentDogClip.value = _manualClip;
      }
    } else {
      final animation = _dogAnimationController.select(
        pet: pet,
        behavior: decision.type,
      );
      if (_currentDogClip.value != animation.clip) {
        _currentDogClip.value = animation.clip;
      }
    }
    _dogAudio.tick(behavior: decision.type, speed: decision.speed);
    if (decision.speed > 0) {
      ref.read(petProvider.notifier).movePet(
            decision,
            const Duration(milliseconds: 100),
          );
    }
  }

  @override
  void dispose() {
    _behaviorTimer?.cancel();
    _animController.dispose();
    _currentDogClip.dispose();
    _dogAudio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    if (pet == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Chat locally',
            onPressed: _openChat,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Manual test controls',
            onPressed: _showManualControls,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('🍖', pet.hunger),
                  _stat('⚡', pet.energy),
                  _stat('😊', pet.happiness),
                  _stat('💧', pet.cleanliness),
                  _stat('❤️', pet.affection),
                  _stat('🥤', pet.hydration),
                  _stat('🧘', 1.0 - pet.stress),
                ],
              ),
            ),
            Expanded(
              child: _buildPetViewport(pet),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton('Feed', Icons.restaurant, () {
                    _showReaction('fed');
                    _dogAudio.interaction('feed');
                    AudioService.playHappy();
                    ref.read(petProvider.notifier).feed();
                    AdService.showIfReady();
                  }),
                  _actionButton('Play', Icons.sports_esports, () {
                    _showReaction('play');
                    _dogAudio.interaction('play');
                    AudioService.playMeow();
                    ref.read(petProvider.notifier).play();
                  }),
                  _actionButton('Pet', Icons.favorite, () {
                    _showReaction('pet');
                    _dogAudio.interaction('pet');
                    AudioService.playPurr();
                    ref.read(petProvider.notifier).petPet();
                  }),
                  _actionButton('Clean', Icons.cleaning_services, () {
                    _showReaction('clean');
                    _dogAudio.interaction('clean');
                    ref.read(petProvider.notifier).clean();
                  }),
                  _actionButton('Drink', Icons.water_drop, () {
                    _showReaction('drink');
                    ref.read(petProvider.notifier).drink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReaction(String context) async {
    final reaction = await ref.read(petProvider.notifier).react(context);
    if (!mounted || reaction == null) return;
    ScaffoldMessenger.of(this.context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(reaction),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Widget _buildPetViewport(PetState pet) {
    final fallback = AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return CustomPaint(
          painter: PetPainter(
            pet: pet,
            behavior: _engine.currentBehavior,
            animationTime: _animController.value * 60,
            scale: 1.0,
          ),
          child: const SizedBox.expand(),
        );
      },
    );

    if (pet.species == PetSpecies.dog) {
      return Stack(
        fit: StackFit.expand,
        children: [
          fallback,
          DogSceneView(
            onStatusChanged: _onDogSceneStatusChanged,
            requestedAnimation: _currentDogClip,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: ValueListenableBuilder<String>(
              valueListenable: _currentDogClip,
              builder: (context, clip, _) => PetStatusHud(
                pet: pet,
                animationClip: clip,
                sceneStatus: _dogSceneStatus,
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onPanUpdate: (details) => _cursor = details.localPosition,
      onTapDown: (details) => _cursor = details.localPosition,
      child: fallback,
    );
  }

  void _onDogSceneStatusChanged(DogSceneStatus status) {
    if (!mounted || _dogSceneStatus == status) return;
    setState(() => _dogSceneStatus = status);
  }

  Future<void> _showManualControls() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => ManualTestControls(
          enabled: _manualControlsEnabled,
          selectedMood: _manualMood,
          selectedClip: _manualClip,
          onToggle: (enabled) {
            setState(() => _manualControlsEnabled = enabled);
            setSheetState(() {});
          },
          onMoodSelected: (mood) {
            setState(() => _manualMood = mood);
            setSheetState(() {});
          },
          onClipSelected: (clip) {
            setState(() {
              _manualClip = clip;
              _manualControlsEnabled = true;
            });
            _currentDogClip.value = clip;
            setSheetState(() {});
          },
          onReset: () {
            setState(() {
              _manualControlsEnabled = false;
              _manualMood = 'neutral';
              _manualClip = 'Idle';
            });
            _currentDogClip.value = 'Idle';
            Navigator.pop(sheetContext);
          },
        ),
      ),
    );
  }

  Future<void> _openChat() async {
    final controller = TextEditingController();
    final messages = <Map<String, String>>[];
    var loading = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> send() async {
              final text = controller.text.trim();
              if (text.isEmpty || loading) return;
              controller.clear();
              // Dismiss the keyboard with every send: the sheet must never
              // be dismissed (drag/back) with a focused field, which trips
              // InheritedElement.debugDeactivated and red-screens the app.
              FocusScope.of(context).unfocus();
              setSheetState(() {
                messages.add({'role': 'user', 'text': text});
                loading = true;
              });
              final reply = await ref.read(petProvider.notifier).chat(text);
              if (!context.mounted) return;
              setSheetState(() {
                if (reply != null && reply.isNotEmpty) {
                  messages.add({'role': 'pet', 'text': reply});
                }
                loading = false;
              });
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Local pet chat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'On-device only. Works offline; replies improve when a local model is installed from Settings.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (messages.isEmpty && !loading)
                      const Text(
                        'Say hello to your pet to begin.',
                        textAlign: TextAlign.center,
                      ),
                    if (messages.isEmpty && !loading) const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView(
                        shrinkWrap: true,
                        children: messages.map((message) {
                          final isUser = message['role'] == 'user';
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.orange.shade100
                                    : Colors.brown.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(message['text'] ?? ''),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            enabled: !loading,
                            onSubmitted: (_) => send(),
                            decoration: const InputDecoration(
                              hintText: 'Talk to your pet...',
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: loading ? 'Stop response' : 'Send message',
                          onPressed: loading
                              ? () async {
                                  await ref
                                      .read(petProvider.notifier)
                                      .cancelChat();
                                  if (context.mounted) {
                                    setSheetState(() => loading = false);
                                  }
                                }
                              : send,
                          icon: loading
                              ? const Icon(Icons.stop_circle_outlined)
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    controller.dispose();
  }

  Widget _stat(String emoji, double value) {
    final percent = (value.clamp(0.0, 1.0) * 100).round();
    return Semantics(
      label: '$emoji $percent percent',
      value: '$percent%',
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          SizedBox(
            width: 40,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white12,
              color: value > 0.5
                  ? Colors.green
                  : value > 0.2
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon),
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFFFB870).withValues(alpha: 0.2),
            padding: const EdgeInsets.all(12),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
