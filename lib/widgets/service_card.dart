import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = service['title'] ?? 'Без названия';
    final price = service['price']?.toString() ?? '0';
    final imageUrl = service['image'];
    final author = service['author'] ?? 'Аноним';
    final rating = service['rating'];
    final reviewsCount = service['reviewsCount'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceImage(imageUrl: imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: ServiceDetails(
                author: author,
                title: title,
                price: price,
                rating: rating,
                reviewsCount: reviewsCount,
              ),
            ),
            FavoriteButton(isFavorite: isFavorite, onTap: onFavoriteTap),
          ],
        ),
      ),
    );
  }
}

class ServiceImage extends StatelessWidget {
  final String? imageUrl;

  const ServiceImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null
            ? Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Ошибка загрузки изображения: $error, URL: $imageUrl');
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image, color: Colors.grey),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        )
            : Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image, color: Colors.grey),
        ),
      ),
    );
  }
}

class ServiceDetails extends StatelessWidget {
  final String author;
  final String title;
  final String price;
  final dynamic rating;
  final int reviewsCount;

  const ServiceDetails({
    super.key,
    required this.author,
    required this.title,
    required this.price,
    required this.rating,
    required this.reviewsCount,
  });

  @override
  Widget build(BuildContext context) {
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
          'от $price тенге',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        RatingWidget(rating: rating, reviewsCount: reviewsCount),
      ],
    );
  }
}

class RatingWidget extends StatelessWidget {
  final dynamic rating;
  final int reviewsCount;

  const RatingWidget({
    super.key,
    required this.rating,
    required this.reviewsCount,
  });

  @override
  Widget build(BuildContext context) {
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

  String _getReviewEnding(int count) {
    if (count == 1) return '';
    if (count > 1 && count < 5) return 'а';
    return 'ов';
  }
}

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? Colors.amber : Colors.grey,
        size: 24,
      ),
      onPressed: onTap,
    );
  }
}