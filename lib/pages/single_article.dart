import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/models/Article.dart';
import 'package:flutter_wordpress_app/pages/comments.dart';
import 'package:share_plus/share_plus.dart';

class SingleArticle extends StatefulWidget {
  final Article article;
  final String heroId;

  const SingleArticle(this.article, this.heroId, {super.key});

  @override
  State<SingleArticle> createState() => _SingleArticleState();
}

class _SingleArticleState extends State<SingleArticle> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final article = widget.article;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: widget.heroId,
                      child: article.image.isNotEmpty
                          ? Image.network(
                              article.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  Constants.defaultFeaturedImage,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              Constants.defaultFeaturedImage,
                              fit: BoxFit.cover,
                            ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.category.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.category,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    Text(
                      article.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(article.avatar),
                          radius: 20,
                          onBackgroundImageError: (e, s) =>
                              const Icon(Icons.person),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'By ${article.author}',
                                style: theme.textTheme.titleSmall,
                              ),
                              Text(
                                article.date,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onBackground
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Html(
                      data: article.content,
                      style: {
                        "body": Style(
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          fontSize: FontSize(16.0),
                          lineHeight: LineHeight(1.6),
                          fontFamily: Constants.fontFamily,
                          color: theme.colorScheme.onBackground,
                        ),
                        "p": Style(
                          margin: const EdgeInsets.only(bottom: 16),
                          fontSize: FontSize(16.0),
                          lineHeight: LineHeight(1.6),
                          fontFamily: Constants.fontFamily,
                        ),
                        "h1,h2,h3,h4,h5,h6": Style(
                          margin: const EdgeInsets.only(bottom: 16, top: 24),
                          fontFamily: Constants.fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                        "img": Style(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        "a": Style(
                          color: theme.colorScheme.primary,
                          textDecoration: TextDecoration.none,
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: theme.colorScheme.surface,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.comment,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Comments(article.id),
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: theme.colorScheme.secondary,
                ),
                onPressed: () => Share.share(
                  'Check out this article: ${article.title}\n${article.link}',
                  subject: article.title,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
