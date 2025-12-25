import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

/// Model for parsed article data
class ParsedArticle {
  ParsedArticle({required this.title, required this.content, this.imageUrl});
  final String title;
  final String content;
  final String? imageUrl;
}

final Provider<ArticleParserService> articleParserServiceProvider = Provider(
  (ref) => ArticleParserService(),
);

class ArticleParserService {
  /// Elements to completely remove from the DOM
  static const _removeSelectors = [
    // Scripts, styles, and metadata
    'script', 'style', 'noscript', 'link', 'meta',

    // Navigation and layout
    'nav', 'header', 'footer', 'aside', 'menu', 'menuitem',

    // Ads and tracking
    'iframe', '.ad', '.ads', '.advertisement', '.advert',
    '[class*="ad-"]', '[class*="ads-"]', '[class*="advert"]',
    '[id*="ad-"]', '[id*="ads-"]', '[id*="google_ads"]',
    '[class*="sponsored"]', '[class*="promo"]',

    // Social media widgets
    '.social', '.share', '.sharing', '[class*="social"]', '[class*="share"]',
    '.follow', '[class*="follow"]', '.subscribe', '[class*="subscribe"]',

    // Comments and related content
    '.comments', '.comment', '#comments',
    '.related', '.related-articles', '.related-posts',
    '.recommended', '.more-stories',
    '[class*="related"]', '[class*="recommend"]',

    // Navigation menus and breadcrumbs
    '.breadcrumb', '.breadcrumbs', '.navigation',
    '.nav-menu', '.menu-item', '.site-nav', '.main-nav', '.top-nav',

    // Popups and modals
    '.popup', '.modal', '.overlay',
    '[class*="popup"]', '[class*="modal"]', '[class*="overlay"]',

    // Newsletter and signup forms
    '.newsletter', '.signup', '.subscribe-form', 'form',

    // Sidebars and widgets
    '.sidebar', '.widget', '[class*="sidebar"]', '[class*="widget"]',

    // Tags and categories
    '.tags', '.categories', '.post-tags', '.tag-list',
    '[class*="category"]', '[class*="tags"]',

    // Junk elements
    '.breaking-news', '.trending', '.popular', '.latest',
    '[class*="banner"]', '[class*="promo"]',

    // Hidden elements
    '[style*="display:none"]', '[style*="display: none"]',
    '[style*="visibility:hidden"]', '[hidden]', '.hidden', '.visually-hidden',

    // Utility elements
    'button', 'input', 'select', 'textarea', 'svg', 'canvas',

    // Affiliate and disclaimers
    '.affiliate',
    '[class*="affiliate"]',
    '.disclaimer',
    '[class*="disclaimer"]',
    '.disclosure', '[class*="disclosure"]',

    // Author/meta info (we extract title separately)
    '.author-info', '.author-bio', '.byline', '[class*="byline"]',
    '.meta', '.post-meta', '.article-meta', '[class*="post-meta"]',
    '.date', '.published', '[class*="publish"]',

    // Call-to-actions
    '.cta', '[class*="cta"]', '.call-to-action',
    '.read-more', '.more-link', '[class*="read-more"]',

    // Site-specific: New Indian Express
    '.story-tags', '.story-category', '.article-tags',
    '.location-tag', '[class*="location"]',

    // Site-specific: Android Authority
    '.aa-also-read', '.also-read', '[class*="also-read"]',
    '.newsletter-signup', '.push-notification',

    // Comment sections and policies
    '.comment-policy', '[class*="comment-policy"]',
    '.community', '[class*="community"]',

    // Images we don't want (we show hero separately)
    'figure.featured-image',
  ];

  /// Content container selectors (priority order)
  static const _contentSelectors = [
    '[itemprop="articleBody"]',
    'article[class*="content"]',
    'article[class*="article"]',
    'article[class*="post"]',
    'article[class*="story"]',
    '[class*="article-content"]',
    '[class*="article-body"]',
    '[class*="story-content"]',
    '[class*="story-body"]',
    '[class*="post-content"]',
    '[class*="post-body"]',
    '[class*="entry-content"]',
    '[class*="content-body"]',
    'article',
    '.article-text',
    '.story-text',
    '.post-text',
    'main[class*="content"]',
    'main',
    '[role="main"]',
    '#content',
    '.content',
  ];

  /// Patterns in text to filter out
  static final _junkTextPatterns = [
    RegExp(r'affiliate\s+links?', caseSensitive: false),
    RegExp(r'earn\s+(us\s+)?a?\s*commission', caseSensitive: false),
    RegExp(r'learn\s+more\.?$', caseSensitive: false),
    RegExp(r'follow\s+us', caseSensitive: false),
    RegExp(r'subscribe\s+(to|for)', caseSensitive: false),
    RegExp(r'sign\s+up\s+for', caseSensitive: false),
    RegExp(r'read\s+our\s+comment\s+policy', caseSensitive: false),
    RegExp(r'thank\s+you\s+for\s+being\s+part\s+of', caseSensitive: false),
    RegExp(r"don'?t\s+want\s+to\s+miss", caseSensitive: false),
    RegExp(r'set\s+us\s+as\s+a', caseSensitive: false),
    RegExp(r'preferred\s+source', caseSensitive: false),
    RegExp(r'no\s+stories\s+found', caseSensitive: false),
    RegExp(r'related\s+stories?', caseSensitive: false),
    RegExp(r'^by\s*$', caseSensitive: false),
    RegExp(r'^\s*•\s*$'),
  ];

  String _extractedTitle = '';

  Future<ParsedArticle> parseArticle(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
              'AppleWebKit/537.36 (KHTML, like Gecko) '
              'Chrome/120.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load page: ${response.statusCode}');
      }

      final document = parser.parse(response.body);

      // Extract metadata first (before removing elements)
      _extractedTitle = _extractTitle(document);
      final imageUrl = _extractImage(document);

      // Remove unwanted elements
      _removeUnwantedElements(document);

      // Find main content
      final contentElement = _findMainContent(document);

      // Clean the content element
      _cleanContentElement(contentElement, _extractedTitle);

      // Extract and format the final content
      final content = _formatContent(contentElement);

      return ParsedArticle(
        title: _extractedTitle,
        content: content,
        imageUrl: imageUrl,
      );
    } catch (e) {
      throw Exception('Error parsing article: $e');
    }
  }

  String _extractTitle(Document document) {
    // Try Open Graph title first
    final ogTitle = document.head
        ?.querySelector('meta[property="og:title"]')
        ?.attributes['content'];
    if (ogTitle != null && ogTitle.trim().isNotEmpty) {
      return ogTitle.trim();
    }

    // Try Twitter title
    final twitterTitle = document.head
        ?.querySelector('meta[name="twitter:title"]')
        ?.attributes['content'];
    if (twitterTitle != null && twitterTitle.trim().isNotEmpty) {
      return twitterTitle.trim();
    }

    // Try article h1
    final h1 =
        document.querySelector('article h1')?.text ??
        document.querySelector('h1')?.text;
    if (h1 != null && h1.trim().isNotEmpty) {
      return h1.trim();
    }

    // Fallback to page title
    final pageTitle = document.head?.querySelector('title')?.text;
    if (pageTitle != null) {
      return pageTitle.split('|').first.split('-').first.trim();
    }

    return 'Untitled Article';
  }

  String? _extractImage(Document document) {
    final ogImage = document.head
        ?.querySelector('meta[property="og:image"]')
        ?.attributes['content'];
    if (ogImage != null && ogImage.isNotEmpty) {
      return ogImage;
    }

    final twitterImage = document.head
        ?.querySelector('meta[name="twitter:image"]')
        ?.attributes['content'];
    if (twitterImage != null && twitterImage.isNotEmpty) {
      return twitterImage;
    }

    return null;
  }

  void _removeUnwantedElements(Document document) {
    for (final selector in _removeSelectors) {
      try {
        document.querySelectorAll(selector).forEach((e) => e.remove());
      } on Exception catch (_) {}
    }
  }

  Element? _findMainContent(Document document) {
    for (final selector in _contentSelectors) {
      try {
        final element = document.querySelector(selector);
        if (element != null && _hasSignificantContent(element)) {
          return element;
        }
      } on Exception catch (_) {}
    }
    return _findContentByDensity(document);
  }

  bool _hasSignificantContent(Element element) {
    final text = element.text.trim();
    final paragraphs = element.querySelectorAll('p');
    return text.length > 100 && paragraphs.isNotEmpty;
  }

  Element? _findContentByDensity(Document document) {
    Element? bestElement;
    var bestScore = 0;

    final candidates = document.querySelectorAll('div, section, article');

    for (final candidate in candidates) {
      final paragraphs = candidate.querySelectorAll('p');
      var score = 0;

      for (final p in paragraphs) {
        final text = p.text.trim();
        if (text.length > 50) {
          score += text.length;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestElement = candidate;
      }
    }

    return bestElement ?? document.body;
  }

  void _cleanContentElement(Element? element, String title) {
    if (element == null) return;

    // Remove remaining unwanted elements
    for (final selector in _removeSelectors) {
      try {
        element.querySelectorAll(selector).forEach((e) => e.remove());
      } on Exception catch (_) {}
    }

    // Remove duplicate titles (h1, h2 that match the extracted title)
    _removeDuplicateTitles(element, title);

    // Remove elements with junk text patterns
    _removeJunkTextElements(element);

    // Remove empty elements
    _removeEmptyElements(element);

    // Remove navigation-style lists
    _removeNavigationLists(element);

    // Remove standalone category/location links
    _removeStandaloneLinks(element);
  }

  void _removeDuplicateTitles(Element element, String title) {
    final normalizedTitle = _normalizeText(title);

    // Remove h1, h2 that match the title
    element.querySelectorAll('h1, h2').forEach((heading) {
      final headingText = _normalizeText(heading.text);
      if (_textsAreSimilar(headingText, normalizedTitle)) {
        heading.remove();
      }
    });

    // Also check for title in span/div that's styled as heading
    element.querySelectorAll('span, div').forEach((el) {
      final text = _normalizeText(el.text);
      if (_textsAreSimilar(text, normalizedTitle) && el.text.length < 200) {
        // Only if it's relatively short (likely a title, not content)
        el.remove();
      }
    });
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _textsAreSimilar(String a, String b) {
    if (a == b) return true;
    if (a.isEmpty || b.isEmpty) return false;

    // Check if one contains the other
    if (a.contains(b) || b.contains(a)) return true;

    // Check similarity ratio
    final shorter = a.length < b.length ? a : b;
    final longer = a.length < b.length ? b : a;

    var matches = 0;
    final shorterWords = shorter.split(' ');
    for (final word in shorterWords) {
      if (word.length > 2 && longer.contains(word)) matches++;
    }

    return matches > shorterWords.length * 0.7;
  }

  void _removeJunkTextElements(Element element) {
    // Check paragraphs and divs for junk patterns
    final elementsToCheck = element.querySelectorAll('p, div, span, li');

    for (final el in elementsToCheck.toList()) {
      final text = el.text.trim();

      // Skip if has significant content
      if (text.length > 200) continue;

      for (final pattern in _junkTextPatterns) {
        if (pattern.hasMatch(text)) {
          el.remove();
          break;
        }
      }
    }
  }

  void _removeEmptyElements(Element element) {
    final children = element.children.toList();
    for (final child in children) {
      _removeEmptyElements(child);

      final text = child.text.trim();
      final hasImages = child.querySelectorAll('img').isNotEmpty;

      if (text.isEmpty && !hasImages) {
        child.remove();
      }
    }
  }

  void _removeNavigationLists(Element element) {
    element.querySelectorAll('ul, ol').forEach((list) {
      final links = list.querySelectorAll('a');
      final text = list.text.trim();

      // If a list is mostly links and has short items, it's likely navigation
      if (links.length > 2 && text.length < links.length * 60) {
        list.remove();
      }
    });
  }

  void _removeStandaloneLinks(Element element) {
    element.querySelectorAll('a').forEach((link) {
      final parent = link.parent;
      if (parent == null) return;

      final parentText = parent.text.trim();
      final linkText = link.text.trim();

      // Single short link in a container (not in paragraph)
      if (parentText == linkText && linkText.length < 40) {
        if (parent.localName != 'p' && parent.localName != 'li') {
          parent.remove();
        }
      }
    });
  }

  String _formatContent(Element? element) {
    if (element == null) {
      return '<p>No content found.</p>';
    }

    // Strip inline styles from all elements first
    _stripInlineStyles(element);

    var html = element.innerHtml;

    // Clean up excessive whitespace
    html = html
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'>\s+<'), '><')
        .trim();

    // Remove any remaining inline style attributes via regex
    html = html.replaceAll(
      RegExp(r'\s*style="[^"]*"', caseSensitive: false),
      '',
    );
    html = html.replaceAll(
      RegExp(r"\s*style='[^']*'", caseSensitive: false),
      '',
    );

    // Remove class attributes to prevent site-specific styling
    html = html.replaceAll(
      RegExp(r'\s*class="[^"]*"', caseSensitive: false),
      '',
    );
    html = html.replaceAll(
      RegExp(r"\s*class='[^']*'", caseSensitive: false),
      '',
    );

    if (html.length < 100) {
      return '<p>Could not extract article content. '
          'The page structure may not be supported.</p>';
    }

    return html;
  }

  void _stripInlineStyles(Element element) {
    // Remove style and class attributes from all elements
    element.attributes.remove('style');
    element.attributes.remove('class');
    element.attributes.remove('bgcolor');
    element.attributes.remove('color');

    element.children.forEach(_stripInlineStyles);
  }
}
