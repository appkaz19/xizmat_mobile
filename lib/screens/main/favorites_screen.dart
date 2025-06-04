import 'package:flutter/material.dart';
import '../../utils/favorites_utils.dart';
import '../search/universal_item_card.dart';
import '../search/universal_search_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data state
  List<Map<String, dynamic>> favoriteServices = [];
  List<Map<String, dynamic>> favoriteJobs = [];

  // UI state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);

    try {
      // Загружаем избранные услуги и объявления
      final services = await FavoritesUtils.getAllFavoriteServices();
      final jobs = await FavoritesUtils.getAllFavoriteJobs();

      setState(() {
        favoriteServices = services;
        favoriteJobs = jobs;
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки избранного: $e');
      setState(() => isLoading = false);
    }
  }

  void _toggleFavorite(String itemId, bool isService) {
    setState(() {
      if (isService) {
        favoriteServices.removeWhere((s) => s['id'].toString() == itemId);
        FavoritesUtils.toggleServiceFavorite(itemId);
      } else {
        favoriteJobs.removeWhere((j) => j['id'].toString() == itemId);
        FavoritesUtils.toggleJobFavorite(itemId);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            isService
                ? 'Услуга удалена из избранного'
                : 'Объявление удалено из избранного'
        ),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () {
            // Вернуть в избранное
            if (isService) {
              FavoritesUtils.toggleServiceFavorite(itemId);
            } else {
              FavoritesUtils.toggleJobFavorite(itemId);
            }
            _loadFavorites(); // Перезагрузить список
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: favoriteServices.isNotEmpty
                  ? Badge(
                label: Text('${favoriteServices.length}'),
                child: const Icon(Icons.build),
              )
                  : const Icon(Icons.build),
            ),
            Tab(
              icon: favoriteJobs.isNotEmpty
                  ? Badge(
                label: Text('${favoriteJobs.length}'),
                child: const Icon(Icons.work),
              )
                  : const Icon(Icons.work),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D5F)),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesList(favoriteServices, true),
          _buildFavoritesList(favoriteJobs, false),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<Map<String, dynamic>> items, bool isServices) {
    if (items.isEmpty) {
      return _buildEmptyState(isServices);
    }

    return RefreshIndicator(
      color: const Color(0xFF2E7D5F),
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final itemId = item['id'].toString();

          return UniversalItemCard(
            item: item,
            type: isServices ? ItemType.SERVICE : ItemType.JOB,
            onFavoriteChanged: (id) => _toggleFavorite(id, isServices),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isServices) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isServices ? Icons.favorite_border : Icons.work_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isServices ? 'Нет избранных услуг' : 'Нет избранных объявлений',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isServices
                ? 'Добавьте услуги в избранное для быстрого доступа'
                : 'Добавьте объявления в избранное для быстрого доступа',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UniversalSearchScreen(
                    type: isServices ? SearchType.SERVICES : SearchType.JOBS,
                    title: isServices ? 'Поиск специалистов' : 'Доска объявлений',
                  ),
                ),
              );
            },
            icon: Icon(
              isServices ? Icons.search : Icons.work_history,
              color: const Color(0xFF2E7D5F),
            ),
            label: Text(
              isServices ? 'Найти услуги' : 'Найти объявления',
              style: const TextStyle(color: Color(0xFF2E7D5F)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2E7D5F)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}