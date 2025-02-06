import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:intl/intl.dart';

class Article {
  final int id;
  final String title;
  final String content;
  final String excerpt;
  final String image;
  final String? video;
  final String author;
  final String avatar;
  final String category;
  final String date;
  final String link;
  final int? catId;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.image,
    this.video,
    required this.author,
    required this.avatar,
    required this.category,
    required this.date,
    required this.link,
    this.catId,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    try {
      final embedded = json['_embedded'] as Map<String, dynamic>? ?? {};
      final authorList = embedded['author'] as List<dynamic>?;
      final authorData = authorList?.isNotEmpty == true 
          ? authorList![0] as Map<String, dynamic> 
          : <String, dynamic>{};
      final avatarUrls = authorData['avatar_urls'] as Map<String, dynamic>?;

      final terms = embedded['wp:term'] as List<dynamic>?;
      final categories = terms?.isNotEmpty == true ? terms![0] as List<dynamic> : [];
      final categoryData = categories.isNotEmpty 
          ? categories[0] as Map<String, dynamic> 
          : <String, dynamic>{};

      final mediaList = embedded['wp:featuredmedia'] as List<dynamic>?;
      final mediaData = mediaList?.isNotEmpty == true 
          ? mediaList![0] as Map<String, dynamic> 
          : null;
      
      final postDate = DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now();
      final formattedDate = DateFormat(Constants.defaultDateFormat, 'en_US').format(postDate);

      return Article(
        id: json['id'] as int? ?? 0,
        title: (json['title']?['rendered'] as String? ?? '').trim(),
        content: json['content']?['rendered'] as String? ?? '',
        excerpt: (json['excerpt']?['rendered'] as String? ?? '').trim(),
        image: mediaData?['source_url'] as String? ?? Constants.defaultFeaturedImage,
        video: _extractVideoUrl(json['content']?['rendered'] as String? ?? ''),
        author: authorData['name'] as String? ?? 'Unknown',
        avatar: avatarUrls?['96'] as String? ?? Constants.defaultAvatarImage,
        category: categoryData['name'] as String? ?? '',
        date: formattedDate,
        link: json['link'] as String? ?? '',
        catId: categoryData['id'] as int?,
      );
    } catch (e) {
      return Article(
        id: 0,
        title: 'Error loading article',
        content: e.toString(),
        excerpt: 'Error loading article content',
        image: Constants.defaultFeaturedImage,
        author: 'Unknown',
        avatar: Constants.defaultAvatarImage,
        category: 'Error',
        date: DateFormat(Constants.defaultDateFormat, 'en_US').format(DateTime.now()),
        link: '',
      );
    }
  }

  static String? _extractVideoUrl(String content) {
    if (!content.contains('<video')) {
      return null;
    }
    try {
      final videoPattern = RegExp(r'<video[^>]*src="([^"]*)"');
      final match = videoPattern.firstMatch(content);
      return match?.group(1);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'excerpt': excerpt,
    'image': image,
    'video': video,
    'author': author,
    'avatar': avatar,
    'category': category,
    'date': date,
    'link': link,
    'catId': catId,
  };

  factory Article.fromDatabaseJson(Map<String, dynamic> data) => Article(
    id: data['id'] as int? ?? 0,
    title: data['title'] as String? ?? '',
    content: data['content'] as String? ?? '',
    excerpt: data['excerpt'] as String? ?? '',
    image: data['image'] as String? ?? Constants.defaultFeaturedImage,
    video: data['video'] as String?,
    author: data['author'] as String? ?? 'Unknown',
    avatar: data['avatar'] as String? ?? Constants.defaultAvatarImage,
    category: data['category'] as String? ?? '',
    date: data['date'] as String? ?? DateFormat(Constants.defaultDateFormat, 'en_US').format(DateTime.now()),
    link: data['link'] as String? ?? '',
    catId: data['catId'] as int?,
  );

  Map<String, dynamic> toDatabaseJson() => toJson();

  @override
  String toString() => 'Article(id: $id, title: $title)';
}
