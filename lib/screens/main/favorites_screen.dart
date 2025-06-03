import 'package:flutter/material.dart';
import '../../services/api/service.dart';
import '../../widgets/service_card.dart';

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
  Set<String> localFavorites = {}; // Локальное управление избранным

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
      // В будущем здесь будут вызовы:
      // final services = await ApiService.favorites.getFavoriteServices();
      // final jobs = await ApiService.favorites.getFavoriteJobs();

      // Пока заглушка
      setState(() {
        favoriteServices = [];
        favoriteJobs = [];
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки избранного: $e');
      setState(() => isLoading = false);
    }
  }

  void _toggleFavorite(String serviceId, bool isService) {
    setState(() {
      if (localFavorites.contains(serviceId)) {
        localFavorites.remove(serviceId);
        if (isService) {
          favoriteServices.removeWhere((s) => s['id'].toString() == serviceId);
        } else {
          favoriteJobs.removeWhere((j) => j['id'].toString() == serviceId);
        }
      } else {
        localFavorites.add(serviceId);
      }
    });

    // TODO: Вызвать API для добавления/удаления из избранного
    print('${localFavorites.contains(serviceId) ? 'Added to' : 'Removed from'} favorites: $serviceId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Услуги', icon: Icon(Icons.build)),
            Tab(text: 'Вакансии', icon: Icon(Icons.work)),
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

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ServiceCard(
              service: item,
              isFavorite: true, // Все элементы в избранном
              onFavoriteTap: () => _toggleFavorite(itemId, isServices),
            ),
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
            isServices ? 'Нет избранных услуг' : 'Нет избранных вакансий',
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
                : 'Добавьте вакансии в избранное для быстрого доступа',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // Переход к поиску
              Navigator.pop(context);
            },
            icon: Icon(
              isServices ? Icons.search : Icons.work_history,
              color: const Color(0xFF2E7D5F),
            ),
            label: Text(
              isServices ? 'Найти услуги' : 'Найти вакансии',
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