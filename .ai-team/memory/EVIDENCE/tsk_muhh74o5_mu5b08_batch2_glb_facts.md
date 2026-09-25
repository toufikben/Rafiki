# Evidence — batch 2: 3D asset measured facts (no rigged GLB fabricated)

Task: tsk_muhh74o5_mu5b08 | Date (UTC): 2026-09-25 | Branch: ai/tsk-muhh74o5-mu5b08

## Method
Read-only inspection of `assets/models/dog/dog.glb` with .NET byte reads in
PowerShell (no Python/Flutter tooling in this environment): verified `glTF`
magic, version 2, header length == file length (113,456), decoded the JSON
chunk, counted nodes/meshes/materials/animations/skins, summed triangle
counts from index accessors.

## Measured facts
- Valid glTF 2.0 binary, 113,456 bytes; ~4,920 triangles / 20 primitives
  (inside the 12,000 target, below the 18,000 ceiling).
- 21 named nodes, 5 materials, 1 embedded image/texture.
- **0 animations, 0 skins** — the committed asset is a static prototype, as
  `dog_rig_manifest.json` (`asset_status: prototype_static_glb`) declares.
- Node vocabulary uses Blender-style dots (`Eye.L`, `Ear.L`, `Tail`,
  `TailTip`); contract gaps vs manifest skeleton: no `Jaw`, no eyelids, no
  `Tail_01..03` chain, `Paw` name reused 4x instead of unique paw joints.

## What changed
- `assets/models/dog/README.md`: recorded the measured facts + production
  gate checklist (no binary touched).
- Runtime tolerance (case-tolerant clip lookup, wider joint aliases in
  `dog_animation_controller/runtime/secondary_motion`) retained from the
  working tree so a future rigged GLB binds without replacing the 2D
  fallback (`DogSceneView` still fails closed to the 2D renderer).

## Reused
- `flutter_scene` ^0.23.0 + `vector_math` (existing 3D path; no new engine).
- Existing `DogSceneView`, `DogAnimationRuntime`, `DogSecondaryMotion`.

## NOT done (honest gaps)
- No rigged replacement GLB was produced: authoring a 23-joint skinned asset
  with 9 authored clips + 2K textures is artist work requiring Blender and
  visual QA; fabricating one here would be dishonest and unverifiable.
- No on-device visual/frame-time verification (no device/adb here).

## Verification available here
- GLB byte-level facts above (reproducible with the PowerShell snippet).
- `flutter test test/dog_animation_controller_test.dart` via CI (no local SDK).
