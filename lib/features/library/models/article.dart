class Article {

  Article({
    required this.url, required this.title, required this.savedAt, this.id,
    this.author,
    this.content,
    this.imageUrl,
    this.description,
    this.publishedAt,
  });

  // Extract Article from Map
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as int?,
      url: map['url'] as String,
      title: map['title'] as String,
      author: map['author'] as String?,
      content: map['content'] as String?,
      imageUrl: map['imageUrl'] as String?,
      description: map['description'] as String?,
      savedAt: DateTime.fromMillisecondsSinceEpoch(map['savedAt'] as int),
      publishedAt: map['publishedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['publishedAt'] as int)
          : null,
    );
  }
  final int? id;
  final String url;
  final String title;
  final String? author;
  final String? content; // HTML content
  final String? imageUrl;
  final String? description;
  final DateTime savedAt;
  final DateTime? publishedAt;

  // Convert Article to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'author': author,
      'content': content,
      'imageUrl': imageUrl,
      'description': description,
      'savedAt': savedAt.millisecondsSinceEpoch,
      'publishedAt': publishedAt?.millisecondsSinceEpoch,
    };
  }
}
