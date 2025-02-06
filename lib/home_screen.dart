import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_wordpress_app/models/category.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_wordpress_app/models/post.dart';
import 'package:flutter_wordpress_app/providers/posts_provider.dart';
import 'package:flutter_wordpress_app/widgets/error_box.dart';
import 'package:flutter_wordpress_app/widgets/post_card.dart';
import 'package:flutter_wordpress_app/common/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController();
  final PagingController<int, Post> _pagingController =
      PagingController(firstPageKey: 1);
  String? _searchQuery;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final provider = context.read<PostsProvider>();
      final newItems = await provider.fetchPosts(
        page: pageKey,
        perPage: 10,
        categoryId: _selectedCategory?.id,
        searchQuery: _searchQuery,
      );

      final isLastPage = newItems.length < 10;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _loadInitialData() async {
    try {
      await context.read<PostsProvider>().fetchCategories();
      if (mounted) {
        final categories = context.read<PostsProvider>().categories;
        if (categories.isNotEmpty) {
          setState(() {
            _selectedCategory = categories.first;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $error')),
        );
      }
    }
  }

  void _onCategorySelected(Category category) {
    setState(() {
      _selectedCategory = category;
      _pagingController.refresh();
    });
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.isNotEmpty ? query : null;
      _pagingController.refresh();
    });
  }

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: false,
      expandedHeight: 160.0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          Constants.appName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            shadows: [
              const Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:
                  '${Constants.wordpressUrl}/wp-content/uploads/2023/08/header-bg.jpg',
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const ColoredBox(
                color: Colors.grey,
                child: Icon(Icons.error),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(128),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search articles...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = context.watch<PostsProvider>().categories;
    if (categories.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
                  label: Text(category.name),
                  selected: _selectedCategory?.id == category.id,
                  onSelected: (_) => _onCategorySelected(category),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPostGrid() {
    return PagedSliverGrid<int, Post>(
      pagingController: _pagingController,
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        repeatPattern: QuiltedGridRepeatPattern.inverted,
        pattern: const [
          QuiltedGridTile(2, 2),
          QuiltedGridTile(1, 1),
          QuiltedGridTile(1, 1),
          QuiltedGridTile(1, 2),
        ],
      ),
      builderDelegate: PagedChildBuilderDelegate<Post>(
        itemBuilder: (context, post, index) => PostCard(post: post),
        firstPageProgressIndicatorBuilder: (context) => const _ShimmerGrid(),
        newPageProgressIndicatorBuilder: (context) => const _LoadingIndicator(),
        firstPageErrorIndicatorBuilder: (context) => ErrorBox(
          error: _pagingController.error,
          onRetry: () => _pagingController.refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) => ErrorBox(
          error: _pagingController.error,
          onRetry: () => _pagingController.retryLastFailedRequest(),
        ),
        noItemsFoundIndicatorBuilder: (context) => const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No articles found'),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: () async {
          try {
            _pagingController.refresh();
            _refreshController.refreshCompleted();
          } catch (e) {
            _refreshController.refreshFailed();
          }
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildCategoryChips(),
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: _buildPostGrid(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: theme.colorScheme.surfaceContainerHighest,
            highlightColor: theme.colorScheme.surface,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          childCount: 6,
        ),
      ),
    );
  }
}
