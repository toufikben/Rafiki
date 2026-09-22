// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rafiq';

  @override
  String get chooseCompanion => 'Choose your companion';

  @override
  String get giveName => 'Give them a name...';

  @override
  String get start => 'Start';

  @override
  String get feed => 'Feed';

  @override
  String get play => 'Play';

  @override
  String get pet => 'Pet';

  @override
  String get clean => 'Clean';

  @override
  String get settings => 'Settings';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get floatingPet => 'Floating Pet';

  @override
  String get floatingPetDesc => 'Show your pet on top of other apps';

  @override
  String get deleteAllData => 'Delete All Data';

  @override
  String get deleteWarning => 'This cannot be undone';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyDescription => 'All data stays on your device';

  @override
  String get version => 'Version';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Delete everything?';

  @override
  String get confirmDeleteBody =>
      'Your pet and all memories will be permanently deleted.';

  @override
  String missesYou(Object name) {
    return '$name misses you';
  }

  @override
  String get comeBackSoon => 'Come back soon, I will wait';

  @override
  String grewUp(Object name) {
    return '$name grew up!';
  }

  @override
  String get lookHowBig => 'Look how big they are now';
}
