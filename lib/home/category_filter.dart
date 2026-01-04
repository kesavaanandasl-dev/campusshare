import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const CategoryFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final categories = const [
    'All',
    'Books',
    'Stationery',
    'Gadgets',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;

          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => onChanged(category),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length,
      ),
    );
  }
}
