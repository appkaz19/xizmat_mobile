import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "filter_sections.dart";
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
