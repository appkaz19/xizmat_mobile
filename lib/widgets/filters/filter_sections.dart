import "package:flutter/material.dart";
import "../../utils/city_autocomplete.dart";

// Остальные виджеты остаются без изменений...
class FilterHeader extends StatelessWidget {
  final VoidCallback onClose;

  const FilterHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Фильтр',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class ServicesFilterSection extends StatelessWidget {
  final List<Map<String, String>> categories;
  final List<Map<String, String>> subcategories;
  final String? selectedCategoryId;
  final String? selectedSubcategoryId;
  final bool allowCategoryChange;
  final Function(String?) onCategoryChanged;
  final Function(String?) onSubcategoryChanged;

  const ServicesFilterSection({
    super.key,
    required this.categories,
    required this.subcategories,
    required this.selectedCategoryId,
    required this.selectedSubcategoryId,
    required this.allowCategoryChange,
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FilterSectionTitle('Услуги'),
        const SizedBox(height: 12),

        if (allowCategoryChange)
          CategoryDropdown(
            categories: categories,
            selectedCategoryId: selectedCategoryId,
            onChanged: onCategoryChanged,
          ),

        if (allowCategoryChange) const SizedBox(height: 12),

        if (subcategories.isNotEmpty)
          SubcategoryDropdown(
            subcategories: subcategories,
            selectedSubcategoryId: selectedSubcategoryId,
            onChanged: onSubcategoryChanged,
          ),
      ],
    );
  }
}

class LocationFilterSection extends StatelessWidget {
  final List<Map<String, dynamic>> cities;
  final String? selectedCityId;
  final Function(String?) onCityChanged;

  const LocationFilterSection({
    super.key,
    required this.cities,
    required this.selectedCityId,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FilterSectionTitle('Местоположение'),
        const SizedBox(height: 12),
        CityAutocomplete(
          cities: cities,
          selectedCityId: selectedCityId,
          onCityChanged: onCityChanged,
        ),
      ],
    );
  }
}

class RatingFilterSection extends StatelessWidget {
  final int? selectedRating;
  final Function(int?) onRatingChanged;

  const RatingFilterSection({
    super.key,
    required this.selectedRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FilterSectionTitle('Рейтинг'),
        const SizedBox(height: 12),
        RatingChips(
          selectedRating: selectedRating,
          onRatingChanged: onRatingChanged,
        ),
      ],
    );
  }
}

class FilterSectionTitle extends StatelessWidget {
  final String title;
  const FilterSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}

class CategoryDropdown extends StatelessWidget {
  final List<Map<String, String>> categories;
  final String? selectedCategoryId;
  final Function(String?) onChanged;

  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Категория',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('Все категории')),
        ...categories.map((category) => DropdownMenuItem<String>(
          value: category['id'],
          child: Text(category['name'] ?? ''),
        )),
      ],
      onChanged: onChanged,
    );
  }
}

class SubcategoryDropdown extends StatelessWidget {
  final List<Map<String, String>> subcategories;
  final String? selectedSubcategoryId;
  final Function(String?) onChanged;

  const SubcategoryDropdown({
    super.key,
    required this.subcategories,
    required this.selectedSubcategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedSubcategoryId,
      decoration: const InputDecoration(
        labelText: 'Подкатегория',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('Все подкатегории')),
        ...subcategories.map((subcategory) => DropdownMenuItem<String>(
          value: subcategory['id'],
          child: Text(subcategory['name'] ?? ''),
        )),
      ],
      onChanged: onChanged,
    );
  }
}

class RatingChips extends StatelessWidget {
  final int? selectedRating;
  final Function(int?) onRatingChanged;

  const RatingChips({
    super.key,
    required this.selectedRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildRatingChip('Все', null),
        _buildRatingChip('5★', 5),
        _buildRatingChip('4★', 4),
        _buildRatingChip('3★', 3),
      ],
    );
  }

  Widget _buildRatingChip(String label, int? rating) {
    final isSelected = selectedRating == rating;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        final newRating = selected ? rating : null;
        onRatingChanged(newRating);
      },
      selectedColor: const Color(0xFF2E7D5F).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2E7D5F),
    );
  }
}

class FilterBottomButtons extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onApply;

  const FilterBottomButtons({
    super.key,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReset,
              child: const Text('Сбросить'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D5F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Применить'),
            ),
          ),
        ],
      ),
    );
  }
}
