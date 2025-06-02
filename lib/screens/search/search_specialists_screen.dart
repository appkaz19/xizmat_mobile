import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api/service.dart';

class SearchSpecialistsScreen extends StatefulWidget {
  const SearchSpecialistsScreen({super.key});

  @override
  State<SearchSpecialistsScreen> createState() => _SearchSpecialistsScreenState();
}

class _SearchSpecialistsScreenState extends State<SearchSpecialistsScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<String> recentSearches = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, String>> categories = [];
  List<Map<String, String>> subcategories = [];
  List<Map<String, dynamic>> cities = [];

  bool isLoading = false;
  bool hasSearched = false;

  // Filter values
  String? selectedCategoryId;
  String? selectedSubcategoryId;
  String? selectedCityId;
  double minPrice = 0;
  double maxPrice = 100000;
  int? selectedRating;

  static const String _recentSearchesKey = 'recent_searches';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final categoriesData = await ApiService.category.getCategories();
      final citiesData = await ApiService.location.getRegionsWithCities();

      setState(() {
        categories = categoriesData;
        cities = citiesData;
      });
    } catch (e) {
      print('Ошибка загрузки данных: $e');
    }
  }

  Future<void> _loadSubcategories(String categoryId) async {
    try {
      final subcategoriesData = await ApiService.subcategory.getSubcategoriesByCategory(categoryId);
      setState(() {
        subcategories = subcategoriesData;
        selectedSubcategoryId = null; // Reset subcategory when category changes
      });
    } catch (e) {
      print('Ошибка загрузки подкатегорий: $e');
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchesKey) ?? [];
    setState(() {
      recentSearches = searches;
    });
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  Future<void> _clearAllRecentSearches() async {
    setState(() {
      recentSearches.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }

  Future<void> _removeRecentSearch(int index) async {
    setState(() {
      recentSearches.removeAt(index);
    });
    await _saveRecentSearches();
  }

  Future<void> _performSearch([String? query]) async {
    final searchQuery = query ?? _searchController.text.trim();
    if (searchQuery.isEmpty && selectedCategoryId == null && selectedCityId == null) return;

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    // Add to search history
    if (searchQuery.isNotEmpty && !recentSearches.contains(searchQuery)) {
      setState(() {
        recentSearches.insert(0, searchQuery);
        if (recentSearches.length > 10) {
          recentSearches.removeLast();
        }
      });
      await _saveRecentSearches();
    } else if (searchQuery.isNotEmpty) {
      // Move to top if already exists
      setState(() {
        recentSearches.remove(searchQuery);
        recentSearches.insert(0, searchQuery);
      });
      await _saveRecentSearches();
    }

    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {};

      if (searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (selectedCategoryId != null) {
        queryParams['categoryId'] = selectedCategoryId;
      }
      if (selectedSubcategoryId != null) {
        queryParams['subcategoryId'] = selectedSubcategoryId;
      }
      if (selectedCityId != null) {
        queryParams['cityId'] = selectedCityId;
      }
      if (minPrice > 0) {
        queryParams['minPrice'] = minPrice.toString();
      }
      if (maxPrice < 100000) {
        queryParams['maxPrice'] = maxPrice.toString();
      }

      final results = await ApiService.service.searchServices(queryParams);

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка поиска: $e');
      setState(() {
        searchResults = [];
        isLoading = false;
      });
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Фильтр',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Filter content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Services section
                      const Text(
                        'Услуги',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Категория',
                          border: OutlineInputBorder(),
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
                        onChanged: (value) {
                          setModalState(() {
                            selectedCategoryId = value;
                            selectedSubcategoryId = null;
                            subcategories.clear();
                          });
                          setState(() {
                            selectedCategoryId = value;
                            selectedSubcategoryId = null;
                            subcategories.clear();
                          });
                          if (value != null) {
                            _loadSubcategories(value);
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      // Subcategory dropdown
                      if (subcategories.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: selectedSubcategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Подкатегория',
                            border: OutlineInputBorder(),
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
                          onChanged: (value) {
                            setModalState(() {
                              selectedSubcategoryId = value;
                            });
                            setState(() {
                              selectedSubcategoryId = value;
                            });
                          },
                        ),

                      const SizedBox(height: 24),

                      // Location section
                      const Text(
                        'Местоположение',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // City dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCityId,
                        decoration: const InputDecoration(
                          labelText: 'Город',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Все города'),
                          ),
                          ...cities.map((city) => DropdownMenuItem<String>(
                            value: city['id'],
                            child: Text('${city['name']} (${city['region']})'),
                          )),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            selectedCityId = value;
                          });
                          setState(() {
                            selectedCityId = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Price section
                      const Text(
                        'Цена',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: minPrice.toString(),
                              decoration: const InputDecoration(
                                labelText: 'От',
                                border: OutlineInputBorder(),
                                suffixText: '₸',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final price = double.tryParse(value) ?? 0;
                                setModalState(() {
                                  minPrice = price;
                                });
                                setState(() {
                                  minPrice = price;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: maxPrice.toString(),
                              decoration: const InputDecoration(
                                labelText: 'До',
                                border: OutlineInputBorder(),
                                suffixText: '₸',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final price = double.tryParse(value) ?? 100000;
                                setModalState(() {
                                  maxPrice = price;
                                });
                                setState(() {
                                  maxPrice = price;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Rating section
                      const Text(
                        'Рейтинг',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        children: [
                          _buildRatingChip('Все', null, setModalState),
                          _buildRatingChip('5★', 5, setModalState),
                          _buildRatingChip('4★', 4, setModalState),
                          _buildRatingChip('3★', 3, setModalState),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Reset filters
                          setModalState(() {
                            selectedCategoryId = null;
                            selectedSubcategoryId = null;
                            selectedCityId = null;
                            minPrice = 0;
                            maxPrice = 100000;
                            selectedRating = null;
                          });
                          setState(() {
                            selectedCategoryId = null;
                            selectedSubcategoryId = null;
                            selectedCityId = null;
                            minPrice = 0;
                            maxPrice = 100000;
                            selectedRating = null;
                            subcategories.clear();
                          });
                        },
                        child: const Text('Сбросить'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _performSearch();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D5F),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Применить'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingChip(String label, int? rating, StateSetter setModalState) {
    final isSelected = selectedRating == rating;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          selectedRating = selected ? rating : null;
        });
        setState(() {
          selectedRating = selected ? rating : null;
        });
      },
      selectedColor: const Color(0xFF2E7D5F).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2E7D5F),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Поиск специалистов...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          // Real-time search can be implemented here
                        },
                        onSubmitted: (value) {
                          if (value.isNotEmpty || _hasActiveFilters()) {
                            _performSearch(value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: _hasActiveFilters() ? const Color(0xFF2E7D5F) : Colors.grey,
                    ),
                    onPressed: _showFilters,
                  ),
                ],
              ),
            ),

            // Content based on search state
            Expanded(
              child: !hasSearched
                  ? _buildRecentSearches()
                  : isLoading
                  ? _buildLoadingState()
                  : searchResults.isEmpty
                  ? _buildNoResults()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return selectedCategoryId != null ||
        selectedSubcategoryId != null ||
        selectedCityId != null ||
        minPrice > 0 ||
        maxPrice < 100000 ||
        selectedRating != null;
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF2E7D5F),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Результаты поиска (${searchResults.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final service = searchResults[index];
              return _buildServiceCard(service);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final title = service['title'] ?? 'Без названия';
    final description = service['description'] ?? '';
    final price = service['price']?.toString() ?? '0';
    final images = service['images'] as List<dynamic>? ?? [];
    final userName = service['user']?['fullName'] ?? service['user']?['nickname'] ?? 'Аноним';
    final cityName = service['city']?['translations']?[0]?['name'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: images.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(images[0]),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: images.isEmpty
                  ? const Icon(Icons.image, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),

            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (cityName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      cityName,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${price}₸',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D5F),
                    ),
                  ),
                ],
              ),
            ),

            // Bookmark icon
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.grey),
              onPressed: () {
                // Implement bookmark functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'История поиска пуста',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ваши недавние поиски будут отображаться здесь',
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Недавние',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Очистить историю'),
                      content: const Text('Удалить всю историю поиска?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearAllRecentSearches();
                          },
                          child: const Text(
                            'Очистить',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Очистить все'),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(recentSearches[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => _removeRecentSearch(index),
                ),
                onTap: () {
                  _searchController.text = recentSearches[index];
                  _performSearch(recentSearches[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D5F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sentiment_dissatisfied,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Icon(
                  Icons.search_off,
                  size: 30,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Ничего не найдено',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'К сожалению, по вашему запросу ничего не найдено. Попробуйте изменить ключевое слово или настройки фильтра.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                hasSearched = false;
                selectedCategoryId = null;
                selectedSubcategoryId = null;
                selectedCityId = null;
                minPrice = 0;
                maxPrice = 100000;
                selectedRating = null;
                subcategories.clear();
              });
              _focusNode.requestFocus();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D5F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Попробовать другой запрос'),
          ),
        ],
      ),
    );
  }
}