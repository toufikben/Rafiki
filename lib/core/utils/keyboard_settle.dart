import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Dismisses the keyboard and waits until the platform insets actually
/// settle back to zero (or a timeout expires) before the caller pops a
/// route. Just calling `unfocus()` is NOT enough: the keyboard dismissal
/// animates over several frames, and tearing down a dialog or bottom-sheet
/// route while a MediaQuery/focus dependent is still registered trips
/// `InheritedElement.debugDeactivated` (`_dependents.isEmpty`) and
/// red-screens the app. Verified on-device: unfocus alone, and even
/// unfocus plus a fixed 300ms delay, still crashed; waiting for the real
/// inset signal is what works.
///
/// Returns false when [context] unmounts mid-wait so callers can skip the
/// pop; callers must still guard the pop itself with a `mounted` check to
/// satisfy `use_build_context_synchronously`.
Future<bool> settleKeyboardForPop(BuildContext context) async {
  if (!context.mounted) return false;
  FocusScope.of(context).unfocus();
  // Force the platform IME down as well: on some keyboards (e.g. Gboard
  // with its text-editing toolbar) Flutter-side unfocus alone leaves the
  // input connection half-alive and the insets never settle.
  try {
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  } catch (_) {
    // Best effort only; the inset wait below is the real gate.
  }
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsedMilliseconds < 2000) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!context.mounted) return false;
    if (MediaQuery.viewInsetsOf(context).bottom <= 0) return true;
  }
  return context.mounted;
}
