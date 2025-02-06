import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/models/post.dart';
import 'package:flutter_wordpress_app/widgets/post_card.dart';
import 'package:http/http.dart' as http;

class LocalArticles extends StatefulWidget {
  const LocalArticles({super.key});

  @override
  State<LocalArticles> createState() => _LocalArticlesState();
}

class _LocalArticlesState extends State<LocalArticles> {
  List<Post> _articles = [];
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _articles = [];
        _hasMore = true;
        _error = null;
      });
    }

    if (!_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          "${Constants.apiEndpoint}/posts?categories=${Constants.page2CategoryId}&page=$_page&per_page=${Constants.defaultPostsPerPage}&_embed=true",
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final newArticles = jsonData.map((json) => Post.fromJson(json)).toList();

        setState(() {
          _articles.addAll(newArticles);
          _isLoading = false;
          _error = null;
          _page++;
          _hasMore = newArticles.length >= Constants.defaultPostsPerPage;
        });
      } else {
        setState(() {
          _error = Constants.generalError;
          _isLoading = false;
        });
      }
    } on SocketException {
      setState(() {
        _error = Constants.noInternetError;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadArticles();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Constants.page2CategoryName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadArticles(refresh: true),
        child: _error != null && _articles.isEmpty
            ? _buildErrorWidget()
            : _buildArticlesList(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadArticles(refresh: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _articles.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _articles.length) {
          return PostCard(post: _articles[index]);
        } else if (_hasMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
