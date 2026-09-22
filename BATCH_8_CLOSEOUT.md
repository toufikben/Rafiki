# إغلاق Batch 8 — الحركة ومشهد الكلب

**الحالة:** مغلق على مستوى التنفيذ البرمجي وعقد الدمج.  
**قيد الإصدار:** الأصل الحالي `dog.glb` ما يزال prototype static GLB، لذلك تبقى بوابة الأصل الإنتاجي واختبار Android الميداني خارج نطاق الإغلاق البرمجي.

## الأدلة المنفذة

| البوابة | النتيجة | الدليل |
|---|---|---|
| تحميل GLB | ناجحة | `DogSceneView` يحمّل `assets/models/dog/dog.glb` مع fallback عند الفشل |
| عقد الحركة | ناجحة | `DogAnimationController` يطابق السلوك مع clips المطلوبة |
| عقد الأصول | ناجحة | `dog_rig_manifest.json` يحتوي أسماء clips والمفاصل المطلوبة |
| runtime binding | ناجحة | `DogAnimationRuntime` يقرأ `Node.parsedAnimations` وينشئ `AnimationClip` |
| crossfade | ناجحة | انتقال أوزان clips القديمة والجديدة خلال مدة انتقال محددة |
| loop policy | ناجحة | Idle/Walk/Run/Sleep/Eat/Drink loop، والحركات القصيرة non-loop |
| fallback للأصل الثابت | ناجحة | لا يتعطل المشهد عندما لا توجد authored animations |
| secondary motion | ناجحة | بقيت طبقة الأذنين والذيل والتنفس مستقلة عن clips الإنتاجية |
| التحليل | ناجحة | `flutter analyze` — لا توجد issues |
| الاختبارات | ناجحة | `flutter test -j 1` — 27 من 27 |
| APK | ناجحة | `flutter build apk --debug` — 307 MB |

## ما تم إغلاقه

أصبحت طبقة الحركة جاهزة لاستقبال GLB rigged لاحقًا دون تغيير عقد المشهد أو إعادة كتابة منطق التشغيل. عند توفر clips بالأسماء المتفق عليها، سيقوم runtime بربطها وتشغيلها وإجراء crossfade بينها. أما الأصل الحالي، فيستمر بأمان كنسخة static prototype.

## ما لا يمكن إغلاقه داخل الكود وحده

| البند | سبب بقائه مفتوحًا |
|---|---|
| نموذج production-quality rigged | يحتاج أصلًا فنيًا مرخصًا ومطابقًا للمراجع البصرية |
| skeleton وskin weights الفعلية | غير موجودة في prototype static GLB الحالي |
| authored clips التسعة | يجب إنتاجها داخل ملف GLB النهائي وليس اختلاقها في التطبيق |
| visual QA وframe-time | تتطلب جهاز Android فعليًا وأصلًا نهائيًا |
| texture/GPU/memory budget | لا يمكن إثباتها من static prototype فقط |

## قرار الإغلاق

تم إغلاق **Batch 8 implementation gate**. لا يُعلن Batch 8 جاهزًا للنشر المرئي النهائي قبل استبدال الأصل التجريبي بالأصل الإنتاجي وتنفيذ اختبارات Android البصرية والأدائية. هذا الفصل يمنع اعتبار عقد runtime المكتمل دليلًا زائفًا على وجود animations داخل GLB الحالي.
