import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// Rendering environment for the Android dog vertical slice.
///
/// The defaults are intentionally restrained for mobile: soft cascaded shadows,
/// contact AO, a warm ground plane, and a sparse dust layer with soft-depth
/// fading. Each feature can be disabled independently for low-end devices.
class DogEnvironment {
  const DogEnvironment({
    this.enableShadows = true,
    this.enableAmbientOcclusion = true,
    this.enableFog = true,
    this.enableDust = true,
  });

  final bool enableShadows;
  final bool enableAmbientOcclusion;
  final bool enableFog;
  final bool enableDust;

  void configure(Scene scene) {
    scene.directionalLight = DirectionalLight(
      direction: vm.Vector3(-0.35, -1.0, -0.25),
      color: vm.Vector3(1.0, 0.78, 0.58),
      intensity: 3.2,
      castsShadow: enableShadows,
      shadowSoftness: 0.12,
      shadowCascadeCount: 2,
      shadowMaxDistance: 18.0,
      shadowFadeRange: 3.0,
      shadowMapResolution: 1024,
      shadowDepthBias: 0.012,
      shadowNormalBias: 0.018,
      shadowAmbientStrength: 0.32,
      contactShadows: true,
      contactShadowDistance: 0.45,
      angularRadius: 0.08,
    );

    final ao = scene.ambientOcclusion;
    ao.enabled = enableAmbientOcclusion;
    ao.method = AmbientOcclusionMethod.obscurance;
    ao.radius = 0.38;
    ao.intensity = 0.85;
    ao.power = 1.35;
    ao.detail = 0.65;
    ao.bias = 0.055;
    ao.directLightAffect = 0.18;
    ao.sampleCount = 16;

    final fog = scene.fog;
    fog.enabled = enableFog;
    fog.mode = FogMode.exponentialSquared;
    fog.color = vm.Vector3(0.62, 0.48, 0.32);
    fog.skyColorInfluence = 0.18;
    fog.density = 0.012;
    fog.start = 3.0;
    fog.maxOpacity = 0.22;
    fog.height = 0.0;
    fog.heightFalloff = 0.7;
    fog.sunInScatter = 0.08;
    fog.sunInScatterExponent = 10.0;
  }

  /// Adds a large matte ground receiver. It receives the dog's shadows but
  /// does not cast them, keeping the mobile shadow pass inexpensive.
  Node createGround() {
    final material = PhysicallyBasedMaterial()
      ..baseColorFactor = vm.Vector4(0.48, 0.30, 0.16, 1.0)
      ..metallicFactor = 0.0
      ..roughnessFactor = 0.94;
    return Node(
      name: 'EnvironmentGround',
      mesh: Mesh(PlaneGeometry(width: 12.0, depth: 12.0), material),
    )
      ..castsShadows = false
      ..shadowStatic = true;
  }

  /// Creates a sparse billboard dust emitter. It is deliberately low density
  /// and uses soft depth fading so particles dissolve into the ground instead
  /// of producing hard intersections.
  Node createDustEmitter() {
    final system = ParticleSystem(
      maxParticles: 72,
      shape: SphereEmitterShape(radius: 0.8, hemisphere: true),
      spawner: Spawner(rate: 7.0),
      lifetime: const UniformFloat(2.0, 4.5),
      startSpeed: const UniformFloat(0.015, 0.055),
      startSize: const UniformFloat(0.012, 0.035),
      startColor: const ConstantColor(vm.Vector4(0.76, 0.54, 0.32, 0.18)),
      gravity: vm.Vector3(0.0, 0.006, 0.0),
      modules: <ParticleModule>[
        ColorOverLifeModule(
          GradientColor(
            ColorGradient([
              ColorStop(0.0, vm.Vector4(0.76, 0.54, 0.32, 0.0)),
              ColorStop(0.12, vm.Vector4(0.76, 0.54, 0.32, 0.18)),
              ColorStop(0.72, vm.Vector4(0.76, 0.54, 0.32, 0.10)),
              ColorStop(1.0, vm.Vector4(0.76, 0.54, 0.32, 0.0)),
            ]),
          ),
        ),
      ],
      prewarm: 2.0,
      seed: 7421,
    );

    final emitter = ParticleEmitterComponent(system: system)
      ..aspectRatio = 1.35
      ..material.softDepthFade = 0.18
      ..material.tint = vm.Vector4(1.0, 0.86, 0.68, 0.72);
    return Node(name: 'EnvironmentDust')..addComponent(emitter);
  }
}
