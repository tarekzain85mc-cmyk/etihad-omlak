import 'package:flutter/material.dart';

import '../domain/announcement.dart';

String formatPublishedAt(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)} '
      '${two(value.hour)}:${two(value.minute)}';
}

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({required this.announcements, super.key});

  final List<Announcement> announcements;

  @override
  Widget build(BuildContext context) {
    final items = sortAnnouncements(announcements);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('أخبار العمارة'),
      ),
      body: items.isEmpty
          ? const Center(child: Text('لا توجد أخبار منشورة بعد'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) => AnnouncementTile(item: items[index]),
            ),
    );
  }
}

class AnnouncementTile extends StatelessWidget {
  const AnnouncementTile({required this.item, super.key});

  final Announcement item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                item.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (item.isPinned || item.isImportant) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (item.isPinned)
                    const Semantics(
                      label: 'خبر مثبت',
                      child: Chip(label: Text('مثبت')),
                    ),
                  if (item.isImportant)
                    const Semantics(
                      label: 'خبر مهم',
                      child: Chip(label: Text('مهم')),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(item.body),
            const SizedBox(height: 8),
            Text(
              formatPublishedAt(item.publishedAt),
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
