/// Tiny in-memory breadcrumb log for the on-device diagnostics screen.
///
/// Suspicious spots (dialog open/close, chat send, install start/finish)
/// record one-line events with timestamps. The diagnostics screen shows the
/// latest events and includes them in the copyable report, so a crash can
/// be matched to exactly what the user tapped just before it.
class DiagEvent {
  DiagEvent(this.time, this.message);

  final DateTime time;
  final String message;
}

class DiagLog {
  static final List<DiagEvent> _events = <DiagEvent>[];

  static const int maxEvents = 100;

  static void event(String message) {
    _events.add(DiagEvent(DateTime.now(), message));
    if (_events.length > maxEvents) {
      _events.removeRange(0, _events.length - maxEvents);
    }
  }

  static List<DiagEvent> snapshot() => List<DiagEvent>.unmodifiable(_events);

  static void clear() => _events.clear();
}
