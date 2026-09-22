import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import 'dog_environment.dart';
import 'dog_interaction_motion.dart';
import 'dog_secondary_motion.dart';
import '../services/audio_service.dart';

/// Android 3D vertical-slice host for the dog asset.
///
/// It deliberately fails closed: until a validated rigged GLB is supplied,
/// the existing 2D pet renderer remains the production fallback instead of
/// displaying an unverified placeholder model.
class DogSceneView extends StatefulWidget {
  const DogSceneView({super.key, this.assetPath = 'assets/models/dog/dog.glb'});

  final String assetPath;

  @override
  State<DogSceneView> createState() => _DogSceneViewState();
}

class _DogSceneViewState extends State<DogSceneView> {
  final Scene _scene = Scene();
  final DogInteractionMotion _interaction = DogInteractionMotion(
    onPat: AudioService.playDogTouch,
    onMove: AudioService.playDogTouchMove,
  );
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDog();
  }

  Future<void> _loadDog() async {
    try {
      await Scene.initializeStaticResources();
      const environment = DogEnvironment();
      environment.configure(_scene);
      _scene.add(environment.createGround());
      if (environment.enableDust) {
        _scene.add(environment.createDustEmitter());
      }
      final dog = await Node.fromGlbAsset(widget.assetPath);
      dog.addComponent(_interaction);
      dog.addComponent(DogSecondaryMotion());
      _scene.add(dog);
      if (mounted) setState(() => _ready = true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return const SizedBox.shrink();
    }
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _interaction.pat,
      onPanUpdate: (details) {
        _interaction.dragHorizontal(
          details.delta.dx,
          context.size?.width ?? 1,
        );
        _interaction.dragVertical(
          details.delta.dy,
          context.size?.height ?? 1,
        );
      },
      onPanEnd: (_) => _interaction.release(),
      onPanCancel: _interaction.release,
      child: SceneView(
        _scene,
        camera: PerspectiveCamera(
          position: vm.Vector3(0, 1.2, 3.5),
          target: vm.Vector3(0, 0.9, 0),
        ),
      ),
    );
  }
}
