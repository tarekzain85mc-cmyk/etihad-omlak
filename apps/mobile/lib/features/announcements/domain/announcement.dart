class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
    this.isPinned = false,
    this.isImportant = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime publishedAt;
  final bool isPinned;
  final bool isImportant;
}

/// Pinned first, then newest [Announcement.publishedAt], then [Announcement.id]
/// ascending. The important flag never affects order.
List<Announcement> sortAnnouncements(Iterable<Announcement> items) {
  final sorted = items.toList();
  sorted.sort((a, b) {
    if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
    final byTime = b.publishedAt.compareTo(a.publishedAt);
    if (byTime != 0) return byTime;
    return a.id.compareTo(b.id);
  });
  return sorted;
}
