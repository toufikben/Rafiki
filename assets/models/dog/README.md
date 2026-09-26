# Dog 3D asset contract

This directory is the asset boundary for the first `flutter_scene` vertical slice. The visual source is the puppy reference image stored at `reference_images/reference_2.jpg`. The JSON manifest beside this file is a production contract for the eventual rigged GLB; it is not a model and it does not claim that animations already exist.

The final asset must be a rigged GLB with separate eye/eyelid, jaw, floppy-ear, four-leg, paw, and three-segment tail controls. The required animation clips and cross-fade durations are defined in `dog_rig_manifest.json`. The initial budget is 12,000 triangles, with an 18,000-triangle ceiling and a 2K texture target before Android performance testing.

The next asset step is to create or supply a legally usable GLB matching this contract, validate it in a glTF viewer, then load it through the `flutter_scene` build hook and `loadScene('assets/models/dog/dog.glb')`. Until that file exists, the app must keep the existing 2D renderer as its production fallback rather than silently substituting a fake 3D dog.

## Measured prototype facts (2026-09-25, read from the committed binary)

- Valid glTF 2.0 binary, 113,456 bytes; ~4,920 triangles across 20 primitives (inside the 12,000-triangle target).
- 21 named nodes, 5 materials, 1 embedded image/texture; **0 animations, 0 skins** — a static prototype, as declared.
- Node names use Blender-style dots (`Eye.L`, `Ear.L`, `Tail`, `TailTip`); the runtime therefore resolves contract joints through case-tolerant clip lookup and joint-name aliases, and ignores missing clips.
- Known contract gaps (production gate): no `Jaw`, no eyelids, no `Tail_01..03` chain (only `Tail`/`TailTip`), and the name `Paw` is reused 4 times instead of unique `Paw_FL/FR/BL/BR` joints.
- Device verification (visual QA, authored-clip binding, frame-time profiling) is pending a real rigged asset and representative Android hardware.
