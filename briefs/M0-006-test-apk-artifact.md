# M0-006 — ملف APK تجريبي قابل للتنزيل

## الحالة والمسؤول

`IN_PROGRESS` بواسطة Codex Cloud على فرع
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

## الرجوع

حذف خطوة `Upload debug APK` يعيد CI إلى السلوك السابق دون تغيير التطبيق أو
قاعدة البيانات.
