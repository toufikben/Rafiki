/// Deterministic cooldown policy for one-shot audio cues.
///
/// Keeping time outside the audio plugin makes rate limiting testable without
/// initializing platform audio channels. Production uses [DateTime.now],
/// while tests can provide a monotonic fake clock.
class AudioCooldownPolicy {
  AudioCooldownPolicy({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final Map<String, DateTime> _lastPlayed = <String, DateTime>{};

  bool allow(String cue, Duration minimumGap) {
    final current = _now();
    final previous = _lastPlayed[cue];
    if (previous != null && current.difference(previous) < minimumGap) {
      return false;
    }
    _lastPlayed[cue] = current;
    return true;
  }

  void reset() => _lastPlayed.clear();
}
