import 'package:flutter/material.dart';
import 'package:flutter_wordpress_app/common/constants.dart';

class SearchBox extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback onPressed;

  const SearchBox({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(Constants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: 48,
              width: 48,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBoxGrid extends StatelessWidget {
  const SearchBoxGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: Constants.customCategories.length,
      itemBuilder: (context, index) {
        final category = Constants.customCategories[index];
        return SearchBox(
          text: category['name'] as String,
          icon: category['icon'] as String,
          onPressed: () {
            // Navigate to category
            // TODO: Implement category navigation
          },
        );
      },
    );
  }
}
