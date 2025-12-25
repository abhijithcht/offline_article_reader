import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

// Simple model for parsed data
class ParsedArticle {

  ParsedArticle({required this.title, required this.content, this.imageUrl});
  final String title;
  final String content; // HTML content or plain text
  final String? imageUrl;
}

final Provider<ArticleParserService> articleParserServiceProvider = Provider((ref) => ArticleParserService());

class ArticleParserService {
  Future<ParsedArticle> parseArticle(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load page: ${response.statusCode}');
      }

      final document = parser.parse(response.body);

      // Simple extraction strategy (Extract title, image, and body)
      // This is a naive implementation; specialized packages or readablity.js port recommended for production

      // Title
      final title =
          document.head?.querySelector('title')?.text ??
          document.body?.querySelector('h1')?.text ??
          'No Title';

      // Image (Open Graph or first image)
      final imageUrl = document.head
          ?.querySelector('meta[property="og:image"]')
          ?.attributes['content'];

      // Content cleaning
      // Remove scripts, styles, navs, footers
      document
          .querySelectorAll(
            'script, style, nav, footer, header, aside, .ad, .advertisement',
          )
          .forEach((element) {
            element.remove();
          });

      // Extract body text (naive)
      // Ideally we want to find the main article container
      // For now, let's look for <article> tag or use body
      final contentElement =
          document.querySelector('article') ?? document.body;

      final content = contentElement?.innerHtml ?? 'No Content Found';

      return ParsedArticle(
        title: title.trim(),
        content: content,
        imageUrl: imageUrl,
      );
    } catch (e) {
      throw Exception('Error parsing article: $e');
    }
  }
}
