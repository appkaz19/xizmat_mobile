import 'package:flutter/material.dart';
import 'service_card.dart';

class SearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final int totalResults;
  final bool isLoadingMore;
  final Set<String> favoriteServices;
  final Function(String) onFavoriteTap;
  final VoidCallback onLoadMore;

  const SearchResults({
    super.key,
    required this.results,
    required this.totalResults,
    required this.isLoadingMore,
    required this.favoriteServices,
    required this.onFavoriteTap,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Результаты поиска ($totalResults найдено)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                onLoadMore();
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == results.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D5F),
                      ),
                    ),
                  );
                }
                return ServiceCard(
                  service: results[index],
                  isFavorite: favoriteServices.contains(results[index]['id'].toString()),
                  onFavoriteTap: () => onFavoriteTap(results[index]['id'].toString()),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}