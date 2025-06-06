import 'package:flutter/material.dart';

// ДОБАВЛЯЕМ отсутствующий компонент FilterSectionTitle
class FilterSectionTitle extends StatelessWidget {
  final String title;

  const FilterSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}

class ServicesFilterSection extends StatelessWidget {
  final List<Map<String, String>> categories;
  final List<Map<String, String>> subcategories;
  final String? selectedCategoryId;
  final String? selectedSubcategoryId;
  final bool allowCategoryChange;
  final bool allowSubcategoryChange; // ДОБАВИЛИ: новый параметр
  final Function(String?) onCategoryChanged;
  final Function(String?) onSubcategoryChanged;

  const ServicesFilterSection({
    super.key,
    required this.categories,
    required this.subcategories,
    required this.selectedCategoryId,
    required this.selectedSubcategoryId,
    required this.allowCategoryChange,
    this.allowSubcategoryChange = true, // ДОБАВИЛИ: дефолтное значение
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Категория
        if (allowCategoryChange) ...[
          const Text(
            'Категория',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedCategoryId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Выберите категорию',
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Все категории'),
              ),
              ...categories.map((category) => DropdownMenuItem<String>(
                value: category['id'],
                child: Text(category['name'] ?? ''),
              )),
            ],
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 16),
        ] else if (selectedCategoryId != null) ...[
          // Показываем выбранную категорию как неизменяемое поле
          const Text(
            'Категория',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[50],
            ),
            child: Text(
              categories.firstWhere(
                    (cat) => cat['id'] == selectedCategoryId,
                orElse: () => {'name': 'Неизвестная категория'},
              )['name'] ?? 'Неизвестная категория',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Подкатегория
        if (allowSubcategoryChange) ...[
          const Text(
            'Подкатегория',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedSubcategoryId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Выберите подкатегорию',
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Все подкатегории'),
              ),
              ...subcategories.map((subcategory) => DropdownMenuItem<String>(
                value: subcategory['id'],
                child: Text(subcategory['name'] ?? ''),
              )),
            ],
            onChanged: subcategories.isNotEmpty ? onSubcategoryChanged : null,
          ),
        ] else if (selectedSubcategoryId != null) ...[
          // ДОБАВИЛИ: показываем выбранную подкатегорию как неизменяемое поле
          const Text(
            'Подкатегория',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[50],
            ),
            child: Text(
              subcategories.firstWhere(
                    (subcat) => subcat['id'] == selectedSubcategoryId,
                orElse: () => {'name': 'Неизвестная подкатегория'},
              )['name'] ?? 'Неизвестная подкатегория',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
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
        const Text(
          'Город',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCityId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Выберите город',
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Все города'),
            ),
            ...cities.map((city) => DropdownMenuItem<String>(
              value: city['id']?.toString(),
              child: Text(city['name']?.toString() ?? ''),
            )),
          ],
          onChanged: onCityChanged,
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
        const Text(
          'Минимальный рейтинг',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (int i = 1; i <= 5; i++)
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('$i+'),
                  ],
                ),
                selected: selectedRating == i,
                onSelected: (selected) {
                  onRatingChanged(selected ? i : null);
                },
                selectedColor: const Color(0xFF2E7D5F).withOpacity(0.2),
                checkmarkColor: const Color(0xFF2E7D5F),
              ),
          ],
        ),
      ],
    );
  }
}