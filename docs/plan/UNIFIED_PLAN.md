# الخطة الموحدة

## حالات العمل

`PLANNED → READY → IN_PROGRESS → REVIEW → COMPLETE`، أو `BLOCKED` بسبب موثق.

## M0 — Foundation

- `M0-001` Bootstrap Flutter، بنية المجلدات، RTL والثيمات. `COMPLETE`
- `M0-002` GitHub، CI، حماية الأسرار وقوالب PR. `COMPLETE`
  - GitHub Actions رقم `42698268081` نجح على commit `822ec20`.
  - Secret scan وعزل Strix وFlutter format/analyze/tests وبناء APK كلها ناجحة.
- `M0-003` PRD، المعمارية وThreat Model. `COMPLETE`
- `M0-004` Supabase local structure ومخطط أولي بلا Production. `IN_PROGRESS`

## التشغيل المستمر

- مشروع `etihad-omlak` مفتوح في Antigravity ويستخدم `.agents/skills` وContext7.
- منسق Claude Cloud مجدول يوميًا للمستودع؛ مهارات Claude المحلية وContext7
  project MCP ما زالتا تتطلبان موافقة Workspace Trust وMCP داخل الجلسة المحلية.
- مراقب Codex المحلي نشط مرتين يوميًا، وينفذ مهمة آمنة واحدة على فرع مستقل
  دون دمج تلقائي للتغييرات الحساسة.

## M1 — الهوية وعزل العمارات

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
