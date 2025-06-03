import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api/service.dart';
import '../../widgets/search_results.dart';
import '../../widgets/filter_bottom_sheet.dart';

class ServicesListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ServicesListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  final _searchController = TextEditingController();

  // Data state - переиспользуем логику из search
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, String>> categories = [];
  List<Map<String, String>> subcategories = [];
  List<Map<String, dynamic>> cities = [];
  Set<String> favoriteServices = {};

  // UI state
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int currentPage = 1;
  int totalResults = 0;

  // Filter state
  String? selectedSubcategoryId;
  String? selectedCityId;
  double minPrice = 0;
  double maxPrice = 100000;
  int? selectedRating;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Переиспользуем методы из search_specialists_screen
  Future<void> _initialize() async {
    await _loadInitialData();
    await _loadInitialServices();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        ApiService.subcategory.getSubcategoriesByCategory(widget.categoryId),
        ApiService.location.getRegionsWithCities(),
      ]);

      setState(() {
        subcategories = results[0] as List<Map<String, String>>;
        cities = results[1] as List<Map<String, dynamic>>;
        // Создаем категорию для фильтра
        categories = [{'id': widget.categoryId, 'name': widget.categoryName}];
      });
    } catch (e) {
      print('Ошибка загрузки данных: $e');
    }
  }

  Future<void> _loadInitialServices() async {
    await _performSearch(resetPage: true, showLoading: true);
  }

  Future<void> _performSearch({
    String? query,
    bool resetPage = true,
    bool showLoading = false,
  }) async {
    final searchQuery = query ?? _searchController.text.trim();

    _updateLoadingState(resetPage, showLoading);

    try {
      final queryParams = _buildQueryParams(searchQuery);
      print('Параметры поиска (страница $currentPage): $queryParams');

      final response = await ApiService.service.searchServices(queryParams);
      final parsed = _parseApiResponse(response);
      final filteredServices = _applyClientFilters(parsed.services);

      print('Получено услуг: ${parsed.services.length}, всего: ${parsed.total}');

      _updateSearchResults(filteredServices, parsed.total, resetPage);
    } catch (e) {
      print('Ошибка поиска: $e');
      _handleSearchError(resetPage);
    }
  }

  void _updateLoadingState(bool resetPage, bool showLoading) {
    setState(() {
      if (resetPage) {
        isLoading = showLoading;
        currentPage = 1;
        hasMoreData = true;
      } else {
        isLoadingMore = true;
      }
    });
  }

  Map<String, dynamic> _buildQueryParams(String searchQuery) {
    final queryParams = <String, dynamic>{
      'page': currentPage.toString(),
      'limit': _pageSize.toString(),
      'categoryId': widget.categoryId, // Фиксированная категория
    };

    if (searchQuery.isNotEmpty) queryParams['search'] = searchQuery;
    if (selectedSubcategoryId != null) queryParams['subcategoryId'] = selectedSubcategoryId;
    if (selectedCityId != null) queryParams['cityId'] = selectedCityId;
    if (maxPrice < 100000) queryParams['price'] = maxPrice.toString();

    return queryParams;
  }

  ({List<Map<String, dynamic>> services, int total}) _parseApiResponse(dynamic response) {
    List<Map<String, dynamic>> services = [];
    int total = 0;

    if (response is Map<String, dynamic>) {
      final servicesList = response['services'] as List<dynamic>?;
      services = servicesList?.map<Map<String, dynamic>>(_mapToService).toList() ?? [];

      final rawTotal = response['total'];
      total = rawTotal is int ? rawTotal : int.tryParse(rawTotal?.toString() ?? '0') ?? 0;
    } else if (response is List<dynamic>) {
      services = response.map<Map<String, dynamic>>(_mapToService).toList();
      total = services.length;
    }

    return (services: services, total: total);
  }

  Map<String, dynamic> _mapToService(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item;
    } else if (item is Map) {
      return Map<String, dynamic>.from(item);
    } else {
      throw Exception('Invalid service item type: ${item.runtimeType}');
    }
  }

  List<Map<String, dynamic>> _applyClientFilters(List<Map<String, dynamic>> services) {
    if (minPrice <= 0) return services;

    return services.where((service) {
      final servicePrice = double.tryParse(service['price']?.toString() ?? '0') ?? 0;
      return servicePrice >= minPrice;
    }).toList();
  }

  void _updateSearchResults(List<Map<String, dynamic>> services, int total, bool resetPage) {
    setState(() {
      if (resetPage) {
        searchResults = services;
      } else {
        searchResults.addAll(services);
      }
      totalResults = total;
      isLoading = false;
      isLoadingMore = false;
      hasMoreData = services.length >= _pageSize;
      if (!resetPage) currentPage++;
    });
  }

  void _handleSearchError(bool resetPage) {
    setState(() {
      if (resetPage) searchResults = [];
      isLoading = false;
      isLoadingMore = false;
      hasMoreData = false;
    });
  }

  Future<void> _loadMoreServices() async {
    if (isLoadingMore || !hasMoreData) return;
    currentPage++;
    await _performSearch(resetPage: false);
  }

  Future<void> _loadSubcategories(String categoryId) async {
    try {
      final subcategoriesData = await ApiService.subcategory.getSubcategoriesByCategory(categoryId);
      setState(() {
        subcategories = subcategoriesData;
        selectedSubcategoryId = null;
      });
    } catch (e) {
      print('Ошибка загрузки подкатегорий: $e');
    }
  }

  void _resetFilters() {
    setState(() {
      selectedSubcategoryId = null;
      selectedCityId = null;
      minPrice = 0;
      maxPrice = 100000;
      selectedRating = null;
      subcategories.clear();
    });
  }

  bool _hasActiveFilters() {
    return selectedSubcategoryId != null ||
        selectedCityId != null ||
        minPrice > 0 ||
        maxPrice < 100000;
  }

  void _toggleFavorite(String serviceId) {
    setState(() {
      if (favoriteServices.contains(serviceId)) {
        favoriteServices.remove(serviceId);
      } else {
        favoriteServices.add(serviceId);
      }
    });
    print('${favoriteServices.contains(serviceId) ? 'Added to' : 'Removed from'} favorites: $serviceId');
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        categories: categories,
        subcategories: subcategories,
        cities: cities,
        selectedCategoryId: widget.categoryId, // Фиксированная категория
        selectedSubcategoryId: selectedSubcategoryId,
        selectedCityId: selectedCityId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        selectedRating: selectedRating,
        onCategoryChanged: (_) {}, // Категория фиксированная
        onSubcategoryChanged: (value) => setState(() => selectedSubcategoryId = value),
        onCityChanged: (value) => setState(() => selectedCityId = value),
        onPriceChanged: (min, max) => setState(() {
          minPrice = min;
          maxPrice = max;
        }),
        onRatingChanged: (value) => setState(() => selectedRating = value),
        onReset: _resetFilters,
        onApply: () {
          Navigator.pop(context);
          _performSearch(resetPage: true);
        },
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
            icon: Icon(
              Icons.tune,
              color: _hasActiveFilters() ? const Color(0xFF2E7D5F) : null,
            ),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Поиск в категории...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (value) => _performSearch(query: value, resetPage: true),
              ),
            ),
          ),

          // Переиспользуем SearchResults виджет!
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D5F)),
            )
                : searchResults.isEmpty
                ? _buildEmptyState()
                : SearchResults(
              results: searchResults,
              totalResults: totalResults,
              isLoadingMore: isLoadingMore,
              favoriteServices: favoriteServices,
              onFavoriteTap: _toggleFavorite,
              onLoadMore: _loadMoreServices,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Нет услуг в категории',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить фильтры поиска',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}