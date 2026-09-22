# تقرير تقدم Batch 8 وBatch 9

**المشروع:** Rafiq / Rafiki  
**حالة الجولة:** تنفيذ الجولة الأولى من Batch 9 والتحقق منها
**نتيجة التحقق:** `flutter analyze` ناجح، و`flutter test -j 1` ناجح بعدد 27 اختبارًا، و`flutter build apk --debug` ناجح.

## ملخص التنفيذ

| المجال | ما تم تنفيذه في هذه الجولة | الحالة | المتبقي |
|---|---|---|---|
| Batch 8 — runtime animation | إضافة `DogAnimationRuntime` إلى مشهد الكلب؛ يقرأ clips المضمنة في GLB، ينشئ `AnimationClip`، يدعم loop، اختيار clip، وإجراء crossfade بين الحركة الحالية والتالية | منفذ ومحلل ومبني | يحتاج GLB إنتاجيًا يحتوي skeleton وclips فعلية، ثم تحقق بصري وأداء على Android |
| Batch 8 — prototype safety | عندما لا يحتوي GLB الحالي على animations، يبقى المشغل no-op ولا يعطل عرض النموذج أو fallback | منفذ | لا توجد فجوة وظيفية في النسخة الحالية |
| Batch 9 — explicit model install | إضافة `LocalModelManager` وتثبيت نموذج `.litertlm` من file picker أو URL | منفذ | إضافة preflight لحجم النموذج وصلاحيات المنصة |
| Batch 9 — progress and cancellation | progress callback و`CancelToken` وزر إلغاء أثناء التثبيت | منفذ | اختبار cancellation مع تنزيل حقيقي على Android |
| Batch 9 — model lifecycle | list installed، uninstall، cleanup orphaned storage، active model وstorage usage | منفذ | اختبار lifecycle على Android |
| Batch 9 — privacy boundary | لا يوجد تنزيل تلقائي؛ التثبيت لا يبدأ إلا بعد ضغط المستخدم؛ fallback يعمل بدون نموذج؛ تحذير Wi-Fi/mobile-data | منفذ | تأكيد حجم التخزين قبل التنزيل |
| Batch 9 — chat quality | fallback حتمي، حد 12 دورة للسجل native، وإلغاء التوليد بزر stop | منفذ جزئي | language detection وruntime failure injection |

## ملفات الجولة

| الملف | الغرض |
|---|---|
| `lib/render/dog_animation_runtime.dart` | ربط clips المضمنة في GLB وتشغيلها مع crossfade |
| `lib/render/dog_scene_view.dart` | دمج runtime داخل عقدة الكلب |
| `lib/ai/local_model_manager.dart` | boundary لإدارة تثبيت وحذف وإلغاء نماذج LiteRT-LM |
| `lib/features/settings/settings_screen.dart` | واجهة اختيار ملف أو URL، progress، retry، cancel، storage، active model والحذف |
| `ROADMAP.md` | تحديث حالة Batch 8 و9 وبوابات القبول |

## بوابة التحقق

| الفحص | النتيجة |
|---|---|
| Flutter analyze | ناجح — لا توجد issues |
| Flutter tests | ناجح — 27 من 27 |
| Debug APK | ناجح — `build/app/outputs/flutter-apk/app-debug.apk` |
| اختبار GLB إنتاجي rigged | لم يُنفذ — الأصل الحالي prototype ثابت |
| اختبار تنزيل نموذج فعلي | لم يُنفذ — يتطلب URL/ملف نموذج مرخص وحجمًا كبيرًا |
| Android visual/performance QA | لم يُنفذ — يتطلب جهاز Android فعلي |

## القرار الهندسي

لم يتم تضمين نموذج لغة أو GLB إنتاجي افتراضيًا؛ ذلك يحافظ على حجم المستودع وحقوق الترخيص ويمنع التنزيلات غير المقصودة. تم الآن إغلاق file picker وstorage/active-model UX وحد السجل وإلغاء التوليد. الخطوات التالية ذات الأولوية هي إضافة preflight لحجم النموذج واختبار نموذج مرخص فعليًا، ثم language detection وruntime failure injection على Android.
