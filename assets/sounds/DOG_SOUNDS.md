# Dog interactive sound assets

The dog sound assets in this directory were generated as original non-musical sound effects for this application. They are used as short Foley clips and a pair of loopable body-sound beds. The app does not treat them as speech or music.

| File | Runtime role | Playback policy |
|---|---|---|
| `dog_breathing.mp3` | Calm breathing during idle, walking, and sleep | Dedicated looping body channel with low volume |
| `dog_panting.mp3` | Excited breathing during play and running | Dedicated looping body channel; volume follows movement speed |
| `dog_bark.mp3` | Friendly bark on celebration and selected interactions | One-shot channel with a three-second cooldown |
| `dog_whine.mp3` | Gentle emotional response during begging, hiding, or clean interaction | One-shot channel with a five-second cooldown |
| `dog_steps.mp3` | Small paw-step group for walking and running | Dedicated step channel with cadence throttling |

The audio mixer intentionally keeps body loops, steps, and one-shot reactions on separate `audioplayers` instances. This prevents a bark or step clip from cutting off breathing. Sounds are enabled only when the pet species is identified as dog, puppy, or the Arabic equivalent `كلب`; other pets keep the existing generic purr/meow/happy sounds.

All playback is local and offline. The generated assets are application sound effects, not claims of recordings from a named animal or a licensed third-party library.
