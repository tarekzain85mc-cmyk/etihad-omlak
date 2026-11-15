# M0-006 — ملف APK تجريبي قابل للتنزيل

## الحالة والمسؤول

`REVIEW` بواسطة Codex Cloud على فرع
`phase/M0-006-test-apk-artifact`. هذه مهمة CI مستقلة عن Auth وقاعدة البيانات،
ولا تدمج أو تنشر إصدارًا على المتجر.

## الهدف

إتاحة APK Debug من نفس التشغيل الذي يجتاز تنسيق Flutter والتحليل والاختبارات
والبناء، حتى يستطيع المالك تنزيل النسخة وتجربة واجهة M0 الحالية على Android.

## Skills used

- ci-cd-and-automation
- git-workflow-and-versioning
- graphify
- strix-static-review

## النطاق

1. احتفظ بكل بوابات CI الحالية قبل البناء.
2. ارفع `app-debug.apk` باسم واضح بعد نجاح البناء فقط.
3. افشل التشغيل إذا لم يوجد الملف بدل إظهار نجاح وهمي.
4. احتفظ بالملف 14 يومًا لتجربة المالك، بلا signing أو Release أو Play Store.

## حدود النسخة التجريبية

- هذه نسخة Demo لواجهة RTL والثيمات والتنقل والأخبار ذات الحالة الفارغة.
- زر الدخول الحالي لا يصادق مستخدمًا، والبيانات المالية الظاهرة تجريبية.
- لا Supabase مستضاف، ولا بيانات سكان، ولا دفع، ولا عزل عمارات مثبت داخل APK.
- لا يُعد الملف إصدار `v0.1.0-alpha`؛ ذلك يبقى بعد M1 واختبارات العزل.

## اختبارات القبول

- CI يجتاز Secret scan وعزل Strix وFlutter format/analyze/test.
- `flutter build apk --debug` ينجح.
- Artifact باسم `etihad-omlak-debug-apk` يحتوي `app-debug.apk`.
- لا أسرار ولا keystore ولا signing داخل Git أو Artifact.

## الدليل

- [CI #43592519416](https://github.com/tarekzain85mc-cmyk/etihad-omlak/actions/runs/43592519416)
  نجح على `c84647d`: Secret scan وعزل Strix وFlutter format/analyze و14 اختبارًا
  وبناء APK Debug.
- رفع Artifact باسم `etihad-omlak-debug-apk`، حجمه المضغوط 75,265,916 بايت،
  وينتهي في 2026-11-28. Digest الأرشيف:
  `sha256:46648744ab4ace73535ae9c9f58b9af784412b2d145523cf435a547f889ed11a`.

## الرجوع

حذف خطوة `Upload debug APK` يعيد CI إلى السلوك السابق دون تغيير التطبيق أو
قاعدة البيانات.
