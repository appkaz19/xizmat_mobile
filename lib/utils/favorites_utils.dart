import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesUtils {
  // Показать снэкбар с результатом операции
  static void showFavoriteSnackBar(
      BuildContext context, {
        required bool success,
        required bool wasAdded,
        String? customMessage,
      }) {
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(customMessage ?? 'Ошибка при изменении избранного'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasAdded ? 'Добавлено в избранное' : 'Удалено из избранного',
        ),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Отменить',
          textColor: Colors.white,
          onPressed: () {
            // Можно добавить логику отмены
          },
        ),
      ),
    );
  }

  // Переключить избранное для сервиса с обработкой ошибок
  static Future<void> toggleServiceFavorite(
      BuildContext context,
      String serviceId, {
        String? customSuccessMessage,
        String? customErrorMessage,
      }) async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final wasInFavorites = favoritesProvider.isServiceFavorite(serviceId);

    final success = await favoritesProvider.toggleServiceFavorite(serviceId);

    showFavoriteSnackBar(
      context,
      success: success,
      wasAdded: !wasInFavorites,
      customMessage: success ? customSuccessMessage : customErrorMessage,
    );
  }

  // Переключить избранное для работы с обработкой ошибок
  static Future<void> toggleJobFavorite(
      BuildContext context,
      String jobId, {
        String? customSuccessMessage,
        String? customErrorMessage,
      }) async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final wasInFavorites = favoritesProvider.isJobFavorite(jobId);

    final success = await favoritesProvider.toggleJobFavorite(jobId);

    showFavoriteSnackBar(
      context,
      success: success,
      wasAdded: !wasInFavorites,
      customMessage: success ? customSuccessMessage : customErrorMessage,
    );
  }

  // Получить виджет иконки избранного для сервиса
  static Widget buildServiceFavoriteIcon(
      BuildContext context,
      String serviceId, {
        Color? activeColor = Colors.amber,
        Color? inactiveColor = Colors.grey,
        double size = 24,
        VoidCallback? onPressed,
      }) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isServiceFavorite(serviceId);

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? activeColor : inactiveColor,
            size: size,
          ),
          onPressed: onPressed ?? () => toggleServiceFavorite(context, serviceId),
        );
      },
    );
  }

  // Получить виджет иконки избранного для работы
  static Widget buildJobFavoriteIcon(
      BuildContext context,
      String jobId, {
        Color? activeColor = Colors.amber,
        Color? inactiveColor = Colors.grey,
        double size = 24,
        VoidCallback? onPressed,
      }) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isJobFavorite(jobId);

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? activeColor : inactiveColor,
            size: size,
          ),
          onPressed: onPressed ?? () => toggleJobFavorite(context, jobId),
        );
      },
    );
  }

  // Принудительно обновить избранное с сервера
  static Future<void> refreshFavorites(BuildContext context) async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    await favoritesProvider.refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Избранное обновлено'),
        backgroundColor: Colors.green,
      ),
    );
  }
}