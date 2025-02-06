import 'package:intl/intl.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/models/Article.dart';

class Post {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final String featuredImage;
  final String? video;
  final String author;
  final String avatar;
  final String category;
  final DateTime date;
  final String link;
  final int? categoryId;

  const Post({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.featuredImage,
    this.video,
    required this.author,
    required this.avatar,
    required this.category,
    required this.date,
    required this.link,
    this.categoryId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final embedded = json['_embedded'] as Map<String, dynamic>? ?? {};
    
    // Author data
    final authorList = embedded['author'] as List<dynamic>?;
    final authorData = authorList?.isNotEmpty == true 
        ? authorList![0] as Map<String, dynamic> 
        : <String, dynamic>{};
    final authorName = authorData['name'] as String? ?? 'Unknown';
    final avatarUrls = authorData['avatar_urls'] as Map<String, dynamic>?;
    final authorAvatar = avatarUrls?['96'] as String? ?? Constants.defaultAvatarImage;

    // Category data
    final terms = embedded['wp:term'] as List<dynamic>?;
    final categories = terms?.isNotEmpty == true ? terms![0] as List<dynamic> : [];
    final categoryData = categories.isNotEmpty 
        ? categories[0] as Map<String, dynamic> 
        : <String, dynamic>{};
    final categoryName = categoryData['name'] as String? ?? '';
    final categoryId = categoryData['id'] as int?;

    // Featured media
    final mediaList = embedded['wp:featuredmedia'] as List<dynamic>?;
    final mediaData = mediaList?.isNotEmpty == true 
        ? mediaList![0] as Map<String, dynamic> 
        : null;
    final imageUrl = mediaData?['source_url'] as String? ?? Constants.defaultFeaturedImage;

    // Content processing
    final title = (json['title']?['rendered'] as String? ?? '').trim();
    final content = json['content']?['rendered'] as String? ?? '';
    final excerpt = (json['excerpt']?['rendered'] as String? ?? '').trim();
    final link = json['link'] as String? ?? '';
    final postId = json['id'] as int? ?? 0;

    return Post(
      id: postId,
      title: title,
      excerpt: excerpt,
      content: content,
      featuredImage: imageUrl,
      video: json['custom']?['td_video'] as String?,
      author: authorName,
      avatar: authorAvatar,
      category: categoryName,
      date: DateTime.parse(json['date'] as String),
      link: link,
      categoryId: categoryId,
    );
  }

  Article toArticle() {
    return Article(
      id: id,
      title: title,
      content: content,
      excerpt: excerpt,
      image: featuredImage,
      video: video,
      author: author,
      avatar: avatar,
      category: category,
      date: DateFormat(Constants.defaultDateFormat, 'en_US').format(date),
      link: link,
      catId: categoryId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Post{id: $id, title: $title}';
}
