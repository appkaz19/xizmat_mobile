import 'package:flutter/material.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/service_category_card.dart';
import '../../services/api/service.dart';
import 'subcategory_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Map<String, String>> categories = [];
  bool isLoading = true;

  // Иконки для категорий (можно дополнить)
  final Map<String, IconData> categoryIcons = {
    'Дом': Icons.home,
    'Ремонт': Icons.build,
    'Рем. техники': Icons.devices,
    'Перевозки': Icons.local_shipping,
    'Красота': Icons.face,
    'IT и фриланс': Icons.computer,
    'Ремесло': Icons.handyman,
    'Спецтехника': Icons.construction,
    'СТО': Icons.car_repair,
    'Праздники': Icons.celebration,
    'Деловые услуги': Icons.business,
    'Спорт': Icons.sports,
    'Обучение': Icons.school,
    'Строительство': Icons.engineering,
    'Прочие': Icons.more_horiz,
  };

  // Цвета для категорий
  final Map<String, Color> categoryColors = {
    'Дом': Colors.blue,
    'Ремонт': Colors.orange,
    'Рем. техники': Colors.purple,
    'Перевозки': Colors.red,
    'Красота': Colors.pink,
    'IT и фриланс': Colors.green,
    'Ремесло': Colors.brown,
    'Спецтехника': Colors.grey,
    'СТО': Colors.blue,
    'Праздники': Colors.purple,
    'Деловые услуги': Colors.indigo,
    'Спорт': Colors.orange,
    'Обучение': Colors.teal,
    'Строительство': Colors.amber,
    'Прочие': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesData = await ApiService.category.getCategories();
      setState(() {
        categories = categoriesData;
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки категорий: $e');
      setState(() {
        isLoading = false;
      });
      // Показываем снекбар с ошибкой
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка загрузки категорий'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getIconForCategory(String categoryName) {
    // Ищем иконку по точному совпадению или частичному
    for (final entry in categoryIcons.entries) {
      if (categoryName.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(categoryName.toLowerCase())) {
        return entry.value;
      }
    }
    return Icons.category; // Иконка по умолчанию
  }

  Color _getColorForCategory(String categoryName) {
    // Ищем цвет по точному совпадению или частичному
    for (final entry in categoryColors.entries) {
      if (categoryName.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(categoryName.toLowerCase())) {
        return entry.value;
      }
    }
    return Colors.grey; // Цвет по умолчанию
  }

  void _navigateToSubcategories(String categoryId, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubcategoryScreen(
          categoryId: categoryId,
          categoryName: categoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Все категории'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Переход к общему поиску без фиксированной категории
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SearchBarWidget(),
              const SizedBox(height: 24),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D5F),
                    ),
                  ),
                )
              else if (categories.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Категории не найдены',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
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
                    final categoryName = category['name'] ?? 'Без названия';
                    final categoryId = category['id'] ?? '';

                    return ServiceCategoryCard(
                      title: categoryName,
                      icon: _getIconForCategory(categoryName),
                      color: _getColorForCategory(categoryName),
                      onTap: () {
                        _navigateToSubcategories(categoryId, categoryName);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}