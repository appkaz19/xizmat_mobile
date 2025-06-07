import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/favorites_provider.dart';
import '../../services/api/service.dart';
import '../../utils/app_theme.dart';
import '../../utils/favorites_utils.dart';
import '../../widgets/service_media_carousel.dart';
import '../../widgets/media_grid_preview.dart';
import '../../widgets/full_gallery_modal.dart';
import '../chat/conversation_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;

  const JobDetailScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Map<String, dynamic>? jobData;
  bool isLoading = true;
  bool showFullDescription = false;
  bool isContactUnlocked = false;
  Map<String, dynamic>? contactInfo;

  @override
  void initState() {
    super.initState();
    _initializeFavorites();
    _loadJobData();
    _checkContactStatus();
  }

  Future<void> _initializeFavorites() async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    if (!favoritesProvider.isInitialized) {
      await favoritesProvider.initialize();
    }
  }

  Future<void> _loadJobData() async {
    setState(() => isLoading = true);

    try {
      final data = await ApiService.job.getJobById(widget.jobId);
      setState(() {
        jobData = data;
        isLoading = false;
        // Check if contact is already unlocked from API response
        isContactUnlocked = data?['contactUnlocked'] == true;
        if (isContactUnlocked) {
          contactInfo = data?['contact'];
        }
      });

      // ДОБАВИЛИ: отладочный вывод для понимания структуры данных
      print('=== JOB DATA DEBUG ===');
      print('Full jobData: $jobData');
      print('City data: ${jobData?['city']}');
      print('Region data: ${jobData?['region']}');
      print('Address: ${jobData?['address']}');
      print('=====================');
    } catch (e) {
      print('Ошибка загрузки объявления: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkContactStatus() async {
    try {
      final purchasedContacts = await ApiService.purchased.getMyPurchasedContacts();
      final hasPurchased = purchasedContacts.any((contact) =>
      contact['jobId'] == widget.jobId
      );

      if (hasPurchased) {
        setState(() {
          isContactUnlocked = true;
          final purchasedContact = purchasedContacts.firstWhere(
                  (contact) => contact['jobId'] == widget.jobId
          );
          contactInfo = purchasedContact['job']?['user'];
        });
      }
    } catch (e) {
      print('Ошибка проверки купленных контактов: $e');
    }
  }

  Future<void> _buyContact() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      final result = await ApiService.job.buyEmployerContact(widget.jobId);

      Navigator.of(context).pop();

      if (result != null) {
        setState(() {
          isContactUnlocked = true;
          contactInfo = result['contact'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Контакт успешно разблокирован!'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        throw Exception('Не удалось разблокировать контакт');
      }
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startChat() async {
    final user = jobData!['user'] as Map<String, dynamic>? ?? {};
    final targetUserId = user['id']?.toString();

    if (targetUserId == null || targetUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Невозможно начать чат: пользователь не найден'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      // Создаем или получаем существующий чат
      final chatData = await ApiService.chat.startChat(targetUserId);

      Navigator.of(context).pop(); // Закрываем диалог загрузки

      if (chatData != null) {
        // Переходим в чат
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              chatId: chatData['id'].toString(),
              otherUserId: targetUserId,
              userName: user['fullName'] ?? user['phone'] ?? 'Работодатель',
              avatarUrl: user['avatarUrl'],
            ),
          ),
        );
      } else {
        throw Exception('Не удалось создать чат');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Закрываем диалог загрузки

      print('Ошибка создания чата: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка создания чата: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось совершить звонок'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatPrice(String price) {
    final number = int.tryParse(price) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    );
  }

  // ИСПРАВИЛИ: методы получения города и региона
  String _getCityName() {
    // Проверяем разные возможные структуры данных
    final city = jobData?['city'];
    if (city == null) return 'Город не указан';

    // Если city - это объект с переводами
    if (city is Map<String, dynamic>) {
      // Проверяем translations
      final translations = city['translations'] as List<dynamic>?;
      if (translations != null && translations.isNotEmpty) {
        final translation = translations.first as Map<String, dynamic>?;
        final name = translation?['name'];
        if (name != null && name.toString().isNotEmpty) {
          return name.toString();
        }
      }

      // Проверяем прямое поле name
      final name = city['name'];
      if (name != null && name.toString().isNotEmpty) {
        return name.toString();
      }
    }

    // Если city - это строка
    if (city is String && city.isNotEmpty) {
      return city;
    }

    return 'Город не указан';
  }

  String _getRegionName() {
    // Проверяем разные возможные структуры данных
    final region = jobData?['region'];
    if (region == null) return '';

    // Если region - это объект с переводами
    if (region is Map<String, dynamic>) {
      // Проверяем translations
      final translations = region['translations'] as List<dynamic>?;
      if (translations != null && translations.isNotEmpty) {
        final translation = translations.first as Map<String, dynamic>?;
        final name = translation?['name'];
        if (name != null && name.toString().isNotEmpty) {
          return name.toString();
        }
      }

      // Проверяем прямое поле name
      final name = region['name'];
      if (name != null && name.toString().isNotEmpty) {
        return name.toString();
      }
    }

    // Если region - это строка
    if (region is String && region.isNotEmpty) {
      return region;
    }

    return '';
  }

  String _getAddress() {
    final address = jobData?['address'];
    if (address == null || address.toString().trim().isEmpty) {
      return 'Адрес не указан';
    }
    return address.toString();
  }

  // ДОБАВИЛИ: метод для построения строки местоположения
  String _buildLocationString() {
    final cityName = _getCityName();
    final regionName = _getRegionName();

    if (cityName == 'Город не указан' && regionName.isEmpty) {
      return 'Местоположение не указано';
    }

    if (regionName.isEmpty) {
      return cityName;
    }

    if (cityName == 'Город не указан') {
      return regionName;
    }

    return '$cityName, $regionName';
  }

  List<String> _getAllImages() {
    final images = jobData?['images'] as List<dynamic>? ?? [];
    return images.map((image) => image.toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (jobData == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Объявление не найдено'),
        ),
      );
    }

    final allImages = _getAllImages();
    final user = jobData!['user'] as Map<String, dynamic>? ?? {};
    final employerName = user['fullName'] ?? 'Неизвестно';
    final title = jobData!['title'] ?? 'Без названия';
    final description = jobData!['description'] ?? '';
    final price = jobData!['price']?.toString() ?? '0';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Media Carousel
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: allImages.isNotEmpty
                  ? ServiceMediaCarousel(images: allImages)
                  : _buildDefaultImage(),
            ),
            actions: [
              Consumer<FavoritesProvider>(
                builder: (context, favoritesProvider, child) {
                  final isFavorite = favoritesProvider.isJobFavorite(widget.jobId);
                  return IconButton(
                    onPressed: () async {
                      await favoritesProvider.toggleJobFavorite(widget.jobId);
                    },
                    icon: Icon(
                      Icons.star,
                      color: isFavorite ? Colors.amber : Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
            ],
          ),

          // Job Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Employer Info
                  Row(
                    children: [
                      Text(
                        employerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location - ИСПРАВИЛИ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Город и регион
                            Text(
                              _buildLocationString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Адрес
                            Text(
                              _getAddress(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Price
                  Text(
                    'до ${_formatPrice(price)} тенге',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // About Section
                  const Text(
                    'Описание работы',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildDescription(description),

                  const SizedBox(height: 32),

                  // Photos Section
                  if (allImages.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          allImages.length == 1 ? 'Фото' : 'Фото (${allImages.length})',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (allImages.length > 1)
                          TextButton(
                            onPressed: () {
                              _showFullGallery(allImages);
                            },
                            child: const Text(
                              'Посмотреть все',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    MediaGridPreview(
                      images: allImages,
                      onTap: (List<String> images) => _showFullGallery(images),
                    ),

                    const SizedBox(height: 32),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDescription(String description) {
    final lines = description.split('\n');
    final hasLongText = lines.length > 3 || description.length > 150;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          showFullDescription || !hasLongText
              ? (description.isNotEmpty ? description : 'Описание не указано')
              : '${description.substring(0, description.length > 150 ? 150 : description.length)}...',
          style: const TextStyle(
            color: AppColors.textPrimary,
            height: 1.5,
            fontSize: 16,
          ),
        ),
        if (hasLongText)
          TextButton(
            onPressed: () {
              setState(() {
                showFullDescription = !showFullDescription;
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(top: 8),
            ),
            child: Text(
              showFullDescription ? 'Свернуть' : 'Читать далее...',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  void _showFullGallery(List<String> images) {
    showDialog(
      context: context,
      builder: (context) => FullGalleryModal(images: images),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.8),
            Colors.red.withOpacity(0.8),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 60,
              color: Colors.white,
            ),
            SizedBox(height: 12),
            Text(
              'Фото не добавлены',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isContactUnlocked ? _buildContactButtons() : _buildBuyContactButton(),
    );
  }

  Widget _buildBuyContactButton() {
    return ElevatedButton(
      onPressed: _buyContact,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Посмотреть контакт (100 тенге)',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContactButtons() {
    // Берем данные из основного объекта, а не из contactInfo
    final user = jobData!['user'] as Map<String, dynamic>? ?? {};
    final phone = contactInfo?['phone'] ?? user['phone'] ?? '';
    final fullName = contactInfo?['fullName'] ?? user['fullName'] ?? 'Неизвестно';

    // Проверяем разрешенные способы связи
    final allowChat = jobData?['allowChat'] == true;
    final allowPhone = jobData?['allowPhone'] == true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Показываем кнопки в зависимости от разрешений
        if (allowChat && allowPhone) ...[
          // Обе кнопки
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _startChat(),
                  icon: const Icon(Icons.message, size: 20),
                  label: const Text('Написать'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: phone.isNotEmpty ? () => _makePhoneCall(phone) : null,
                  icon: const Icon(Icons.phone, size: 20),
                  label: const Text('Позвонить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else if (allowChat) ...[
          // Только чат
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _startChat(),
              icon: const Icon(Icons.message, size: 20),
              label: const Text('Написать'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ] else if (allowPhone) ...[
          // Только звонок
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: phone.isNotEmpty ? () => _makePhoneCall(phone) : null,
              icon: const Icon(Icons.phone, size: 20),
              label: const Text('Позвонить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ] else ...[
          // Никакой способ связи не разрешен
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Способы связи не указаны',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }
}