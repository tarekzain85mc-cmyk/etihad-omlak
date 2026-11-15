# M0-007 — High-contrast login input outline

## الحالة

`REVIEW` في [PR #7](https://github.com/tarekzain85mc-cmyk/etihad-omlak/pull/7).

## مصدر العيب

اختبار يدوي للـAPK من GitHub Actions run `43592960067` على محاكي Android 15
نجح في الفتح وRTL وإظهار كلمة المرور وحفظ الثيم والتنقل بلا crash أو Flutter
exception. لاحظ المختبر أن حقول الدخول في ثيم التباين العالي بلا إطار واضح فوق
الخلفية البيضاء. لم تُستخدم بيانات حقيقية.

## النطاق

- تعريف إطار عالي التباين داخل `InputDecorationTheme` بدل تخصيص شاشة الدخول.
- إطار أسود بعرض 2px في الحالة العادية و3px عند التركيز، فلا يعتمد التركيز على
  اللون وحده.
- الاحتفاظ بلون الخطأ الدلالي مع نفس فرق السماكة.
- Widget test يمنع رجوع غياب الإطار.
- لا Auth أو Supabase أو migrations أو أسرار.

## Skills used

- frontend-ui-engineering
- test-driven-development
- git-workflow-and-versioning
- graphify

## TDD والأدلة

- RED: [CI #43636682048](https://github.com/tarekzain85mc-cmyk/etihad-omlak/actions/runs/43636682048)
  نجح في format وanalyze، ثم فشل الاختبار الجديد وحده لأن `enabledBorder` كان
  `null`؛ 14 اختبارًا نجح وواحد فشل.
- GREEN: [CI #43636832202](https://github.com/tarekzain85mc-cmyk/etihad-omlak/actions/runs/43636832202)
  نجح في Secret scan وعزل Strix وformat وanalyze و15 اختبار Flutter وبناء APK
  Debug.
- Graphify حُدث محليًا بعد الإصلاح إلى 1083 عقدة و1027 علاقة؛
  `graphify-out/` غير مرفوع.

## القبول والرجوع

- يظل إطار حقلي الهوية وكلمة المرور مرئيًا في ثيم التباين العالي قبل التركيز
  وأثناءه.
- إعادة الاختبار اليدوي على Android 15 مطلوبة قبل إغلاق المهمة.
- الرجوع هو revert لتغيير الثيم والاختبار فقط؛ لا توجد بيانات أو migration.
