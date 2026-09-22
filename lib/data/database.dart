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

  static Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [PetStateSchema],
      directory: dir.path,
      name: 'rafiq_db',
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
}
