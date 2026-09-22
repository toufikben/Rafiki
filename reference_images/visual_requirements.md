# Rafiq — Visual Requirements v1

## Scope

The four Google Drive images were used only as visual references. No instruction, code, or embedded content from the files was executed. The target platform is Android, and the target direction is a unified stylized 3D character family rather than photorealistic animals.

## Shared art direction

| Requirement | Decision |
|---|---|
| Rendering style | Stylized 3D cartoon with soft rounded forms and premium studio lighting |
| Character language | Oversized expressive eyes, compact bodies, readable silhouettes, friendly facial expressions |
| Materials | Soft matte-to-satin fur/feather material, controlled specular highlights, separate color zones for belly and face |
| Lighting | Warm key light, soft fill, contact shadow, subtle ambient occlusion; avoid harsh realistic fur noise |
| Camera | Front three-quarter view as the default, with a short follow/orbit response to interaction |
| Runtime target | Android only; first target is a mid-range device at 60 FPS with a quality fallback |
| Asset format | Rigged GLB/glTF, one shared skeleton convention where practical, compressed textures and separate animation clips |

## Character specifications

| Character | Shape and identity | Required rig controls | Required animation set |
|---|---|---|---|
| Monkey | Warm brown fur, peach face and belly, oversized head, very large ears, bright brown eyes, smiling mouth, curled expressive tail and top hair tuft | Head, jaw, eyelids, ears, fingers/toes, spine/chest, segmented tail | Idle breathing, blink, ear wiggle, walk, run, jump, laugh/play, sit, sleep, surprised, happy |
| Puppy | White base coat with black floppy ears and patches, warm tan accents, large head, short muzzle, black nose, seated friendly pose and curled tail | Head, jaw, eyelids, floppy ears, four legs/paws, segmented tail, muzzle/chest material zones | Idle, blink, sit/stand, walk, run, sniff, eat, play bow, sleep, tail wag, happy jump, sad head-down |
| Fox | Orange/copper coat, cream muzzle/chest/tail tip, large triangular ears, white cheek ruff, large fluffy tail, seated on a rock in the reference | Head, jaw, eyelids, ears, four paws, spine, segmented fluffy tail, muzzle/chest zones | Idle, blink, ear twitch, tail swish, sit/stand, walk, run, sniff, pounce/play, happy jump, sleep curled, alert/startled |
| Penguin | Deep navy-blue body, cream face and belly, orange beak and feet, rounded pear-shaped body, short flippers, tiny head tuft | Head, eyelids, beak, flippers, feet, body squash/stretch controls | Idle breathing, blink, waddle, short run, flap, hop, slide, eat, sleep, excited flap, startled turn |

## Animation principles

The animation system should be clip-driven for locomotion and state-driven for decisions. Idle must contain visible but restrained breathing, blinking, eye focus changes, and secondary motion. Locomotion should use root motion or a stable in-app movement controller, with cross-fading between idle, walk, run, and stop. Ears, tail, flippers, and facial controls should receive a procedural secondary layer so that the same clip does not look robotic.

The first vertical slice should implement one animal completely before the remaining three are integrated. The recommended first slice is the puppy because it tests four-legged locomotion, floppy-ear secondary motion, facial expression, and a simple friendly silhouette. The fox is the second priority because its large tail is an important visual feature. The monkey and penguin then reuse the same rendering and behavior infrastructure with species-specific rigs.

## Flutter Scene integration requirements

The selected runtime renderer is `flutter_scene` 0.23.0 on Android with Flutter GPU/Impeller enabled. The integration must use the build-time asset pipeline for shipped GLB files rather than parsing every model at runtime. The first implementation should verify model loading, PBR material appearance, a single animation clip, clip blending, touch/raycast interaction, and frame timing before adding particles or post-processing.

Each model should be kept modular: body mesh, eyes, eyelids, mouth/beak, ears or flippers, and tail should be independently addressable when the source pipeline supports it. Textures should use compressed formats and include a lower-detail fallback. The initial acceptance target is a visually stable 60 FPS on a mid-range Android device; if the full-quality scene misses that target, reduce texture resolution, shadow quality, post-processing, and model LOD before changing the character style.

## Acceptance criteria for the next batch

| Check | Pass condition |
|---|---|
| Visual match | The first model preserves the reference silhouette, palette, eye proportions, and defining accessories |
| Animation | Idle, walk, run, sleep, eat, and one emotional animation blend without visible popping |
| Interaction | Tap/drag changes attention or facing direction without breaking animation playback |
| Performance | No sustained jank in the Android debug build; frame timing is measured rather than assumed |
| Asset quality | GLB loads without missing textures, broken skeletons, or excessive file size |
| Code quality | `flutter analyze`, unit tests, and an Android build pass before the next batch begins |

## Current batch result

The visual analysis is complete for four references: monkey, puppy, fox, and penguin. No production code was changed in this batch. The next batch is asset/runtime validation: confirm the actual `flutter_scene` API in the installed Flutter environment, prepare or obtain rigged GLB assets that are legally usable, and implement the puppy vertical slice first.
