import 'package:flutter/material.dart';
import '../../../services/api/service.dart';
import '../../../utils/app_theme.dart';

class AddReviewDialog extends StatefulWidget {
  final String serviceId;
  final VoidCallback onReviewAdded;

  const AddReviewDialog({
    super.key,
    required this.serviceId,
    required this.onReviewAdded,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, напишите комментарий')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService.reviews.submitReview(
        serviceId: widget.serviceId,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );

      if (result != null) {
        widget.onReviewAdded();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Отзыв успешно добавлен'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        throw Exception('Не удалось добавить отзыв');
      }
    } catch (e) {
      String errorMessage = 'Ошибка при добавлении отзыва';

      // Проверяем специфичные ошибки
      if (e.toString().contains('Review already submitted')) {
        errorMessage = 'Вы уже оставили отзыв на этот сервис';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Нельзя оставить отзыв на этот сервис';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Оставить отзыв',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Оценка:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                final rating = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = rating),
                  child: Icon(
                    Icons.star,
                    size: 32,
                    color: rating <= _selectedRating ? Colors.amber : Colors.grey[300],
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            const Text(
              'Комментарий:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Поделитесь своим опытом...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Отправить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}