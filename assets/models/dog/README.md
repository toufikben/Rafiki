# Dog 3D asset contract

This directory is the asset boundary for the first `flutter_scene` vertical slice. The visual source is the puppy reference image stored at `reference_images/reference_2.jpg`. The JSON manifest beside this file is a production contract for the eventual rigged GLB; it is not a model and it does not claim that animations already exist.

The final asset must be a rigged GLB with separate eye/eyelid, jaw, floppy-ear, four-leg, paw, and three-segment tail controls. The required animation clips and cross-fade durations are defined in `dog_rig_manifest.json`. The initial budget is 12,000 triangles, with an 18,000-triangle ceiling and a 2K texture target before Android performance testing.

The next asset step is to create or supply a legally usable GLB matching this contract, validate it in a glTF viewer, then load it through the `flutter_scene` build hook and `loadScene('assets/models/dog/dog.glb')`. Until that file exists, the app must keep the existing 2D renderer as its production fallback rather than silently substituting a fake 3D dog.
