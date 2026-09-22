// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'رفيق';

  @override
  String get chooseCompanion => 'اختر رفيقك';

  @override
  String get giveName => 'أعطه اسماً...';

  @override
  String get start => 'ابدأ';

  @override
  String get feed => 'إطعام';

  @override
  String get play => 'لعب';

  @override
  String get pet => 'لمس';

  @override
  String get clean => 'تنظيف';

  @override
  String get settings => 'الإعدادات';

  @override
  String get soundEffects => 'المؤثرات الصوتية';

  @override
  String get floatingPet => 'الحيوان العائم';

  @override
  String get floatingPetDesc => 'أظهر رفيقك فوق التطبيقات الأخرى';

  @override
  String get deleteAllData => 'حذف جميع البيانات';

  @override
  String get deleteWarning => 'لا يمكن التراجع';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacyDescription => 'جميع البيانات على جهازك';

  @override
  String get version => 'الإصدار';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get confirmDelete => 'حذف كل شيء؟';

  @override
  String get confirmDeleteBody => 'سيتم حذف رفيقك وجميع الذكريات نهائياً.';

  @override
  String missesYou(Object name) {
    return '$name يشتاق إليك';
  }

  @override
  String get comeBackSoon => 'عد قريباً، سأنتظرك';

  @override
  String grewUp(Object name) {
    return '$name كبر!';
  }

  @override
  String get lookHowBig => 'انظر كم أصبح كبيراً';
}
