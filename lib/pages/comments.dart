import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/models/comment.dart';
import 'package:flutter_wordpress_app/providers/comment_provider.dart';
import 'package:flutter_wordpress_app/services/auth_service.dart';
import 'package:flutter_wordpress_app/widgets/commentBox.dart';
import 'package:flutter_wordpress_app/pages/add_comment.dart';

class Comments extends StatefulWidget {
  final int postId;

  const Comments(this.postId, {super.key});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComments(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments({bool refresh = false}) async {
    await context.read<CommentProvider>().fetchComments(
      widget.postId,
      refresh: refresh,
    );
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final provider = context.read<CommentProvider>();
    
    if (currentScroll >= maxScroll - 200 && provider.hasMore && !provider.isLoading) {
      setState(() => _isLoadingMore = true);
      _loadComments().then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn = context.watch<AuthService>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comments',
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Consumer<CommentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.comments.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null && provider.comments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _loadComments(refresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _loadComments(refresh: true),
            child: provider.comments.isEmpty
                ? CommentsList(
                    comments: const [],
                    onRefresh: () => _loadComments(refresh: true),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.comments.length + 1,
                    itemBuilder: (context, index) {
                      if (index == provider.comments.length) {
                        if (provider.hasMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      final comment = provider.comments[index];
                      return CommentBox(
                        author: comment.author,
                        avatar: comment.avatar,
                        content: comment.content,
                        date: comment.date,
                      );
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoggedIn
            ? () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddComment(widget.postId),
                    fullscreenDialog: true,
                  ),
                );

                if (result == true && mounted) {
                  _loadComments(refresh: true);
                }
              }
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please login to comment'),
                  ),
                );
              },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
