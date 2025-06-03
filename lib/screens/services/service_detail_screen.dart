import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api/service.dart';
import '../../utils/app_theme.dart';
import '../../utils/video_manager.dart';
import '../../utils/favorites_utils.dart';
import '../../widgets/service_media_carousel.dart';
import '../../widgets/media_grid_preview.dart';
import '../../widgets/reviews_section.dart';
import '../../widgets/full_gallery_modal.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Map<String, dynamic>? serviceData;
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;
  bool showFullDescription = false;
  bool isContactUnlocked = false;
  Map<String, dynamic>? contactInfo;

  @override
  void initState() {
    super.initState();
    _loadServiceData();
    _loadReviews();
    _checkContactStatus();
  }

  Future<void> _loadServiceData() async {
    setState(() => isLoading = true);

    try {
      final data = await ApiService.service.getServiceById(widget.serviceId);
      setState(() {
        serviceData = data;
        isLoading = false;
        isContactUnlocked = data?['contactUnlocked'] == true;
        if (isContactUnlocked) {
          contactInfo = data?['contact'];
        }
      });
    } catch (e) {
      print('Ошибка загрузки сервиса: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviewsData = await ApiService.reviews.getReviews(widget.serviceId);
      setState(() {
        reviews = reviewsData;
      });
    } catch (e) {
      print('Ошибка загрузки отзывов: $e');
    }
  }

  Future<void> _checkContactStatus() async {
    try {
      final purchasedContacts = await ApiService.purchased.getMyPurchasedContacts();
      final hasPurchased = purchasedContacts.any((contact) =>
      contact['serviceId'] == widget.serviceId
      );

      if (hasPurchased) {
        setState(() {
          isContactUnlocked = true;
          final purchasedContact = purchasedContacts.firstWhere(
                  (contact) => contact['serviceId'] == widget.serviceId
          );
          contactInfo = purchasedContact['service']?['user'];
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

      final result = await ApiService.purchased.buyServiceContact(widget.serviceId);

      Navigator.of(context).pop();

      if (result != null) {
        setState(() {
          isContactUnlocked = true;
          contactInfo = result['user'];
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

  String _getCategoryName() {
    if (serviceData?['category']?['CategoryTranslation'] == null) return '';
    final translations = serviceData!['category']['CategoryTranslation'] as List;
    final ruTranslation = translations.firstWhere(
          (t) => t['language'] == 'ru',
      orElse: () => translations.isNotEmpty ? translations.first : null,
    );
    return ruTranslation?['name'] ?? '';
  }

  double _getAverageRating() {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<double>(0.0, (sum, review) => sum + (review['rating'] ?? 0));
    return sum / reviews.length;
  }

  List<dynamic> _getAllMedia() {
    final images = serviceData?['images'] as List<dynamic>? ?? [];
    final videos = serviceData?['videos'] as List<dynamic>? ?? [];

    final List<dynamic> allMedia = [];

    for (final image in images) {
      allMedia.add({'type': 'image', 'url': image});
    }

    for (final video in videos) {
      allMedia.add({'type': 'video', 'url': video});
    }

    return allMedia;
  }

  String _getReviewEnding(int count) {
    if (count == 1) return '';
    if (count > 1 && count < 5) return 'а';
    return 'ов';
  }

  @override
  void dispose() {
    // Очищаем видео ресурсы при закрытии экрана
    VideoManager().dispose();
    super.dispose();
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

    if (serviceData == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Сервис не найден'),
        ),
      );
    }

    final allMedia = _getAllMedia();
    final user = serviceData!['user'] as Map<String, dynamic>? ?? {};
    final providerName = user['fullName'] ?? 'Неизвестно';
    final title = serviceData!['title'] ?? 'Без названия';
    final description = serviceData!['description'] ?? '';
    final price = serviceData!['price']?.toString() ?? '0';
    final address = serviceData!['address'] ?? 'Адрес не указан';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Media Carousel
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: allMedia.isNotEmpty
                  ? ServiceMediaCarousel(media: allMedia)
                  : _buildDefaultImage(),
            ),
            actions: [
              FavoritesUtils.buildServiceFavoriteIcon(
                context,
                widget.serviceId,
                inactiveColor: Colors.white,
              ),
            ],
          ),

          // Service Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Provider Info
                  Row(
                    children: [
                      Text(
                        providerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(
                        _getAverageRating().toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${reviews.length} отзыв${_getReviewEnding(reviews.length)})',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Category and Address
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          _getCategoryName(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Price
                  Text(
                    '${_formatPrice(price)} тенге',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // About Section
                  const Text(
                    'О сервисе',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildDescription(description),

                  const SizedBox(height: 32),

                  // Photos & Videos Section
                  if (allMedia.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Фото и видео',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _showFullGallery(allMedia);
                          },
                          child: const Text(
                            'Посмотреть все',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    MediaGridPreview(media: allMedia, onTap: _showFullGallery),

                    const SizedBox(height: 32),
                  ],

                  // Reviews Section
                  ReviewsSection(
                    reviews: reviews,
                    serviceId: widget.serviceId,
                    onReviewAdded: _loadReviews,
                  ),

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

  void _showFullGallery(List<dynamic> media) {
    showDialog(
      context: context,
      builder: (context) => FullGalleryModal(media: media),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.blue.withOpacity(0.8),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.build,
          size: 80,
          color: Colors.white,
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
    final phone = contactInfo?['phone'] ?? '';
    final fullName = contactInfo?['fullName'] ?? 'Исполнитель';

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

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Переход в чаты будет реализован позже')),
                  );
                },
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
      ],
    );
  }
}