# M0-004 — Supabase foundation

## الهدف

إنشاء بنية Supabase محلية ومخطط Postgres أولي يعزل كل عمارة، ويربط العضويات
والأدوار والوحدات والدعوات وسجل التدقيق، بلا مشروع Production أو أسرار أو
بيانات سكان حقيقية.

## النطاق

- Migration واحدة قابلة لإعادة البناء محليًا.
- جداول الهوية المؤسسية الأساسية فقط: profiles، buildings، units، memberships،
  roles، occupancies، invitations وaudit events.
- RLS للقراءة الآمنة ومنع تعديل العضويات والأدوار مباشرة من العميل.
- اختبارات pgTAP لبنية المخطط والعزل بين عمارتين.
- لا مالية أو دفع أو تكامل أعمال مع Storage أو Edge Functions أو ربط Flutter في
  هذه المهمة؛ خدمة Storage المحلية معطلة في `config.toml`.

## Skills used

- planning-and-task-breakdown
- security-and-hardening
- test-driven-development
- documentation-and-adrs
- graphify
- strix-static-review

## قرارات الأمان

- تطبيق Flutter عميل غير موثوق، ولا توجد صلاحية إدارية في JWT user metadata.
- دوال RLS المساعدة داخل schema باسم `private`، وتستخدم `security definer` مع
  `search_path = ''` ومنح Execute صريحًا لـ`authenticated` فقط.
- لا تُخزن دعوة خام؛ المخطط يفرض `token_digest` بطول 32 بايت ولا يمنح العميل
  قراءته. حساب SHA-256 داخل RPC مؤجل إلى M1.
- روابط الوحدة والعضوية تستخدم مفاتيح مركبة تتضمن `building_id` لمنع الربط
  بين عمارتين.
- منح وسحب الأدوار وقبول الدعوة ستتم عبر RPC ذرية ومدققة في M1، لذلك لا توجد
  سياسات INSERT/UPDATE/DELETE مباشرة لهذه الجداول في M0.
- حذف آخر Admin/President محمي بقيود مؤجلة داخل المعاملة الواحدة. لا يُسمح
  بإطلاق M1 قبل أن تستخدم كل RPC تغيّر الدور أو حالة العضوية قفلًا تعامليًا
  موحدًا للعمارة لمنع سباق معاملتين متوازيتين، ومنع أي مسار خدمة يتجاوز القفل.

## القبول

- `supabase db reset` يطبق migration وseed بلا خطأ عند توفر Docker وSupabase CLI.
- `supabase test db` يثبت وجود الجداول وRLS ودوال الأمان.
- مستخدم عمارة A لا يرى سجلات عمارة B.
- الساكن لا يرفع صلاحياته ولا يرى الدعوات أو سجل التدقيق.
- Admin يرى أعضاء ودعوات وسجل عمارة واحدة فقط.
- لا توجد hosted/Production endpoints أو مفاتيح أو بيانات حقيقية؛ عناوين
  `127.0.0.1` المحلية فقط موجودة في إعداد التطوير.

## Verification

- `git diff --check`: مطلوب قبل كل commit.
- Graphify: تحديث محلي بعد التغيير؛ مخرجات `graphify-out/` غير مرفوعة.
- مراجعة Strix الساكنة: محلية فقط، بلا تشغيل Strix أو رفع مصدر أو فحص هدف حي.
- اختبارات قاعدة البيانات: 30 assertion للمخطط و34 للعزل/القيود مصممة، لكن
  لا يُسجل نجاحها قبل تشغيل GitHub Actions؛ Docker غير متاح محليًا على الجهاز.
- دليل GitHub Actions والـcommit: يضافان هنا بعد نجاح CI وقبل نقل المهمة إلى
  `REVIEW`.

## مؤجل إلى M1

- RPC لإنشاء العمارة وقبول الدعوة ومنح/سحب الدور وتغيير حالة العضوية مع
  advisory transaction lock موحد وإدخال audit ذري.
- حساب SHA-256 للدعوة والتحقق من أنها غير منتهية/ملغاة/مستخدمة، ومطابقة بريد أو
  هاتف موثق، واشتراط `manage_roles` قبل أي دور مميز.
- ربط البريد/الهاتف الموثق من Supabase Auth.
- اختبارات عميل end-to-end ودورة الدعوة كاملة.

## الرجوع

المهمة محلية فقط. استخدم `supabase db reset` لإعادة بناء قاعدة التطوير. لا تطبق
هذه migration على Production قبل مراجعة M1 واختبارات العزل الكاملة.
