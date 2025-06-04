import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api/service.dart';
import '../../screens/search/universal_search_screen.dart';
import '../utils/city_autocomplete.dart';

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

class PriceFilterSection extends StatefulWidget {
  final int maxPrice;
  final Function(int) onPriceChanged;

  const PriceFilterSection({
    super.key,
    required this.maxPrice,
    required this.onPriceChanged,
  });

  @override
  State<PriceFilterSection> createState() => _PriceFilterSectionState();
}

class _PriceFilterSectionState extends State<PriceFilterSection> {
  late TextEditingController _controller;
  late int _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.maxPrice;
    _controller = TextEditingController(text: _formatPrice(widget.maxPrice));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    if (price == 0) return '';
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    );
  }

  int _parsePrice(String text) {
    return int.tryParse(text.replaceAll(' ', '')) ?? 0;
  }

  void _updatePrice(int newPrice) {
    setState(() {
      _sliderValue = newPrice;
      _controller.text = _formatPrice(newPrice);
    });
    widget.onPriceChanged(newPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FilterSectionTitle('Максимальная цена'),
        const SizedBox(height: 12),

        // Поле ввода цены
        TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'До',
            border: OutlineInputBorder(),
            suffixText: '₸',
            hintText: 'Введите максимальную цену',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _ThousandsSeparatorInputFormatter(),
          ],
          onChanged: (value) {
            final price = _parsePrice(value);
            if (price <= 10000000) { // Ограничиваем максимум
              setState(() {
                _sliderValue = price;
              });
              widget.onPriceChanged(price);
            }
          },
        ),

        const SizedBox(height: 16),

        // Слайдер для удобства
        Column(
          children: [
            Slider(
              value: _sliderValue.toDouble(),
              min: 0,
              max: 2000000, // 2 млн тенге
              divisions: 100,
              activeColor: const Color(0xFF2E7D5F),
              label: _sliderValue == 0 ? 'Любая цена' : '${_formatPrice(_sliderValue)} ₸',
              onChanged: (value) {
                _updatePrice(value.toInt());
              },
            ),

            // Подписи под слайдером
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0 ₸',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '2 000 000 ₸',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),

        // Быстрые кнопки
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickPriceChip('Любая', 0),
            _buildQuickPriceChip('50 000', 50000),
            _buildQuickPriceChip('100 000', 100000),
            _buildQuickPriceChip('200 000', 200000),
            _buildQuickPriceChip('500 000', 500000),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPriceChip(String label, int price) {
    final isSelected = _sliderValue == price;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _updatePrice(price);
        }
      },
      selectedColor: const Color(0xFF2E7D5F).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2E7D5F),
    );
  }
}

// Форматтер для добавления пробелов в числа
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll(' ', ''));
    if (number == null) {
      return oldValue;
    }

    final formattedText = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    );

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// Остальные виджеты остаются без изменений...
class FilterHeader extends StatelessWidget {
  final VoidCallback onClose;

  const FilterHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Фильтр',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class ServicesFilterSection extends StatelessWidget {
  final List<Map<String, String>> categories;
  final List<Map<String, String>> subcategories;
  final String? selectedCategoryId;
  final String? selectedSubcategoryId;
  final bool allowCategoryChange;
  final Function(String?) onCategoryChanged;
  final Function(String?) onSubcategoryChanged;

  const ServicesFilterSection({
    super.key,
    required this.categories,
    required this.subcategories,
    required this.selectedCategoryId,
    required this.selectedSubcategoryId,
    required this.allowCategoryChange,
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FilterSectionTitle('Услуги'),
        const SizedBox(height: 12),

        if (allowCategoryChange)
          CategoryDropdown(
            categories: categories,
            selectedCategoryId: selectedCategoryId,
            onChanged: onCategoryChanged,
          ),

        if (allowCategoryChange) const SizedBox(height: 12),

        if (subcategories.isNotEmpty)
          SubcategoryDropdown(
            subcategories: subcategories,
            selectedSubcategoryId: selectedSubcategoryId,
            onChanged: onSubcategoryChanged,
          ),
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
        const FilterSectionTitle('Местоположение'),
        const SizedBox(height: 12),
        CityAutocomplete(
          cities: cities,
          selectedCityId: selectedCityId,
          onCityChanged: onCityChanged,
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
        const FilterSectionTitle('Рейтинг'),
        const SizedBox(height: 12),
        RatingChips(
          selectedRating: selectedRating,
          onRatingChanged: onRatingChanged,
        ),
      ],
    );
  }
}

class FilterSectionTitle extends StatelessWidget {
  final String title;
  const FilterSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}

class CategoryDropdown extends StatelessWidget {
  final List<Map<String, String>> categories;
  final String? selectedCategoryId;
  final Function(String?) onChanged;

  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Категория',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('Все категории')),
        ...categories.map((category) => DropdownMenuItem<String>(
          value: category['id'],
          child: Text(category['name'] ?? ''),
        )),
      ],
      onChanged: onChanged,
    );
  }
}

class SubcategoryDropdown extends StatelessWidget {
  final List<Map<String, String>> subcategories;
  final String? selectedSubcategoryId;
  final Function(String?) onChanged;

  const SubcategoryDropdown({
    super.key,
    required this.subcategories,
    required this.selectedSubcategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedSubcategoryId,
      decoration: const InputDecoration(
        labelText: 'Подкатегория',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('Все подкатегории')),
        ...subcategories.map((subcategory) => DropdownMenuItem<String>(
          value: subcategory['id'],
          child: Text(subcategory['name'] ?? ''),
        )),
      ],
      onChanged: onChanged,
    );
  }
}

class RatingChips extends StatelessWidget {
  final int? selectedRating;
  final Function(int?) onRatingChanged;

  const RatingChips({
    super.key,
    required this.selectedRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildRatingChip('Все', null),
        _buildRatingChip('5★', 5),
        _buildRatingChip('4★', 4),
        _buildRatingChip('3★', 3),
      ],
    );
  }

  Widget _buildRatingChip(String label, int? rating) {
    final isSelected = selectedRating == rating;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        final newRating = selected ? rating : null;
        onRatingChanged(newRating);
      },
      selectedColor: const Color(0xFF2E7D5F).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2E7D5F),
    );
  }
}

class FilterBottomButtons extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onApply;

  const FilterBottomButtons({
    super.key,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReset,
              child: const Text('Сбросить'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D5F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Применить'),
            ),
          ),
        ],
      ),
    );
  }
}