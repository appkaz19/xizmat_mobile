import 'package:flutter/material.dart';
import '../../../services/api/service.dart';
import '../../../utils/app_theme.dart';
import 'add_review_dialog.dart';

class ReviewsSection extends StatefulWidget {
  final List<Map<String, dynamic>> reviews;
  final String serviceId;
  final VoidCallback onReviewAdded;

  const ReviewsSection({
    super.key,
    required this.reviews,
    required this.serviceId,
    required this.onReviewAdded,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  String selectedFilter = 'All';

  double _getAverageRating() {
    if (widget.reviews.isEmpty) return 0.0;
    final sum = widget.reviews.fold<double>(0.0, (sum, review) => sum + (review['rating'] ?? 0));
    return sum / widget.reviews.length;
  }

  List<Map<String, dynamic>> _getFilteredReviews() {
    if (selectedFilter == 'All') return widget.reviews;
    final rating = int.tryParse(selectedFilter);
    if (rating == null) return widget.reviews;
    return widget.reviews.where((review) => review['rating'] == rating).toList();
  }

  String _getReviewEnding(int count) {
    if (count == 1) return '';
    if (count > 1 && count < 5) return 'а';
    return 'ов';
  }

  @override
  Widget build(BuildContext context) {
    final filteredReviews = _getFilteredReviews();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reviews Header
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Text(
              _getAverageRating().toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '(${widget.reviews.length} отзыв${_getReviewEnding(widget.reviews.length)})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                _showAddReviewDialog();
              },
              child: const Text(
                'Оставить отзыв',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Review Filters
        if (widget.reviews.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildReviewFilter('All'),
                const SizedBox(width: 8),
                _buildReviewFilter('5'),
                const SizedBox(width: 8),
                _buildReviewFilter('4'),
                const SizedBox(width: 8),
                _buildReviewFilter('3'),
                const SizedBox(width: 8),
                _buildReviewFilter('2'),
                const SizedBox(width: 8),
                _buildReviewFilter('1'),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],

        // Review Items
        if (filteredReviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Отзывов пока нет',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ...filteredReviews.take(3).map((review) => _buildReviewItem(review)),

        if (filteredReviews.length > 3)
          TextButton(
            onPressed: () {
              // Show all reviews
            },
            child: const Text(
              'Посмотреть все отзывы',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewFilter(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != 'All') ...[
              const Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 4),
            ],
            Text(
              label == 'All' ? 'Все' : label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final user = review['user'] as Map<String, dynamic>? ?? {};
    final userName = user['fullName'] ?? 'Аноним';
    final rating = review['rating'] ?? 0;
    final comment = review['comment'] ?? '';
    final createdAt = DateTime.tryParse(review['createdAt'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    height: 1.4,
                    fontSize: 15,
                  ),
                ),
                if (createdAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}.${date.month}.${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else {
      return 'Только что';
    }
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        serviceId: widget.serviceId,
        onReviewAdded: widget.onReviewAdded,
      ),
    );
  }
}