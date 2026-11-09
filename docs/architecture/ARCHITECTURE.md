# المعمارية

## الاختيار

Flutter + Supabase، بهيكل قريب من MVVM:

```text
View → ViewModel/Controller → Repository → Service/Supabase
                         ↘ Domain use cases
```

## مجلدات التطبيق

```text
apps/mobile/lib/
  app/                 # bootstrap, router, theme, localization
  core/                # errors, result, permissions, shared widgets
  features/
    auth/
    buildings/
    dashboard/
    billing/
    expenses/
    payments/
    announcements/
    polls/
    maintenance/
    security/
  data/
```

## نموذج البيانات الأساسي

- `profiles`
- `buildings`
- `building_memberships`
- `units`
- `unit_occupancies`
- `billing_cycles`, `charge_rules`, `charges`
- `payments`, `payment_allocations`
- `expenses`, `expense_documents`, `building_bills`
- `announcements`
- `polls`, `poll_options`, `poll_votes`
- `maintenance_requests`, `work_orders`, `assets`, `vendors`
- `notifications`, `notification_deliveries`
- `audit_events`

كل سجل تابع لعمارة يحمل `building_id`. الدالة الخادمية `has_permission(building_id, permission)` هي بوابة RLS للأدوار الدقيقة.

## حدود الأمان

- تطبيق Flutter عميل غير موثوق.
- Supabase RLS وFunctions تفرضان العضوية والصلاحيات.
- مفاتيح service role وFawry وتوقيع Android تبقى على الخادم/خزنة CI.
- الملفات الخاصة في Storage تحت `building_id/...` وروابطها مؤقتة.
- كل webhook يراجع التوقيع والوقت و`idempotency_key`.
