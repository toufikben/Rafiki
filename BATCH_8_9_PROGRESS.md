# تقرير تقدم Batch 8 وBatch 9

**المشروع:** Rafiq / Rafiki  
**حالة الجولة:** تنفيذ ودمج أولي موثق  
**نتيجة التحقق:** `flutter analyze` ناجح، و`flutter test -j 1` ناجح بعدد 27 اختبارًا، و`flutter build apk --debug` ناجح.

## ملخص التنفيذ

| المجال | ما تم تنفيذه في هذه الجولة | الحالة | المتبقي |
|---|---|---|---|
| Batch 8 — runtime animation | إضافة `DogAnimationRuntime` إلى مشهد الكلب؛ يقرأ clips المضمنة في GLB، ينشئ `AnimationClip`، يدعم loop، اختيار clip، وإجراء crossfade بين الحركة الحالية والتالية | منفذ ومحلل ومبني | يحتاج GLB إنتاجيًا يحتوي skeleton وclips فعلية، ثم تحقق بصري وأداء على Android |
| Batch 8 — prototype safety | عندما لا يحتوي GLB الحالي على animations، يبقى المشغل no-op ولا يعطل عرض النموذج أو fallback | منفذ | لا توجد فجوة وظيفية في النسخة الحالية |
| Batch 9 — explicit model install | إضافة `LocalModelManager` لتثبيت نموذج `.litertlm` من ملف محلي أو URL | منفذ | إضافة file picker حقيقي بدل المسار النصي |
| Batch 9 — progress and cancellation | progress callback و`CancelToken` وزر إلغاء أثناء التثبيت | منفذ | اختبار cancellation مع تنزيل حقيقي على Android |
| Batch 9 — model lifecycle | list installed، uninstall، cleanup orphaned storage | منفذ | عرض active-model identity وstorage usage في الواجهة |
| Batch 9 — privacy boundary | لا يوجد تنزيل تلقائي؛ التثبيت لا يبدأ إلا بعد ضغط المستخدم؛ fallback يعمل بدون نموذج | منفذ | إضافة رسالة Wi-Fi وتأكيد حجم التخزين قبل التنزيل |
| Batch 9 — chat quality | fallback حتمي ومختبر، وسياق الحيوان يمر للنموذج عند توفره | منفذ جزئي | history limit، response cancellation، language detection، runtime failure injection |

## ملفات الجولة

| الملف | الغرض |
|---|---|
| `lib/render/dog_animation_runtime.dart` | ربط clips المضمنة في GLB وتشغيلها مع crossfade |
| `lib/render/dog_scene_view.dart` | دمج runtime داخل عقدة الكلب |
| `lib/ai/local_model_manager.dart` | boundary لإدارة تثبيت وحذف وإلغاء نماذج LiteRT-LM |
| `lib/features/settings/settings_screen.dart` | واجهة صريحة لإدخال مسار محلي أو URL ومتابعة التثبيت والحذف |
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

لم يتم تضمين نموذج لغة أو GLB إنتاجي افتراضيًا؛ ذلك يحافظ على حجم المستودع وحقوق الترخيص ويمنع التنزيلات غير المقصودة. الكود الحالي يجهز نقاط الدمج ويغلق السلوك الآمن في حال غياب الأصول. الخطوات التالية ذات الأولوية هي إضافة file picker وstorage/active-model UX، ثم اختبار نموذج مرخص فعليًا، وبعدها استبدال GLB prototype بنموذج rigged والتحقق من clips على جهاز Android.
