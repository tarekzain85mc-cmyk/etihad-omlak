# الخطة الموحدة

## حالات العمل

`PLANNED → READY → IN_PROGRESS → REVIEW → COMPLETE`، أو `BLOCKED` بسبب موثق.

## M0 — Foundation

- `M0-001` Bootstrap Flutter، بنية المجلدات، RTL والثيمات. `COMPLETE`
- `M0-002` GitHub، CI، حماية الأسرار وقوالب PR. `COMPLETE`
  - GitHub Actions رقم `42698268081` نجح على commit `822ec20`.
  - Secret scan وعزل Strix وFlutter format/analyze/tests وبناء APK كلها ناجحة.
- `M0-003` PRD، المعمارية وThreat Model. `COMPLETE`
- `M0-004` Supabase local structure ومخطط أولي بلا Production. `REVIEW`
  - [PR #1 المسودة](https://github.com/tarekzain85mc-cmyk/etihad-omlak/pull/1)
    على فرع `phase/M0-004-supabase-foundation`؛
    [Database Tests #42836735384](https://github.com/tarekzain85mc-cmyk/etihad-omlak/actions/runs/42836735384)
    و[CI #42836735346](https://github.com/tarekzain85mc-cmyk/etihad-omlak/actions/runs/42836735346)
    نجحا على `557f054`، بما فيها 308 اختبارات pgTAP. تتضمن المصفوفة حسابًا
    واحدًا رئيسًا في عمارة وساكنًا في أخرى، وتغطي القراءة فقط؛ تغييرات الأدوار
    والتزامن باقية في M1.
  - لا دمج أو تطبيق على Production قبل مراجعة بشرية للمخطط وRLS.
- `M0-005` حفظ الثيم المختار محليًا عبر إعادة تشغيل التطبيق. `COMPLETE`
  - [PR #2](https://github.com/tarekzain85mc-cmyk/etihad-omlak/pull/2)؛
    [CI #42796812478](https://github.com/tarekzain85mc-cmyk/etihad-omlak/actions/runs/42796812478)
    نجح على `4fd5489`: Secret scan وFlutter format/analyze و10 اختبارات وبناء APK Debug.

## التشغيل المستمر

- مشروع `etihad-omlak` مفتوح في Antigravity ويستخدم `.agents/skills` وContext7.
- منسق Claude Cloud مجدول يوميًا للمستودع؛ تشغيله الأول يوم 2026-11-10
  اكتمل بلا تعديل لأن المهمة المتاحة كانت migration حساسة. في تشغيل ثانٍ يوم
  2026-11-10 نفذ M3-001 عبر PR #3، وراجع Codex اختبارات الوصول ثم دُمجت
  الواجهة. مهارات Claude المحلية وContext7 project MCP ما زالتا تتطلبان موافقة
  Workspace Trust وMCP داخل الجلسة المحلية.
- Antigravity Remote متاح في التطبيق، ومستودع GitHub ظاهر للاختيار، لكن مشروع
  Remote لاتحاد الملاك لم يُنشأ بعد؛ يحتاج تأكيد المالك قبل إتاحة الكود داخل
  بيئة Google السحابية. جلسة Remote الجارية تستطيع الاستمرار والجهاز مغلق،
  ولم تثبت أتمتة Gemini دورية مستقلة عن الجهاز بعد.
- مراقب Codex المحلي نشط مرتين يوميًا، وينفذ مهمة آمنة واحدة على فرع مستقل
  دون دمج تلقائي للتغييرات الحساسة.

## M1 — الهوية وعزل العمارات

- `M1-001` بوابة Auth وعضوية Flutter. `READY` لمسودة Antigravity/Gemini على
  فرع مستقل؛ [brief](../../briefs/M1-001-auth-client.md). لا دمج قبل مراجعة
  PR #1 واختبار التكامل الخادمي. يتجنب منسق Claude تكرار هذه المهمة.
- تسجيل البريد/الهاتف، الاسترجاع وOTP.
- العمارات والوحدات والدعوات المغلقة.
- استكمال RBAC/RLS وRPC الذرية واختبارات العزل والتزامن.

## M2 — المالية والشفافية

- دورات الاشتراك والرسوم والمتأخرات.
- المدفوعات والتخصيص والمصروفات والفواتير والإيصالات.
- Audit log وتقارير الوحدة والعمارة.

## M3 — المجتمع والتشغيل

- الأخبار والإشعارات والتصويت.
- طلبات الصيانة والأمن وأوامر العمل.
- `M3-001` واجهة الأخبار فقط. `COMPLETE` في
  [PR #3](https://github.com/tarekzain85mc-cmyk/etihad-omlak/pull/3)
  المدمج على `c9839c7`؛
  [CI main #42841162925](https://github.com/tarekzain85mc-cmyk/etihad-omlak/actions/runs/42841162925)
  نجح، بما فيه 14 اختبار Flutter وSecret scan وبناء APK. المهمة مستقلة عن M1/M2؛
  [brief](../../briefs/M3-001-announcements-ui.md):
  - أزل الإعلان المثبت الوهمي من شاشة الإنتاج، واعرض حالة فارغة واضحة إلى أن
    تتوفر بيانات حقيقية. ابنِ مكوّنات تقبل أخبارًا عادية ومثبتة ومهمة عبر مدخلات
    صريحة، مع قائمة أخبار وعودة للصفحة الرئيسية وRTL وتسميات قارئ الشاشة.
    الترتيب: المثبت أولًا، ثم وقت النشر تنازليًا، ثم المعرف تصاعديًا.
  - لا Supabase ولا صلاحيات ولا نشر أو تعديل خبر في هذه المهمة، ولا بيانات سكان.
  - اختبارات Widget للخبر المثبت وترتيب القائمة والحالة الفارغة والتنقل؛
    Flutter format/analyze/test/APK وSecret scan قبل الدمج.

## M4 — الدفع التجريبي

- Fawry Sandbox وwebhooks.
- InstaPay بإيصال واعتماد يدوي حتى توفر API رسمي تعاقدي.

## M5 — Hardening والإصدار

- مراجعة أمنية، نسخ احتياطي واسترجاع، أداء، accessibility.
- توقيع Android وGitHub Release؛ Play Store بموافقة بشرية منفصلة.

## قواعد الترتيب

- لا يبدأ الدفع قبل اكتمال عزل العمارات والمالية واختباراتهما.
- لا auto-merge لتغييرات auth/RBAC/finance/payments/migrations/secrets/release.
- لا يعمل منفذان على الفرع نفسه.
