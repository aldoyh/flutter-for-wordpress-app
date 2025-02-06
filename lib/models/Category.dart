import 'package:flutter/foundation.dart';

@immutable
class Category {
  final int id;
  final String name;
  final int count;
  final String? description;
  final String? image;
  final int? parent;

  const Category({
    required this.id,
    required this.name,
    required this.count,
    this.description,
    this.image,
    this.parent,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      count: json['count'] as int,
      description: json['description'] as String?,
      image: json['_embedded']?['wp:featuredmedia']?[0]?['source_url'] as String?,
      parent: json['parent'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  Category copyWith({
    int? id,
    String? name,
    int? count,
    String? description,
    String? image,
    int? parent,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      description: description ?? this.description,
      image: image ?? this.image,
      parent: parent ?? this.parent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'count': count,
      'description': description,
      'image': image,
      'parent': parent,
    };
  }
}
