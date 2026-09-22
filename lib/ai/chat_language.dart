enum ChatLanguage {
  arabic('ar'),
  english('en'),
  unknown('auto');

  const ChatLanguage(this.code);
  final String code;
}

/// Lightweight offline language detector for short pet-chat messages.
/// It intentionally uses script counts instead of locale or network APIs.
class ChatLanguageDetector {
  static ChatLanguage detect(String text) {
    var arabic = 0;
    var latin = 0;
    for (final rune in text.runes) {
      if ((rune >= 0x0600 && rune <= 0x06ff) ||
          (rune >= 0x0750 && rune <= 0x077f) ||
          (rune >= 0x08a0 && rune <= 0x08ff)) {
        arabic++;
      } else if ((rune >= 0x0041 && rune <= 0x005a) ||
          (rune >= 0x0061 && rune <= 0x007a)) {
        latin++;
      }
    }
    if (arabic == 0 && latin == 0) return ChatLanguage.unknown;
    if (arabic > latin) return ChatLanguage.arabic;
    if (latin > arabic) return ChatLanguage.english;
    return ChatLanguage.unknown;
  }
}
