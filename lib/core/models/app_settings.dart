import 'package:isar/isar.dart';

part 'app_settings.g.dart';

/// App-level preferences, stored as a single row (id 0).
///
/// Deliberately separate from [PetState] so "delete all pet data" clears the
/// pet without resetting user preferences such as the sound toggle.
@collection
class AppSettings {
  Id id = 0;
  bool soundEnabled = true;
}
