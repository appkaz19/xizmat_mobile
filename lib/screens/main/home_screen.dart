import 'package:flutter/material.dart';
import '../../widgets/search_bar_widget.dart';
import '../../services/api/service.dart';
import '../search/universal_search_screen.dart';
import '../services/add_service_screen.dart';
import '../jobs/add_job_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _walletData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Загружаем профиль и кошелек параллельно
      final profileFuture = ApiService.user.getProfile();
      final walletFuture = ApiService.wallet.getWallet();

      final results = await Future.wait([profileFuture, walletFuture]);

      if (mounted) {
        setState(() {
          _userProfile = results[0];
          _walletData = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Ошибка загрузки данных: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String get _displayName {
    if (_userProfile == null) return 'Пользователь';

    final fullName = _userProfile!['fullName'];
    final nickname = _userProfile!['nickname'];

    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    } else if (nickname != null && nickname.isNotEmpty) {
      return '@$nickname';
    } else {
      return 'Пользователь';
    }
  }

  String? get _avatarUrl {
    return _userProfile?['avatarUrl'];
  }

  String get _coinsDisplay {
    if (_isLoading) return 'Загружается...';
    if (_walletData == null) return 'Ошибка загрузки';

    final balance = _walletData!['balance'];
    if (balance == null) return '0 монет';

    // Форматируем число с разделителями
    final balanceInt = balance is int ? balance : int.tryParse(balance.toString()) ?? 0;
    return '${_formatNumber(balanceInt)} монет';
  }

  String _formatNumber(int number) {
    if (number < 1000) return number.toString();

    String numberStr = number.toString();
    String result = '';

    for (int i = 0; i < numberStr.length; i++) {
      if (i > 0 && (numberStr.length - i) % 3 == 0) {
        result += ' ';
      }
      result += numberStr[i];
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile info
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _avatarUrl != null
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: _avatarUrl == null
                        ? (_isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.person, size: 25))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Реальный баланс монет
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              _coinsDisplay,
                              style: TextStyle(
                                color: _isLoading ? Colors.grey : Colors.amber,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on_outlined),
                    onPressed: () {
                      // Show location
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // Show notifications
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Search Bar
              const SearchBarWidget(),

              const SizedBox(height: 24),

              // Quick Actions Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickActionCard(
                    'Найти специалиста',
                    Icons.search,
                    Colors.blue,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UniversalSearchScreen(
                            type: SearchType.SERVICES,
                            title: 'Поиск специалистов',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    'Добавить услугу',
                    Icons.add_box,
                    Colors.green,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddServiceScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    'Доска объявлений',
                    Icons.work_outline,
                    Colors.orange,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UniversalSearchScreen(
                            type: SearchType.JOBS,
                            title: 'Доска объявлений',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    'Создать объявление',
                    Icons.edit_note,
                    Colors.red,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddJobScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // AI Agent Card
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D5F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'AI Агенты',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Special Offers Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Спец. предложения',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Show all offers
                    },
                    child: const Text('Смотреть все'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Special Offer Card
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D5F), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '30%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Специальное\nпредложение!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Скидка на подписку для\nновых пользователей',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}