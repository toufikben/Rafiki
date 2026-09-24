# تقرير تقدم Batch 8 وBatch 9

**المشروع:** Rafiq / Rafiki  
**حالة الجولة:** إغلاق شاشة تأكيد تنزيل النموذج ضمن Batch 9
**نتيجة التحقق التاريخية:** `flutter analyze` ناجح، و`flutter test -j 1` ناجح بعدد 32 اختبارًا، و`flutter build apk --debug` ناجح. مراجعة المصدر في 24 سبتمبر 2026 وجدت 33 تصريح اختبار عبر سبعة ملفات؛ إعادة التشغيل مطلوبة لتحديث النتيجة.

## ملخص التنفيذ

| المجال | ما تم تنفيذه في هذه الجولة | الحالة | المتبقي |
|---|---|---|---|
| Batch 8 — runtime animation | إضافة `DogAnimationRuntime` إلى مشهد الكلب؛ يقرأ clips المضمنة في GLB، ينشئ `AnimationClip`، يدعم loop، اختيار clip، وإجراء crossfade بين الحركة الحالية والتالية | منفذ ومحلل ومبني | يحتاج GLB إنتاجيًا يحتوي skeleton وclips فعلية، ثم تحقق بصري وأداء على Android |
| Batch 8 — prototype safety | عندما لا يحتوي GLB الحالي على animations، يبقى المشغل no-op ولا يعطل عرض النموذج أو fallback | منفذ | لا توجد فجوة وظيفية في النسخة الحالية |
| Batch 9 — explicit model install | إضافة `LocalModelManager` وتثبيت نموذج `.litertlm` من file picker أو URL | منفذ | تحسين صلاحيات المنصة ورسائل الخطأ |
| Batch 9 — progress and cancellation | progress callback و`CancelToken` وزر إلغاء أثناء التثبيت | منفذ | اختبار cancellation مع تنزيل حقيقي على Android |
| Batch 9 — model lifecycle | list installed، uninstall، cleanup orphaned storage، active model وstorage usage | منفذ | اختبار lifecycle على Android |
| Batch 9 — privacy boundary | لا يوجد تنزيل تلقائي؛ التثبيت لا يبدأ إلا بعد ضغط المستخدم؛ fallback يعمل بدون نموذج؛ تحذير Wi-Fi/mobile-data | منفذ | لا توجد فجوة وظيفية؛ تحسين free-space إن توفر API |
| Batch 9 — chat quality | fallback حتمي، كشف العربية/الإنجليزية، حد 12 دورة للسجل native، وإلغاء التوليد بزر stop | منفذ جزئي | runtime failure injection |
| Batch 9 — model preflight | تحقق extension، وجود الملف، minimum size، وصحة URL وHEAD metadata قبل التثبيت | منفذ | اختبار Android فعلي |

## ملفات الجولة

| الملف | الغرض |
|---|---|
| `lib/render/dog_animation_runtime.dart` | ربط clips المضمنة في GLB وتشغيلها مع crossfade |
| `lib/render/dog_scene_view.dart` | دمج runtime داخل عقدة الكلب |
| `lib/ai/local_model_manager.dart` | boundary لإدارة تثبيت وحذف وإلغاء نماذج LiteRT-LM |
| `lib/ai/model_install_preflight.dart` | فحص المصادر المحلية والشبكية قبل أي تثبيت |
| `lib/ai/chat_language.dart` | كشف العربية والإنجليزية دون شبكة |
| `test/batch9_quality_test.dart` | اختبارات كشف اللغة وpreflight للملفات والروابط |
| `lib/features/settings/settings_screen.dart` | واجهة اختيار ملف أو URL، progress، retry، cancel، storage، active model والحذف |
| `ROADMAP.md` | تحديث حالة Batch 8 و9 وبوابات القبول |

## بوابة التحقق

| الفحص | النتيجة |
|---|---|
| Flutter analyze | ناجح — لا توجد issues |
| Flutter tests | ناجح تاريخيًا — 32 من 32؛ الحالة الحالية 33 تصريحًا وتحتاج إعادة تشغيل |
| Debug APK | ناجح — `build/app/outputs/flutter-apk/app-debug.apk` |
| اختبار GLB إنتاجي rigged | لم يُنفذ — الأصل الحالي prototype ثابت |
| اختبار تنزيل نموذج فعلي | لم يُنفذ — يتطلب URL/ملف نموذج مرخص وحجمًا كبيرًا |
| Android visual/performance QA | لم يُنفذ — يتطلب جهاز Android فعلي |

## القرار الهندسي

لم يتم تضمين نموذج لغة أو GLB إنتاجي افتراضيًا؛ ذلك يحافظ على حجم المستودع وحقوق الترخيص ويمنع التنزيلات غير المقصودة. تم الآن إغلاق file picker وstorage/active-model UX وحد السجل وإلغاء التوليد وكشف العربية/الإنجليزية وpreflight الأساسي للمصادر وشاشة تأكيد تنزيل غنية. الخطوات التالية ذات الأولوية هي اختبار نموذج مرخص فعليًا وruntime failure injection على Android، مع تحسين free-space إذا توفر API موثوق.
