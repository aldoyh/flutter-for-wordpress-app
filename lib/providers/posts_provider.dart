import 'dart:convert';
import 'package:flutter/foundation.dart' as flutter;
import 'package:http/http.dart' as http;
import 'package:flutter_wordpress_app/models/post.dart';
import 'package:flutter_wordpress_app/models/category.dart';
import 'package:flutter_wordpress_app/common/constants.dart';

class PostsProvider extends flutter.ChangeNotifier {
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  Future<List<Post>> fetchPosts({
    required int page,
    required int perPage,
    int? categoryId,
    String? searchQuery,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        '_embed': 'true',
      };

      if (categoryId != null) {
        queryParams['categories'] = categoryId.toString();
      }

      if (searchQuery != null) {
        queryParams['search'] = searchQuery;
      }

      final url = Uri.parse('${Constants.wordpressUrl}/wp-json/wp/v2/posts')
          .replace(queryParameters: queryParams);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final url = Uri.parse('${Constants.wordpressUrl}/wp-json/wp/v2/categories');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _categories = jsonData
            .map((json) => Category(
                  id: json['id'] as int,
                  name: json['name'] as String,
                  count: json['count'] as int,
                ))
            .toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
