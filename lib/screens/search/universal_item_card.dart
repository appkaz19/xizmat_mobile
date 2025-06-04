import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/services/service_detail_screen.dart';
import '../../screens/jobs/job_detail_screen.dart';
import '../../providers/favorites_provider.dart';

enum ItemType { SERVICE, JOB }

class UniversalItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final ItemType type;
  final Function(String)? onFavoriteChanged;

  const UniversalItemCard({
    super.key,
    required this.item,
    required this.type,
    this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final itemId = item['id']?.toString();
    final title = item['title'] ?? 'Без названия';
    final price = item['price']?.toString() ?? '0';
    final imageUrl = item['image'];
    final author = item['author'] ?? 'Аноним';
    final rating = item['rating'];
    final reviewsCount = item['reviewsCount'] ?? 0;
    final address = item['address'] ?? 'Адрес не указан';

    return GestureDetector(
      onTap: () {
        if (itemId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => type == ItemType.SERVICE
                  ? ServiceDetailScreen(serviceId: itemId)
                  : JobDetailScreen(jobId: itemId),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemImage(imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: _buildItemDetails(
                  author: author,
                  title: title,
                  price: price,
                  rating: rating,
                  reviewsCount: reviewsCount,
                  address: address,
                ),
              ),
              if (itemId != null)
                _buildFavoriteIcon(context, itemId)
              else
                const SizedBox(width: 48), // Заглушка если нет ID
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage(String? imageUrl) {
    final Color backgroundColor = type == ItemType.SERVICE
        ? Colors.blue[50]!
        : Colors.orange[50]!;
    final Color iconColor = type == ItemType.SERVICE
        ? Colors.blue[400]!
        : Colors.orange[400]!;
    final IconData icon = type == ItemType.SERVICE
        ? Icons.build
        : Icons.work_outline;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: backgroundColor,
              child: Icon(icon, color: iconColor, size: 32),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: backgroundColor,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        )
            : Container(
          color: backgroundColor,
          child: Icon(icon, color: iconColor, size: 32),
        ),
      ),
    );
  }

  Widget _buildItemDetails({
    required String author,
    required String title,
    required String price,
    required dynamic rating,
    required int reviewsCount,
    required String address,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          author,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          type == ItemType.SERVICE
              ? 'от $price тенге'
              : 'до $price тенге',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        if (type == ItemType.SERVICE)
          _buildRatingWidget(rating, reviewsCount)
        else
          _buildAddressWidget(address),
      ],
    );
  }

  Widget _buildRatingWidget(dynamic rating, int reviewsCount) {
    if (rating != null || reviewsCount > 0) {
      return Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            rating?.toString() ?? '0.0',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(
            '$reviewsCount отзыв${_getReviewEnding(reviewsCount)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      );
    }
    return Text(
      'Нет отзывов',
      style: TextStyle(color: Colors.grey[500], fontSize: 12),
    );
  }

  Widget _buildAddressWidget(String address) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            address,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteIcon(BuildContext context, String itemId) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = type == ItemType.SERVICE
            ? favoritesProvider.isServiceFavorite(itemId)
            : favoritesProvider.isJobFavorite(itemId);

        return GestureDetector(
          onTap: () async {
            // УБРАЛ ДУБЛИРУЮЩИЙ ВЫЗОВ toggleServiceFavorite/toggleJobFavorite
            // Теперь только вызываем callback
            onFavoriteChanged?.call(itemId);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.star,
              color: isFavorite ? Colors.amber : Colors.grey,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  String _getReviewEnding(int count) {
    if (count == 1) return '';
    if (count > 1 && count < 5) return 'а';
    return 'ов';
  }
}

// Wrapper для обратной совместимости
class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final Function(String)? onFavoriteChanged;

  const ServiceCard({
    super.key,
    required this.service,
    this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalItemCard(
      item: service,
      type: ItemType.SERVICE,
      onFavoriteChanged: onFavoriteChanged,
    );
  }
}

// Новая карточка для объявлений
class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final Function(String)? onFavoriteChanged;

  const JobCard({
    super.key,
    required this.job,
    this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalItemCard(
      item: job,
      type: ItemType.JOB,
      onFavoriteChanged: onFavoriteChanged,
    );
  }
}