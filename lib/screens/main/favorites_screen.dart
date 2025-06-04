import 'package:flutter/material.dart';
import '../../services/api/service.dart';
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
              text: 'Услуги',
              icon: const Icon(Icons.build),
              child: favoriteServices.isNotEmpty
                  ? Badge(
                label: Text('${favoriteServices.length}'),
                child: const Icon(Icons.build),
              )
                  : const Icon(Icons.build),
            ),
            Tab(
              text: 'Объявления',
              icon: const Icon(Icons.work),
              child: favoriteJobs.isNotEmpty
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

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: isServices
                ? ServiceCard(
              service: item,
            )
                : _buildJobCard(item),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final jobId = job['id'].toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to job detail
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (context) => JobDetailScreen(jobId: jobId),
          // ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange[100],
                      image: job['image'] != null
                          ? DecorationImage(
                        image: NetworkImage(job['image']),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: job['image'] == null
                        ? Icon(
                      Icons.work_outline,
                      color: Colors.orange[400],
                      size: 32,
                    )
                        : null,
                  ),

                  const SizedBox(width: 12),

                  // Job Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['title'] ?? 'Без названия',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          job['author'] ?? 'Неизвестно',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                job['address'] ?? 'Адрес не указан',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Favorite button
                  IconButton(
                    onPressed: () => _toggleFavorite(jobId, false),
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Price
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'до ${_formatPrice(job['price']?.toString() ?? '0')} тенге',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
        ),
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

  String _formatPrice(String price) {
    final number = int.tryParse(price) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    );
  }
}