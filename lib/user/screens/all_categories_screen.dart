import 'package:flutter/material.dart';
import '../providers/browse_providers.dart';
import 'search_results_screen.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({Key? key}) : super(key: key);

  static const Color pureWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF6B6B6B);
  static const Color sectionFill = Color(0xFFF7F8F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureWhite,
      appBar: AppBar(
        backgroundColor: pureWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        title: const Text(
          'All Categories',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: browseCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 14,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final category = browseCategories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultsScreen(
                      initialQuery: '',
                      category: category.name,
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: sectionFill,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          category.assetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => const Icon(
                            Icons.image_outlined,
                            color: textGray,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: textDark, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}