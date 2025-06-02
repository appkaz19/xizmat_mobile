import 'package:flutter/material.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/service_category_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<Map<String, dynamic>> categories = [
    {'title': 'Дом', 'icon': Icons.home, 'color': Colors.blue},
    {'title': 'Ремонт', 'icon': Icons.build, 'color': Colors.orange},
    {'title': 'Рем. техники', 'icon': Icons.devices, 'color': Colors.purple},
    {'title': 'Перевозки', 'icon': Icons.local_shipping, 'color': Colors.red},
    {'title': 'Красота', 'icon': Icons.face, 'color': Colors.pink},
    {'title': 'IT и фриланс', 'icon': Icons.computer, 'color': Colors.green},
    {'title': 'Ремесло', 'icon': Icons.handyman, 'color': Colors.brown},
    {'title': 'Спецтехника', 'icon': Icons.construction, 'color': Colors.grey},
    {'title': 'СТО', 'icon': Icons.car_repair, 'color': Colors.blue},
    {'title': 'Праздники', 'icon': Icons.celebration, 'color': Colors.purple},
    {'title': 'Деловые услуги', 'icon': Icons.business, 'color': Colors.indigo},
    {'title': 'Спорт', 'icon': Icons.sports, 'color': Colors.orange},
    {'title': 'Обучение', 'icon': Icons.school, 'color': Colors.teal},
    {'title': 'Строительство', 'icon': Icons.construction, 'color': Colors.amber},
    {'title': 'Прочие', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Все категории'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SearchBarWidget(),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ServiceCategoryCard(
                  title: category['title'],
                  icon: category['icon'],
                  color: category['color'],
                  onTap: () {
                    // Navigate to category
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}