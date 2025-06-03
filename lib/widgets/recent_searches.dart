import 'package:flutter/material.dart';

class RecentSearches extends StatelessWidget {
  final List<String> searches;
  final Function(String) onSearchTap;
  final Function(int) onRemoveSearch;
  final VoidCallback onClearAll;

  const RecentSearches({
    super.key,
    required this.searches,
    required this.onSearchTap,
    required this.onRemoveSearch,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const EmptySearchHistory();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchHistoryHeader(onClearAll: onClearAll),
        Expanded(
          child: SearchHistoryList(
            searches: searches,
            onSearchTap: onSearchTap,
            onRemoveSearch: onRemoveSearch,
          ),
        ),
      ],
    );
  }
}

class EmptySearchHistory extends StatelessWidget {
  const EmptySearchHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'История поиска пуста',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ваши недавние поиски будут отображаться здесь',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SearchHistoryHeader extends StatelessWidget {
  final VoidCallback onClearAll;

  const SearchHistoryHeader({
    super.key,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Недавние',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => _showClearDialog(context, onClearAll),
            child: const Text('Очистить все'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, VoidCallback onClearAll) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить историю'),
        content: const Text('Удалить всю историю поиска?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onClearAll();
            },
            child: const Text(
              'Очистить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchHistoryList extends StatelessWidget {
  final List<String> searches;
  final Function(String) onSearchTap;
  final Function(int) onRemoveSearch;

  const SearchHistoryList({
    super.key,
    required this.searches,
    required this.onSearchTap,
    required this.onRemoveSearch,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: searches.length,
      itemBuilder: (context, index) {
        return SearchHistoryItem(
          searchText: searches[index],
          onTap: () => onSearchTap(searches[index]),
          onRemove: () => onRemoveSearch(index),
        );
      },
    );
  }
}

class SearchHistoryItem extends StatelessWidget {
  final String searchText;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const SearchHistoryItem({
    super.key,
    required this.searchText,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(searchText),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey),
        onPressed: onRemove,
      ),
      onTap: onTap,
    );
  }
}