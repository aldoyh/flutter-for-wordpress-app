import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:intl/intl.dart';

class Comment {
  final int id;
  final int postId;
  final String author;
  final String avatar;
  final String content;
  final DateTime date;
  final int? authorId;
  final int? parentId;

  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.avatar,
    required this.content,
    required this.date,
    this.authorId,
    this.parentId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final authorData = json['author_avatar_urls'] ?? {};
    final avatar = authorData['96'] ?? Constants.defaultAvatarImage;
    
    String content = '';
    if (json['content'] != null && json['content']['rendered'] != null) {
      content = json['content']['rendered']
          .toString()
          .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
          .replaceAll('&nbsp;', ' ')
          .trim();
    }

    return Comment(
      id: json['id'] as int,
      postId: json['post'] as int,
      author: json['author_name'] as String? ?? 'Anonymous',
      avatar: avatar,
      content: content,
      date: DateTime.parse(json['date'] as String),
      authorId: json['author'] as int?,
      parentId: json['parent'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'post': postId,
    'author_name': author,
    'author_avatar_urls': {
      '96': avatar,
    },
    'content': {
      'rendered': content,
    },
    'date': date.toIso8601String(),
    'author': authorId,
    'parent': parentId,
  };

  String get formattedDate => DateFormat(Constants.defaultDateFormat).format(date);

  Comment copyWith({
    int? id,
    int? postId,
    String? author,
    String? avatar,
    String? content,
    DateTime? date,
    int? authorId,
    int? parentId,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      avatar: avatar ?? this.avatar,
      content: content ?? this.content,
      date: date ?? this.date,
      authorId: authorId ?? this.authorId,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Comment{id: $id, author: $author, content: $content}';
}

class CommentResponse {
  final List<Comment> comments;
  final int total;
  final int totalPages;

  const CommentResponse({
    required this.comments,
    required this.total,
    required this.totalPages,
  });

  factory CommentResponse.fromResponse(
    List<dynamic> data,
    Map<String, String> headers,
  ) {
    final comments = data.map((json) => Comment.fromJson(json)).toList();
    final total = int.tryParse(headers['x-wp-total'] ?? '0') ?? 0;
    final totalPages = int.tryParse(headers['x-wp-totalpages'] ?? '0') ?? 0;

    return CommentResponse(
      comments: comments,
      total: total,
      totalPages: totalPages,
    );
  }
}
