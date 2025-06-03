import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api/service.dart';
import '../../widgets/search_header.dart';
import '../../widgets/search_results.dart';
import '../../widgets/recent_searches.dart';
import '../../widgets/no_results.dart';
import '../../widgets/universal_filter_bottom_sheet.dart';

enum SearchType { SERVICES, JOBS }

class UniversalSearchScreen extends StatefulWidget {
  final SearchType type;
  final String? fixedCategoryId;
  final String? title;

  const UniversalSearchScreen({
    super.key,
    required this.type,
    this.fixedCategoryId,
    this.title,
  });

  @override
  State<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends State<UniversalSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  // Data state
  List<String> recentSearches = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, String>> categories = [];
  List<Map<String, String>> subcategories = [];
  List<Map<String, dynamic>> cities = [];
  Set<String> favoriteItems = {};

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

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.fixedCategoryId; // Устанавливаем фиксированную категорию
    _initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _recentSearchesKey => 'recent_searches_${widget.type.name.toLowerCase()}';

  String get _searchHint => widget.type == SearchType.SERVICES
      ? 'Поиск специалистов...'
      : 'Поиск объявлений...';

  String get _screenTitle => widget.title ?? (widget.type == SearchType.SERVICES
      ? 'Поиск услуг'
      : 'Поиск объявлений');

  // INITIALIZATION
  Future<void> _initialize() async {
    await Future.wait([
      _loadRecentSearches(),
      _loadInitialData(),
    ]);
    await _loadInitialItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      List<Future> futures = [
        ApiService.location.getRegionsWithCities(),
      ];

      // Только для услуг загружаем категории
      if (widget.type == SearchType.SERVICES) {
        futures.add(ApiService.category.getCategories());

        // Если есть фиксированная категория, загружаем её подкатегории
        if (widget.fixedCategoryId != null) {
          futures.add(ApiService.subcategory.getSubcategoriesByCategory(widget.fixedCategoryId!));
        }
      }

      final results = await Future.wait(futures);

      setState(() {
        cities = results[0] as List<Map<String, dynamic>>;

        if (widget.type == SearchType.SERVICES) {
          categories = results[1] as List<Map<String, String>>;

          if (widget.fixedCategoryId != null && results.length > 2) {
            subcategories = results[2] as List<Map<String, String>>;
          }
        }
      });

      _logDataLoaded();
    } catch (e) {
      print('Ошибка загрузки данных: $e');
    }
  }

  void _logDataLoaded() {
    print('Загружено городов: ${cities.length}');
    if (widget.type == SearchType.SERVICES) {
      print('Загружено категорий: ${categories.length}');
      print('Загружено подкатегорий: ${subcategories.length}');
    }
  }

  // API RESPONSE HANDLING
  ({List<Map<String, dynamic>> items, int total}) _parseApiResponse(dynamic response) {
    List<Map<String, dynamic>> items = [];
    int total = 0;

    if (response is Map<String, dynamic>) {
      final itemsKey = widget.type == SearchType.SERVICES ? 'services' : 'jobs';
      final itemsList = response[itemsKey] as List<dynamic>?;
      items = itemsList?.map<Map<String, dynamic>>(_mapToItem).toList() ?? [];

      final rawTotal = response['total'];
      total = rawTotal is int ? rawTotal : int.tryParse(rawTotal?.toString() ?? '0') ?? 0;
    } else if (response is List<dynamic>) {
      items = response.map<Map<String, dynamic>>(_mapToItem).toList();
      total = items.length;
    }

    return (items: items, total: total);
  }

  Map<String, dynamic> _mapToItem(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item;
    } else if (item is Map) {
      return Map<String, dynamic>.from(item);
    } else {
      throw Exception('Invalid item type: ${item.runtimeType}');
    }
  }

  // SEARCH AND LOADING
  Future<void> _loadInitialItems() async {
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
      print('Параметры поиска ${widget.type.name} (страница $currentPage): $queryParams');

      final response = await _callApiMethod(queryParams);
      print('Ответ API: $response');

      final parsed = _parseApiResponse(response);
      final filteredItems = _applyClientFilters(parsed.items);

      print('Получено ${widget.type.name}: ${parsed.items.length}, всего: ${parsed.total}');
      if (minPrice > 0) print('После фильтрации по minPrice ($minPrice): ${filteredItems.length}');

      _updateSearchResults(filteredItems, parsed.total, resetPage);
    } catch (e) {
      print('Ошибка поиска ${widget.type.name}: $e');
      _handleSearchError(resetPage);
    }
  }

  Future<dynamic> _callApiMethod(Map<String, dynamic> queryParams) {
    switch (widget.type) {
      case SearchType.SERVICES:
        return ApiService.service.searchServices(queryParams);
      case SearchType.JOBS:
        return ApiService.job.searchJobs(queryParams);
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

    // Фильтры для услуг
    if (widget.type == SearchType.SERVICES) {
      if (selectedCategoryId != null) queryParams['categoryId'] = selectedCategoryId;
      if (selectedSubcategoryId != null) queryParams['subcategoryId'] = selectedSubcategoryId;
      if (maxPrice < 100000) queryParams['price'] = maxPrice.toString();
    }

    // Общие фильтры
    if (selectedCityId != null) queryParams['cityId'] = selectedCityId;

    return queryParams;
  }

  List<Map<String, dynamic>> _applyClientFilters(List<Map<String, dynamic>> items) {
    if (minPrice <= 0) return items;

    return items.where((item) {
      final itemPrice = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      return itemPrice >= minPrice;
    }).toList();
  }

  void _updateSearchResults(List<Map<String, dynamic>> items, int total, bool resetPage) {
    setState(() {
      if (resetPage) {
        searchResults = items;
      } else {
        searchResults.addAll(items);
      }
      totalResults = total;
      isLoading = false;
      isLoadingMore = false;
      hasMoreData = items.length >= _pageSize;
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

  Future<void> _loadMoreItems() async {
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
    if (widget.type != SearchType.SERVICES) return;

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
      if (widget.fixedCategoryId == null) {
        selectedCategoryId = null;
      }
      selectedSubcategoryId = null;
      selectedCityId = null;
      minPrice = 0;
      maxPrice = 100000;
      selectedRating = null;
      if (widget.fixedCategoryId == null) {
        subcategories.clear();
      }
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
    bool hasFilters = selectedCityId != null || minPrice > 0 || maxPrice < 100000;

    if (widget.type == SearchType.SERVICES) {
      hasFilters = hasFilters ||
          (widget.fixedCategoryId == null && selectedCategoryId != null) ||
          selectedSubcategoryId != null;
    }

    return hasFilters;
  }

  void _toggleFavorite(String itemId) {
    setState(() {
      if (favoriteItems.contains(itemId)) {
        favoriteItems.remove(itemId);
      } else {
        favoriteItems.add(itemId);
      }
    });
    print('${favoriteItems.contains(itemId) ? 'Added to' : 'Removed from'} favorites: $itemId');
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UniversalFilterBottomSheet(
        type: widget.type,
        categories: categories,
        subcategories: subcategories,
        cities: cities,
        selectedCategoryId: selectedCategoryId,
        selectedSubcategoryId: selectedSubcategoryId,
        selectedCityId: selectedCityId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        selectedRating: selectedRating,
        allowCategoryChange: widget.fixedCategoryId == null,
        onCategoryChanged: (value) {
          if (widget.fixedCategoryId == null) {
            setState(() {
              selectedCategoryId = value;
              selectedSubcategoryId = null;
              subcategories.clear();
            });
            if (value != null) _loadSubcategories(value);
          }
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
      appBar: AppBar(
        title: Text(_screenTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SearchHeader(
              controller: _searchController,
              focusNode: _focusNode,
              hasActiveFilters: _hasActiveFilters(),
              hintText: _searchHint,
              onSearch: (value) => _performSearch(query: value, resetPage: true),
              onFilterTap: _showFilters,
              onBack: () => Navigator.pop(context),
              showBackButton: true,
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
                favoriteServices: favoriteItems,
                onFavoriteTap: _toggleFavorite,
                onLoadMore: _loadMoreItems,
              ),
            ),
          ],
        ),
      ),
    );
  }
}