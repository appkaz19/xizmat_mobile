import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasActiveFilters;
  final Function(String) onSearch;
  final VoidCallback onFilterTap;
  final VoidCallback onBack;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasActiveFilters,
    required this.onSearch,
    required this.onFilterTap,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
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
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: 'Поиск специалистов...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: onSearch,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: hasActiveFilters ? const Color(0xFF2E7D5F) : Colors.grey,
            ),
            onPressed: onFilterTap,
          ),
        ],
      ),
    );
  }
}