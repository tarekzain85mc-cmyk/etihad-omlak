import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/theme_picker.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.themeMode,
    required this.onThemeChanged,
    required this.onSignOut,
    super.key,
  });

  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('عمارة النخيل'),
            Text('ساكن', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'الإشعارات',
            onPressed: () {},
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_outlined),
            ),
          ),
          ThemePicker(value: themeMode, onChanged: onThemeChanged),
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: onSignOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _AnnouncementCard(),
          const SizedBox(height: 20),
          const _DueCard(),
          const SizedBox(height: 20),
          Text(
            'نظرة سريعة',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const _SummaryGrid(),
          const SizedBox(height: 20),
          Text(
            'إجراءات سريعة',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _QuickAction(
                icon: Icons.receipt_long_outlined,
                label: 'رفع إيصال',
              ),
              _QuickAction(
                icon: Icons.how_to_vote_outlined,
                label: 'التصويتات',
              ),
              _QuickAction(icon: Icons.handyman_outlined, label: 'طلب صيانة'),
              _QuickAction(icon: Icons.payments_outlined, label: 'طرق الدفع'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.campaign_outlined, color: colors.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إعلان مهم',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'سيتم إجراء صيانة للمصعد يوم السبت من 10 صباحًا إلى 2 ظهرًا.',
                    style: TextStyle(color: colors.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DueCard extends StatelessWidget {
  const _DueCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('المستحق على وحدتك'),
            const SizedBox(height: 8),
            Text(
              '1,250 ج.م',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text('موعد الاستحقاق: 15 نوفمبر 2026'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('عرض طرق الدفع'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: const [
        _SummaryTile(
          icon: Icons.check_circle_outline,
          value: '8',
          label: 'دفعات مكتملة',
        ),
        _SummaryTile(
          icon: Icons.receipt_outlined,
          value: '3',
          label: 'فواتير العمارة',
        ),
        _SummaryTile(
          icon: Icons.trending_down,
          value: '12',
          label: 'مصروفًا منشورًا',
        ),
        _SummaryTile(
          icon: Icons.how_to_vote_outlined,
          value: '1',
          label: 'تصويت مفتوح',
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(avatar: Icon(icon), label: Text(label), onPressed: () {});
  }
}
