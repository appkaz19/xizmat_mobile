import 'package:flutter/material.dart';

class CityAutocomplete extends StatelessWidget {
  final List<Map<String, dynamic>> cities;
  final String? selectedCityId;
  final Function(String?) onCityChanged;

  const CityAutocomplete({
    super.key,
    required this.cities,
    required this.selectedCityId,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return cities;
        return cities.where((city) {
          final cityName = city['name']?.toLowerCase() ?? '';
          final regionName = city['region']?.toLowerCase() ?? '';
          final searchText = textEditingValue.text.toLowerCase();
          return cityName.contains(searchText) || regionName.contains(searchText);
        });
      },
      displayStringForOption: (city) => '${city['name']} (${city['region']})',
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (selectedCityId != null && controller.text.isEmpty) {
          final selectedCity = cities.firstWhere(
                (city) => city['id'] == selectedCityId,
            orElse: () => {},
          );
          if (selectedCity.isNotEmpty) {
            controller.text = '${selectedCity['name']} (${selectedCity['region']})';
          }
        }

        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Город',
            border: OutlineInputBorder(),
            hintText: 'Начните вводить название города...',
          ),
          onChanged: (value) {
            if (value.isEmpty) onCityChanged(null);
          },
        );
      },
      onSelected: (city) => onCityChanged(city['id']),
    );
  }
}