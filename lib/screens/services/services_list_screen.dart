import 'package:flutter/material.dart';
import '../../services/api/service.dart';
import '../../models/service_category.dart';
import '../search/widgets/service_card.dart';
import '../search/widgets/filter_bottom_sheet.dart';
import '../../widgets/services_grid.dart';
import '../../widgets/services_search_bar.dart';

class ServicesListScreen extends StatefulWidget {
  final ServiceCategory category;

  const ServicesListScreen({
    super.key,
    required this.category,
  });

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  // Data state
  List<Map<String, dynamic>> services = [];
  List<Map<String, String>> subcategories = [];
  List<Map<String, dynamic>> cities = [];
  Set<String> favoriteServices = {};

  // UI state
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int currentPage = 1;
  int totalResults = 0;

  // Search and filter state
  String searchQuery = '';
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

  Future<void> _initialize() async {
    await _loadInitialData();
    await _loadServices();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        ApiService.subcategory.getSubcategoriesByCategory(widget.category.id),
        ApiService.location.getRegionsWithCities(),
      ]);

      setState(() {
        subcategories = results[0] as List<Map<String, String>>;
        cities = results[1] as List<Map<String, dynamic>>;
      });
    } catch (e) {
      print('Ошибка загрузки данных: $e');
    }
  }

  Future<void> _loadServices({bool resetPage = true}) async {
    if (resetPage) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        hasMoreData = true;
      });
    } else {
      setState(() => isLoadingMore = true);
    }

    try {
      final queryParams = _buildQueryParams();
      print('Загрузка услуг для категории ${widget.category.name}: $queryParams');

      final response = await ApiService.service.searchServices(queryParams);
      final parsed = _parseApiResponse(response);
      final filteredServices = _applyClientFilters(parsed.services);

      setState(() {
        if (resetPage) {
          services = filteredServices;
        } else {
          services.addAll(filteredServices);
        }
        totalResults = parsed.total;
        isLoading = false;
        isLoadingMore = false;
        hasMoreData = filteredServices.length >= _pageSize;
        if (!resetPage) currentPage++;
      });
    } catch (e) {
      print('Ошибка загрузки услуг: $e');
      setState(() {
        if (resetPage) services = [];
        isLoading = false;
        isLoadingMore = false;
        hasMoreData = false;
      });
    }
  }

  Map<String, dynamic> _buildQueryParams() {
    return {
      'page': currentPage.toString(),
      'limit': _pageSize.toString(),
      'categoryId': widget.category.id,
      if (searchQuery.isNotEmpty) 'search': searchQuery,
      if (selectedSubcategoryId != null) 'subcategoryId': selectedSubcategoryId,
      if (selectedCityId != null) 'cityId': selectedCityId,
      if (maxPrice < 100000) 'price': maxPrice.toString(),
    };
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

  Future<void> _loadMoreServices() async {
    if (isLoadingMore || !hasMoreData) return;
    currentPage++;
    await _loadServices(resetPage: false);
  }

  void _onSearchChanged(String query) {
    setState(() => searchQuery = query);
    _loadServices();
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

  bool _hasActiveFilters() {
    return selectedSubcategoryId != null ||
        selectedCityId != null ||
        minPrice > 0 ||
        maxPrice < 100000 ||
        selectedRating != null;
  }

  void _resetFilters() {
    setState(() {
      selectedSubcategoryId = null;
      selectedCityId = null;
      minPrice = 0;
      maxPrice = 100000;
      selectedRating = null;
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        categories: [{'id': widget.category.id, 'name': widget.category.name}],
        subcategories: subcategories,
        cities: cities,
        selectedCategoryId: widget.category.id, // Fixed category
        selectedSubcategoryId: selectedSubcategoryId,
        selectedCityId: selectedCityId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        selectedRating: selectedRating,
        onCategoryChanged: (_) {}, // Category is fixed, no change allowed
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
          _loadServices();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
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
          ServicesSearchBar(
            onSearchChanged: _onSearchChanged,
            totalResults: totalResults,
          ),
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D5F),
              ),
            )
                : services.isEmpty
                ? _buildEmptyState()
                : ServicesGrid(
              services: services,
              favoriteServices: favoriteServices,
              isLoadingMore: isLoadingMore,
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