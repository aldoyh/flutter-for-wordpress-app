import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/models/comment.dart';
import 'package:flutter_wordpress_app/services/auth_service.dart';

class CommentProvider extends ChangeNotifier {
  final AuthService _authService;
  
  bool _isLoading = false;
  String? _error;
  List<Comment> _comments = [];
  int _totalComments = 0;
  int _currentPage = 1;
  int _totalPages = 1;

  CommentProvider(this._authService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Comment> get comments => _comments;
  bool get hasMore => _currentPage < _totalPages;

  Future<void> fetchComments(int postId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _comments = [];
    }

    if (_isLoading) return;

    _setLoading(true);
    _error = null;

    try {
      final response = await http.get(
        Uri.parse(
          '${Constants.commentsEndpoint}?post=$postId&page=$_currentPage&per_page=10&_embed=true',
        ),
        headers: _authService.isLoggedIn
            ? _authService.authHeaders
            : null,
      );

      if (response.statusCode == 200) {
        final commentResponse = CommentResponse.fromResponse(
          json.decode(response.body) as List,
          response.headers,
        );

        if (refresh) {
          _comments = commentResponse.comments;
        } else {
          _comments.addAll(commentResponse.comments);
        }

        _totalComments = commentResponse.total;
        _totalPages = commentResponse.totalPages;
        _currentPage++;
      } else {
        throw Constants.loadingError;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Comment?> addComment({
    required int postId,
    required String content,
  }) async {
    if (!_authService.isLoggedIn) {
      throw 'Must be logged in to comment';
    }

    try {
      final response = await http.post(
        Uri.parse(Constants.commentsEndpoint),
        headers: _authService.authHeaders,
        body: json.encode({
          'post': postId,
          'content': content,
          'author': _authService.currentUser?.id,
        }),
      );

      if (response.statusCode == 201) {
        final newComment = Comment.fromJson(json.decode(response.body));
        _comments.insert(0, newComment);
        _totalComments++;
        notifyListeners();
        return newComment;
      } else {
        final data = json.decode(response.body);
        throw data['message'] ?? Constants.generalError;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteComment(int commentId) async {
    if (!_authService.isLoggedIn) {
      throw 'Must be logged in to delete comments';
    }

    try {
      final response = await http.delete(
        Uri.parse('${Constants.commentsEndpoint}/$commentId'),
        headers: _authService.authHeaders,
      );

      if (response.statusCode == 200) {
        _comments.removeWhere((comment) => comment.id == commentId);
        _totalComments--;
        notifyListeners();
      } else {
        throw Constants.generalError;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearComments() {
    _comments = [];
    _currentPage = 1;
    _totalPages = 1;
    _totalComments = 0;
    _error = null;
    notifyListeners();
  }
}