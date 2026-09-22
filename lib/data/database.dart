import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../core/models/pet_state.dart';

class Database {
  static Isar? _isar;
  static bool _initialized = false;

  static Isar get isar {
    if (_isar == null) {
      throw StateError('Database not initialized. Call Database.init() first.');
    }
    return _isar!;
  }

  static bool get isReady => _initialized;

  static Future<void> init({String? directory, String name = 'rafiq_db'}) async {
    if (_initialized) return;
    final dir = directory == null
        ? await getApplicationDocumentsDirectory()
        : null;
    _isar = await Isar.open(
      [PetStateSchema],
      directory: directory ?? dir!.path,
      name: name,
    );
    _initialized = true;
  }

  static Future<PetState?> getPet() async {
    if (!_initialized) await init();
    return _isar!.petStates.where().findFirst();
  }

  static Future<void> savePet(PetState pet) async {
    if (!_initialized) await init();
    await _isar!.writeTxn(() async {
      await _isar!.petStates.put(pet);
    });
  }

  static Future<void> deleteAll() async {
    if (!_initialized) await init();
    await _isar!.writeTxn(() async {
      await _isar!.petStates.clear();
    });
  }

  /// Closes the store so integration tests can reopen it from a clean path.
  /// Production callers normally keep the singleton open for the app lifetime.
  static Future<void> close({bool deleteFromDisk = false}) async {
    final instance = _isar;
    _isar = null;
    _initialized = false;
    if (instance != null) {
      await instance.close(deleteFromDisk: deleteFromDisk);
    }
  }
}
