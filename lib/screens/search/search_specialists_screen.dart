import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api/service.dart';
import '../../widgets/search_header.dart';
import '../../widgets/search_results.dart';
import '../../widgets/recent_searches.dart';
import '../../widgets/no_results.dart';
import '../../widgets/filter_bottom_sheet.dart';

class SearchSpecialistsScreen extends StatefulWidget {
  const SearchSpecialistsScreen({super.key});

  @override
  State<SearchSpecialistsScreen> createState() => _SearchSpecialistsScreenState();
}

class _SearchSpecialistsScreenState extends State<SearchSpecialistsScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  // Data state
  List<String> recentSearches = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, String>> categories = [];
  List<Map<String, String>> subcategories = [];
  List<Map<String, dynamic>> cities = [];
  Set<String> favoriteServices = {};

  // UI state
  bool isLoading = false;
  bool hasSearched = false;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int currentPage = 1;
  int totalResults = 0;

  // Filter state
  String? selectedCategoryId;
  String? selectedSubcategoryId;
  String? selectedCityId;
  double minPrice = 0;
  double maxPrice = 100000;
  int? selectedRating;

  static const String _recentSearchesKey = 'recent_searches';
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // INITIALIZATION
  Future<void> _initialize() async {
    await Future.wait([
      _loadRecentSearches(),
      _loadInitialData(),
    ]);
    await _loadInitialServices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        ApiService.category.getCategories(),
        ApiService.location.getRegionsWithCities(),
      ]);

      setState(() {
        categories = results[0] as List<Map<String, String>>;
        cities = results[1] as List<Map<String, dynamic>>;
      });

      _logDataLoaded();
    } catch (e) {
      print('Ошибка загрузки данных: $e');
    }
  }

  void _logDataLoaded() {
    print('Загружено категорий: ${categories.length}');
    print('Загружено городов: ${cities.length}');
    if (categories.isNotEmpty) print('Первая категория: ${categories.first}');
    if (cities.isNotEmpty) print('Первый город: ${cities.first}');
  }

  // API RESPONSE HANDLING
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

  // SEARCH AND LOADING
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

    if (resetPage && searchQuery.isNotEmpty) {
      await _updateSearchHistory(searchQuery);
    }

    try {
      final queryParams = _buildQueryParams(searchQuery);
      print('Параметры поиска (страница $currentPage): $queryParams');

      final response = await ApiService.service.searchServices(queryParams);
      print('Ответ API: $response');

      final parsed = _parseApiResponse(response);
      final filteredServices = _applyClientFilters(parsed.services);

      print('Получено услуг: ${parsed.services.length}, всего: ${parsed.total}');
      if (minPrice > 0) print('После фильтрации по minPrice ($minPrice): ${filteredServices.length}');

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
        hasSearched = true;
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
    };

    if (searchQuery.isNotEmpty) queryParams['search'] = searchQuery;
    if (selectedCategoryId != null) queryParams['categoryId'] = selectedCategoryId;
    if (selectedSubcategoryId != null) queryParams['subcategoryId'] = selectedSubcategoryId;
    if (selectedCityId != null) queryParams['cityId'] = selectedCityId;
    if (maxPrice < 100000) queryParams['price'] = maxPrice.toString();

    return queryParams;
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

  // SEARCH HISTORY
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchesKey) ?? [];
    setState(() => recentSearches = searches);
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  Future<void> _updateSearchHistory(String searchQuery) async {
    if (!recentSearches.contains(searchQuery)) {
      setState(() {
        recentSearches.insert(0, searchQuery);
        if (recentSearches.length > 10) recentSearches.removeLast();
      });
    } else {
      setState(() {
        recentSearches.remove(searchQuery);
        recentSearches.insert(0, searchQuery);
      });
    }
    await _saveRecentSearches();
  }

  Future<void> _clearAllRecentSearches() async {
    setState(() => recentSearches.clear());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }

  Future<void> _removeRecentSearch(int index) async {
    setState(() => recentSearches.removeAt(index));
    await _saveRecentSearches();
  }

  // FILTERS
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
      selectedCategoryId = null;
      selectedSubcategoryId = null;
      selectedCityId = null;
      minPrice = 0;
      maxPrice = 100000;
      selectedRating = null;
      subcategories.clear();
    });
  }

  void _resetToInitialState() {
    _searchController.clear();
    setState(() {
      hasSearched = false;
      currentPage = 1;
      searchResults.clear();
    });
    _resetFilters();
    _focusNode.requestFocus();
  }

  bool _hasActiveFilters() {
    return selectedCategoryId != null ||
        selectedSubcategoryId != null ||
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
        selectedCategoryId: selectedCategoryId,
        selectedSubcategoryId: selectedSubcategoryId,
        selectedCityId: selectedCityId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        selectedRating: selectedRating,
        onCategoryChanged: (value) {
          setState(() {
            selectedCategoryId = value;
            selectedSubcategoryId = null;
            subcategories.clear();
          });
          if (value != null) _loadSubcategories(value);
        },
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
      body: SafeArea(
        child: Column(
          children: [
            SearchHeader(
              controller: _searchController,
              focusNode: _focusNode,
              hasActiveFilters: _hasActiveFilters(),
              onSearch: (value) => _performSearch(query: value, resetPage: true),
              onFilterTap: _showFilters,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: !hasSearched
                  ? RecentSearches(
                searches: recentSearches,
                onSearchTap: (search) {
                  _searchController.text = search;
                  _performSearch(query: search, resetPage: true);
                },
                onRemoveSearch: _removeRecentSearch,
                onClearAll: _clearAllRecentSearches,
              )
                  : isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D5F)))
                  : searchResults.isEmpty
                  ? NoResults(onRetry: _resetToInitialState)
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
      ),
    );
  }
}