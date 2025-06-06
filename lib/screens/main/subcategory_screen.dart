import 'package:flutter/material.dart';
import '../../services/api/service.dart';
import '../search/universal_search_screen.dart';

class SubcategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const SubcategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  List<Map<String, String>> subcategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  Future<void> _loadSubcategories() async {
    try {
      final subcategoriesData = await ApiService.subcategory
          .getSubcategoriesByCategory(widget.categoryId);
      setState(() {
        subcategories = subcategoriesData;
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки подкатегорий: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка загрузки подкатегорий'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToSearch({String? subcategoryId, String? subcategoryName}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UniversalSearchScreen(
          type: SearchType.SERVICES,
          fixedCategoryId: widget.categoryId,
          fixedSubcategoryId: subcategoryId, // Передаем подкатегорию
          title: subcategoryName != null
              ? '${widget.categoryName} - $subcategoryName'
              : widget.categoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _navigateToSearch(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSubcategories,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Кнопка "Все услуги в категории"
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToSearch(),
                  icon: const Icon(Icons.apps),
                  label: Text('Все услуги в категории "${widget.categoryName}"'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D5F),
                    ),
                  ),
                )
              else if (subcategories.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Подкатегории не найдены',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Используйте кнопку выше для поиска всех услуг в категории',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: subcategories.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final subcategory = subcategories[index];
                    final subcategoryName = subcategory['name'] ?? 'Без названия';
                    final subcategoryId = subcategory['id'] ?? '';

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D5F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.folder_outlined,
                          color: Color(0xFF2E7D5F),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        subcategoryName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () => _navigateToSearch(
                        subcategoryId: subcategoryId,
                        subcategoryName: subcategoryName,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 8,
                      ),
                    );
                  },
                ),

              // Отступ снизу
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}