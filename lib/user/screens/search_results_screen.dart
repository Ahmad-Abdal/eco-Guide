import 'package:flutter/material.dart';
import '../providers/search_results_providers.dart';
import 'filters_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  final String? category;

  const SearchResultsScreen({Key? key, required this.initialQuery, this.category}) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => SearchResultsScreenState();
}

class SearchResultsScreenState extends State<SearchResultsScreen> {
  static const Color pureWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF6B6B6B);
  static const Color primaryGreen = Color(0xFF1B7A43);
  static const Color lightGreenBg = Color(0xFFE7F4EC);
  static const Color borderGray = Color(0xFFE0E0E0);

  late final TextEditingController searchController;
  late String? selectedCategory;

  FilterState filters = const FilterState();
  SortOption sort = SortOption.relevance;

  bool isLoading = true;
  List<SearchProduct> results = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.initialQuery);
    selectedCategory = widget.category;
    loadResults();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadResults() async {
    setState(() => isLoading = true);
    final products = await fetchSearchResults(
      query: searchController.text,
      category: selectedCategory,
      filters: filters,
      sort: sort,
    );
    if (!mounted) return;
    setState(() {
      results = products;
      isLoading = false;
    });
  }

  Future<void> openFilters() async {
    final updated = await Navigator.push<FilterState>(
      context,
      MaterialPageRoute(builder: (context) => FiltersScreen(initialFilters: filters)),
    );
    if (updated != null) {
      setState(() => filters = updated);
      loadResults();
    }
  }

  String get sortLabel {
    switch (sort) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.priceLowToHigh:
        return 'Price (Low to High)';
      case SortOption.priceHighToLow:
        return 'Price (High to Low)';
      case SortOption.ecoScoreHighToLow:
        return 'Eco Score (High to Low)';
    }
  }

  List<Widget> buildFilterChips() {
    // Before any filters are applied: quick category/sort shortcuts.
    if (filters.isDefault) {
      return [
        buildQuickChip('All', selectedCategory == null, () {
          setState(() => selectedCategory = null);
          loadResults();
        }),
        if (selectedCategory != null)
          buildQuickChip(selectedCategory!, true, () {}),
        buildQuickChip('Price', false, openFilters),
        buildQuickChip('Eco Score', false, openFilters),
      ];
    }

    // After filters are applied: reflect the actual applied values.
    final chips = <Widget>[];
    if (filters.selectedMaterial != null) {
      chips.add(buildQuickChip(filters.selectedMaterial!, true, openFilters));
    }
    if (filters.priceRange.start != 0 || filters.priceRange.end != 10000) {
      chips.add(buildQuickChip(
        'Price: Rs. ${filters.priceRange.start.round()} - ${filters.priceRange.end.round()}',
        true,
        openFilters,
      ));
    }
    if (filters.ecoScoreRange.start != 0 || filters.ecoScoreRange.end != 100) {
      chips.add(buildQuickChip('Eco Score', true, openFilters));
    }
    if (filters.selectedBrand != 'All') {
      chips.add(buildQuickChip(filters.selectedBrand, true, openFilters));
    }
    return chips;
  }

  Widget buildQuickChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primaryGreen : pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? primaryGreen : borderGray),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : textDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cheapestPrice = results.isEmpty ? null : results.map((p) => p.price).reduce((a, b) => a < b ? a : b);

    return Scaffold(
      backgroundColor: pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: textDark),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderGray),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: searchController,
                        onSubmitted: (_) => loadResults(),
                        style: const TextStyle(color: textDark, fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, color: textGray, size: 20),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close_rounded, color: textGray, size: 18),
                            onPressed: () {
                              searchController.clear();
                              loadResults();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: openFilters,
                    icon: const Icon(Icons.tune_rounded, color: textDark),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: buildFilterChips(),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${results.length} products',
                    style: const TextStyle(color: textGray, fontSize: 13),
                  ),
                  PopupMenuButton<SortOption>(
                    onSelected: (value) {
                      setState(() => sort = value);
                      loadResults();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: SortOption.relevance, child: Text('Relevance')),
                      PopupMenuItem(value: SortOption.priceLowToHigh, child: Text('Price (Low to High)')),
                      PopupMenuItem(value: SortOption.priceHighToLow, child: Text('Price (High to Low)')),
                      PopupMenuItem(value: SortOption.ecoScoreHighToLow, child: Text('Eco Score (High to Low)')),
                    ],
                    child: Row(
                      children: [
                        Text(sortLabel, style: const TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w600)),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: textDark, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryGreen))
                  : results.isEmpty
                      ? Center(
                          child: Text(
                            'No products match this search.',
                            style: TextStyle(color: textGray.withOpacity(0.9), fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final product = results[index];
                            final isBestValue = sort == SortOption.priceLowToHigh &&
                                cheapestPrice != null &&
                                product.price == cheapestPrice;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: pureWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderGray),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            product.imageUrl,
                                            width: 84,
                                            height: 84,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stack) => Container(
                                              width: 84,
                                              height: 84,
                                              color: const Color(0xFFF3F3F3),
                                              child: const Icon(Icons.inventory_2_outlined, color: textGray),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: textDark, fontWeight: FontWeight.w700, fontSize: 15),
                                              ),
                                              if (product.brand != null) ...[
                                                const SizedBox(height: 2),
                                                Text(product.brand!, style: const TextStyle(color: textGray, fontSize: 12)),
                                              ],
                                              const SizedBox(height: 6),
                                              Text(
                                                'Rs. ${product.price.toStringAsFixed(0)}',
                                                style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 15),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(Icons.eco, color: primaryGreen, size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Eco Score ${product.ecoScore}',
                                                    style: const TextStyle(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            // TODO: wishlist toggle.
                                          },
                                          icon: const Icon(Icons.favorite_border_rounded, color: textGray, size: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isBestValue)
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: const BoxDecoration(
                                          color: primaryGreen,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(14),
                                            bottomRight: Radius.circular(14),
                                          ),
                                        ),
                                        child: const Text(
                                          'Best Value',
                                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}