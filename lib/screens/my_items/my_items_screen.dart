import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorites_provider.dart';
import '../../services/api/service.dart';
import '../jobs/add_job_screen.dart';
import '../search/universal_item_card.dart';
import '../services/add_service_screen.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data state
  List<Map<String, dynamic>> myServices = [];
  List<Map<String, dynamic>> myJobs = [];

  // Loading state
  bool isLoadingServices = false;
  bool isLoadingJobs = false;

  // Stats
  int servicesCount = 0;
  int jobsCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Инициализируем FavoritesProvider
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    if (!favoritesProvider.isInitialized) {
      await favoritesProvider.initialize();
    }

    // Загружаем данные параллельно
    await Future.wait([
      _loadMyServices(),
      _loadMyJobs(),
    ]);
  }

  Future<void> _loadMyServices() async {
    setState(() => isLoadingServices = true);

    try {
      final response = await ApiService.service.getMyServices();
      print('Мои услуги ответ: $response');

      List<Map<String, dynamic>> services = [];
      int total = 0;

      if (response is Map<String, dynamic>) {
        final servicesList = response['services'] as List<dynamic>?;
        services = servicesList?.map<Map<String, dynamic>>((item) {
          return item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
        }).toList() ?? [];

        total = response['total'] is int ? response['total'] :
        int.tryParse(response['total']?.toString() ?? '0') ?? 0;
      } else if (response is List<dynamic>) {
        services = response.map<Map<String, dynamic>>((item) {
          return item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
        }).toList();
        total = services.length;
      }

      setState(() {
        myServices = services;
        servicesCount = total;
        isLoadingServices = false;
      });

      print('Загружено услуг: ${services.length}, всего: $total');
    } catch (e) {
      print('Ошибка загрузки моих услуг: $e');
      setState(() {
        myServices = [];
        servicesCount = 0;
        isLoadingServices = false;
      });
    }
  }

  Future<void> _loadMyJobs() async {
    setState(() => isLoadingJobs = true);

    try {
      final response = await ApiService.job.getMyJobs();
      print('Мои объявления ответ: $response');

      List<Map<String, dynamic>> jobs = [];
      int total = 0;

      if (response is Map<String, dynamic>) {
        final jobsList = response['jobs'] as List<dynamic>?;
        jobs = jobsList?.map<Map<String, dynamic>>((item) {
          return item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
        }).toList() ?? [];

        total = response['total'] is int ? response['total'] :
        int.tryParse(response['total']?.toString() ?? '0') ?? 0;
      } else if (response is List<dynamic>) {
        jobs = response.map<Map<String, dynamic>>((item) {
          return item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
        }).toList();
        total = jobs.length;
      }

      setState(() {
        myJobs = jobs;
        jobsCount = total;
        isLoadingJobs = false;
      });

      print('Загружено объявлений: ${jobs.length}, всего: $total');
    } catch (e) {
      print('Ошибка загрузки моих объявлений: $e');
      setState(() {
        myJobs = [];
        jobsCount = 0;
        isLoadingJobs = false;
      });
    }
  }

  void _toggleFavorite(String itemId, bool isService) async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);

    if (isService) {
      await favoritesProvider.toggleServiceFavorite(itemId);
    } else {
      await favoritesProvider.toggleJobFavorite(itemId);
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadMyServices(),
      _loadMyJobs(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои публикации'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D5F),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E7D5F),
          tabs: [
            Tab(
              text: 'Услуги${servicesCount > 0 ? ' ($servicesCount)' : ''}',
            ),
            Tab(
              text: 'Объявления${jobsCount > 0 ? ' ($jobsCount)' : ''}',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF2E7D5F),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildServicesTab(),
            _buildJobsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    if (isLoadingServices) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D5F)),
      );
    }

    if (myServices.isEmpty) {
      return _buildEmptyState(
        icon: Icons.build,
        title: 'У вас пока нет услуг',
        subtitle: 'Добавьте свою первую услугу и начните получать заказы',
        buttonText: 'Добавить услугу',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddServiceScreen(),
            ),
          );

          // Обновляем список если услуга была добавлена
          if (result == true) {
            _loadMyServices();
          }
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: myServices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = myServices[index];
        return UniversalItemCard(
          item: service,
          type: ItemType.SERVICE,
          onFavoriteChanged: (itemId) => _toggleFavorite(itemId, true),
        );
      },
    );
  }

  Widget _buildJobsTab() {
    if (isLoadingJobs) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D5F)),
      );
    }

    if (myJobs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.work_outline,
        title: 'У вас пока нет объявлений',
        subtitle: 'Создайте первое объявление и найдите нужных специалистов',
        buttonText: 'Создать объявление',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddJobScreen(),
            ),
          );

          // Обновляем список если объявление было добавлено
          if (result == true) {
            _loadMyJobs();
          }
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: myJobs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final job = myJobs[index];
        return UniversalItemCard(
          item: job,
          type: ItemType.JOB,
          onFavoriteChanged: (itemId) => _toggleFavorite(itemId, false),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D5F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}