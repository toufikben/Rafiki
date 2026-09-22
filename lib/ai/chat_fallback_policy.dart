import '../core/models/pet_state.dart';
import 'chat_language.dart';

/// Deterministic offline response policy used when no local model is active or
/// when model generation fails. It never executes user instructions as tools
/// and only reads the pet context needed to produce a short reply.
class ChatFallbackPolicy {
  static String respond({required PetState pet, required String text}) {
    final normalized = text.trim().toLowerCase();
    final language = ChatLanguageDetector.detect(text);
    final english = language == ChatLanguage.english;
    if (pet.hunger < 0.22 || normalized.contains('hungry') || text.contains('جوع')) {
      return english
          ? '${pet.name} is hungry; a small meal will help.'
          : '${pet.name} يشعر بالجوع؛ وجبة صغيرة ستجعله أكثر راحة.';
    }
    if (pet.hydration < 0.22 || normalized.contains('water') || text.contains('ماء')) {
      return english
          ? '${pet.name} needs water now.'
          : '${pet.name} يحتاج إلى الماء الآن.';
    }
    if (pet.energy < 0.20 || text.contains('نوم')) {
      return english
          ? '${pet.name} looks tired and needs rest.'
          : '${pet.name} يبدو متعباً ويحتاج إلى الراحة.';
    }
    if (pet.stress > 0.72) {
      return english
          ? '${pet.name} is a little stressed; a calm voice may help.'
          : '${pet.name} متوتر قليلاً؛ تحدث معه بهدوء ومداعبة لطيفة قد تساعد.';
    }
    if (normalized.contains('hello') || text.contains('مرحبا') || text.contains('أهلا')) {
      return english
          ? 'Hello! ${pet.name} is happy you are nearby.'
          : 'مرحباً! ${pet.name} سعيد بوجودك بالقرب منه.';
    }
    return english
        ? '${pet.name} hears you and comes closer with interest.'
        : '${pet.name} يسمعك ويقترب منك باهتمام.';
  }
}
