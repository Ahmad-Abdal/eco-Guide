import 'package:flutter/material.dart';
import '../providers/search_results_providers.dart';

class FiltersScreen extends StatefulWidget {
  final FilterState initialFilters;

  const FiltersScreen({Key? key, required this.initialFilters}) : super(key: key);

  @override
  State<FiltersScreen> createState() => FiltersScreenState();
}

class FiltersScreenState extends State<FiltersScreen> {
  static const Color pureWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF6B6B6B);
  static const Color primaryGreen = Color(0xFF1B7A43);
  static const Color lightGreenBg = Color(0xFFE7F4EC);
  static const Color borderGray = Color(0xFFE0E0E0);
  static const Color sectionFill = Color(0xFFF7F8F6);

  late FilterState filters;

  @override
  void initState() {
    super.initState();
    filters = widget.initialFilters;
  }

  void resetFilters() {
    setState(() => filters = const FilterState());
  }

  Widget buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sectionFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    return Scaffold(
      backgroundColor: pureWhite,
      appBar: AppBar(
        backgroundColor: pureWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        title: const Text('Filters', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: resetFilters,
            child: const Text('Reset', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.eco_outlined, color: primaryGreen, size: 20),
                                  SizedBox(width: 8),
                                  Text('Eco Score', style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 15)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: lightGreenBg, borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  '${filters.ecoScoreRange.start.round()} - ${filters.ecoScoreRange.end.round()}',
                                  style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          RangeSlider(
                            values: filters.ecoScoreRange,
                            min: 0,
                            max: 100,
                            activeColor: primaryGreen,
                            inactiveColor: borderGray,
                            onChanged: (values) => setState(() => filters = filters.copyWith(ecoScoreRange: values)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('0', style: TextStyle(color: textGray, fontSize: 12)),
                              Text('100', style: TextStyle(color: textGray, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.attach_money_rounded, color: primaryGreen, size: 20),
                                  SizedBox(width: 4),
                                  Text('Price Range', style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 15)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: lightGreenBg, borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  'Rs. ${filters.priceRange.start.round()} - Rs. ${filters.priceRange.end.round()}',
                                  style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          RangeSlider(
                            values: filters.priceRange,
                            min: 0,
                            max: 10000,
                            activeColor: primaryGreen,
                            inactiveColor: borderGray,
                            onChanged: (values) => setState(() => filters = filters.copyWith(priceRange: values)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Rs. 0', style: TextStyle(color: textGray, fontSize: 12)),
                              Text('Rs. 10,000', style: TextStyle(color: textGray, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.sell_outlined, color: textDark, size: 20),
                              SizedBox(width: 8),
                              Text('Brand', style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: brandOptions.map((brand) {
                              return buildChip(
                                label: brand,
                                selected: filters.selectedBrand == brand,
                                onTap: () => setState(() => filters = filters.copyWith(selectedBrand: brand)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.eco_outlined, color: textDark, size: 20),
                              SizedBox(width: 8),
                              Text('Material', style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: materialOptions.map((material) {
                              final selected = filters.selectedMaterial == material;
                              return buildChip(
                                label: material,
                                selected: selected,
                                onTap: () => setState(() {
                                  filters = selected
                                      ? filters.copyWith(clearMaterial: true)
                                      : filters.copyWith(selectedMaterial: material);
                                }),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.inventory_2_outlined, color: textDark, size: 20),
                              SizedBox(width: 8),
                              Text('Availability', style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: filters.inStockOnly,
                                activeColor: primaryGreen,
                                onChanged: (value) => setState(() => filters = filters.copyWith(inStockOnly: value ?? true)),
                              ),
                              const Text('In Stock', style: TextStyle(color: textDark, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context, filters),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}