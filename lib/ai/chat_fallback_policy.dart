import '../core/models/pet_state.dart';

/// Deterministic offline response policy used when no local model is active or
/// when model generation fails. It never executes user instructions as tools
/// and only reads the pet context needed to produce a short reply.
class ChatFallbackPolicy {
  static String respond({required PetState pet, required String text}) {
    final normalized = text.trim().toLowerCase();
    if (pet.hunger < 0.22 || normalized.contains('hungry') || text.contains('جوع')) {
      return '${pet.name} يشعر بالجوع؛ وجبة صغيرة ستجعله أكثر راحة.';
    }
    if (pet.hydration < 0.22 || normalized.contains('water') || text.contains('ماء')) {
      return '${pet.name} يحتاج إلى الماء الآن.';
    }
    if (pet.energy < 0.20 || text.contains('نوم')) {
      return '${pet.name} يبدو متعباً ويحتاج إلى الراحة.';
    }
    if (pet.stress > 0.72) {
      return '${pet.name} متوتر قليلاً؛ تحدث معه بهدوء ومداعبة لطيفة قد تساعد.';
    }
    if (normalized.contains('hello') || text.contains('مرحبا') || text.contains('أهلا')) {
      return 'مرحباً! ${pet.name} سعيد بوجودك بالقرب منه.';
    }
    return '${pet.name} يسمعك ويقترب منك باهتمام.';
  }
}
