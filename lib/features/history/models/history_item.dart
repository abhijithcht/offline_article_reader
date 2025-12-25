/// Model for browsing history items
class HistoryItem {
  HistoryItem({
    required this.url,
    required this.title,
    required this.viewedAt,
    this.id,
    this.imageUrl,
  });

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'] as int?,
      url: map['url'] as String,
      title: map['title'] as String,
      imageUrl: map['imageUrl'] as String?,
      viewedAt: DateTime.fromMillisecondsSinceEpoch(map['viewedAt'] as int),
    );
  }

  final int? id;
  final String url;
  final String title;
  final String? imageUrl;
  final DateTime viewedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'imageUrl': imageUrl,
      'viewedAt': viewedAt.millisecondsSinceEpoch,
    };
  }

  HistoryItem copyWith({
    int? id,
    String? url,
    String? title,
    String? imageUrl,
    DateTime? viewedAt,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }
}
