import "package:flutter/material.dart";
import "../../services/api/service.dart";
import "../../screens/search/universal_search_screen.dart";
import "price_filter_section.dart";
import "filter_sections.dart";
class UniversalFilterBottomSheet extends StatefulWidget {
  final SearchType type;
  final List<Map<String, String>> categories;
  final List<Map<String, String>> subcategories;
  final List<Map<String, dynamic>> cities;
  final String? selectedCategoryId;
  final String? selectedSubcategoryId;
  final String? selectedCityId;
  final int maxPrice; // Изменили на int
  final int? selectedRating;
  final bool allowCategoryChange;
  final Function(String?) onCategoryChanged;
  final Function(String?) onSubcategoryChanged;
  final Function(String?) onCityChanged;
  final Function(int) onPriceChanged; // Изменили сигнатуру
  final Function(int?) onRatingChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const UniversalFilterBottomSheet({
    super.key,
    required this.type,
    required this.categories,
    required this.subcategories,
    required this.cities,
    required this.selectedCategoryId,
    required this.selectedSubcategoryId,
    required this.selectedCityId,
    required this.maxPrice,
    required this.selectedRating,
    required this.allowCategoryChange,
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
    required this.onCityChanged,
    required this.onPriceChanged,
    required this.onRatingChanged,
    required this.onReset,
    required this.onApply,
  });

  @override
  State<UniversalFilterBottomSheet> createState() => _UniversalFilterBottomSheetState();
}

class _UniversalFilterBottomSheetState extends State<UniversalFilterBottomSheet> {
  late String? _selectedCategoryId;
  late String? _selectedSubcategoryId;
  late String? _selectedCityId;
  late int _maxPrice;
  late int? _selectedRating;
  late List<Map<String, String>> _localSubcategories;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() {
    _selectedCategoryId = widget.selectedCategoryId;
    _selectedSubcategoryId = widget.selectedSubcategoryId;
    _selectedCityId = widget.selectedCityId;
    _maxPrice = widget.maxPrice;
    _selectedRating = widget.selectedRating;
    _localSubcategories = List.from(widget.subcategories);
  }

  String get _itemTypeName => widget.type == SearchType.SERVICES ? 'Услуги' : 'Объявления';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Поднимает виджет при клавиатуре
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            FilterHeader(onClose: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                child: FilterContent(
                  type: widget.type,
                  itemTypeName: _itemTypeName,
                  categories: widget.categories,
                  subcategories: _localSubcategories,
                  cities: widget.cities,
                  selectedCategoryId: _selectedCategoryId,
                  selectedSubcategoryId: _selectedSubcategoryId,
                  selectedCityId: _selectedCityId,
                  maxPrice: _maxPrice,
                  selectedRating: _selectedRating,
                  allowCategoryChange: widget.allowCategoryChange,
                  onCategoryChanged: _onCategoryChanged,
                  onSubcategoryChanged: _onSubcategoryChanged,
                  onCityChanged: _onCityChanged,
                  onPriceChanged: _onPriceChanged,
                  onRatingChanged: _onRatingChanged,
                ),
              ),
            ),
            FilterBottomButtons(
              onReset: _onReset,
              onApply: widget.onApply,
            ),
          ],
        ),
      ),
    );
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _selectedCategoryId = value;
      _selectedSubcategoryId = null;
      _localSubcategories.clear();
    });
    widget.onCategoryChanged(value);
    if (value != null) _loadSubcategories(value);
  }

  void _onSubcategoryChanged(String? value) {
    setState(() => _selectedSubcategoryId = value);
    widget.onSubcategoryChanged(value);
  }

  void _onCityChanged(String? value) {
    setState(() => _selectedCityId = value);
    widget.onCityChanged(value);
  }

  void _onPriceChanged(int maxPrice) {
    setState(() {
      _maxPrice = maxPrice;
    });
    widget.onPriceChanged(maxPrice);
  }

  void _onRatingChanged(int? value) {
    setState(() => _selectedRating = value);
    widget.onRatingChanged(value);
  }

  void _onReset() {
    setState(() {
      if (widget.allowCategoryChange) {
        _selectedCategoryId = null;
      }
      _selectedSubcategoryId = null;
      _selectedCityId = null;
      _maxPrice = 1000000; // Дефолтная максимальная цена
      _selectedRating = null;
      if (widget.allowCategoryChange) {
        _localSubcategories.clear();
      }
    });
    widget.onReset();
  }

  Future<void> _loadSubcategories(String categoryId) async {
    if (widget.type != SearchType.SERVICES) return;

    try {
      final subcategoriesData = await ApiService.subcategory.getSubcategoriesByCategory(categoryId);
      setState(() {
        _localSubcategories = subcategoriesData;
      });
    } catch (e) {
      print('Ошибка загрузки подкатегорий: $e');
    }
  }
}

// Остальные виджеты остаются такими же, кроме FilterContent и PriceFilterSection

class FilterContent extends StatelessWidget {
  final SearchType type;
  final String itemTypeName;
  final List<Map<String, String>> categories;
  final List<Map<String, String>> subcategories;
  final List<Map<String, dynamic>> cities;
  final String? selectedCategoryId;
  final String? selectedSubcategoryId;
  final String? selectedCityId;
  final int maxPrice; // Изменили тип
  final int? selectedRating;
  final bool allowCategoryChange;
  final Function(String?) onCategoryChanged;
  final Function(String?) onSubcategoryChanged;
  final Function(String?) onCityChanged;
  final Function(int) onPriceChanged; // Изменили сигнатуру
  final Function(int?) onRatingChanged;

  const FilterContent({
    super.key,
    required this.type,
    required this.itemTypeName,
    required this.categories,
    required this.subcategories,
    required this.cities,
    required this.selectedCategoryId,
    required this.selectedSubcategoryId,
    required this.selectedCityId,
    required this.maxPrice,
    required this.selectedRating,
    required this.allowCategoryChange,
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
    required this.onCityChanged,
    required this.onPriceChanged,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Показываем секцию категорий только для услуг
          if (type == SearchType.SERVICES) ...[
            ServicesFilterSection(
              categories: categories,
              subcategories: subcategories,
              selectedCategoryId: selectedCategoryId,
              selectedSubcategoryId: selectedSubcategoryId,
              allowCategoryChange: allowCategoryChange,
              onCategoryChanged: onCategoryChanged,
              onSubcategoryChanged: onSubcategoryChanged,
            ),
            const SizedBox(height: 24),
          ],

          LocationFilterSection(
            cities: cities,
            selectedCityId: selectedCityId,
            onCityChanged: onCityChanged,
          ),
          const SizedBox(height: 24),

          PriceFilterSection(
            maxPrice: maxPrice,
            onPriceChanged: onPriceChanged,
          ),

          // Рейтинг показываем только для услуг
          if (type == SearchType.SERVICES) ...[
            const SizedBox(height: 24),
            RatingFilterSection(
              selectedRating: selectedRating,
              onRatingChanged: onRatingChanged,
            ),
          ],
        ],
      ),
    );
  }
}

