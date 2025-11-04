import 'package:flutter/material.dart';
import '../../../../domain/entities/pet_category.dart';

class CategoryFilter extends StatelessWidget {
  final PetCategory selectedCategory;
  final Function(PetCategory) onCategoryChanged;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: PetCategory.values.length,
        itemBuilder: (context, index) {
          final category = PetCategory.values[index];
          final isSelected = category == selectedCategory;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                category.fullName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey[200],
              onSelected: (selected) {
                if (selected) {
                  onCategoryChanged(category);
                }
              },
              elevation: isSelected ? 4 : 1,
              pressElevation: 6,
            ),
          );
        },
      ),
    );
  }
}