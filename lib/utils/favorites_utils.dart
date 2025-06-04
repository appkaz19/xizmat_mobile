import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api/service.dart';
import '../../utils/app_theme.dart';

class FavoritesUtils {
  static const String _servicesFavoritesKey = 'favorite_services';
  static const String _jobsFavoritesKey = 'favorite_jobs';

  // Services favorites
  static Future<Set<String>> getFavoriteServices() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_servicesFavoritesKey) ?? [];
    return favoritesList.toSet();
  }

  static Future<void> toggleServiceFavorite(String serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_servicesFavoritesKey) ?? [];
    final favoritesSet = favoritesList.toSet();

    if (favoritesSet.contains(serviceId)) {
      favoritesSet.remove(serviceId);
      try {
        await ApiService.favorites.removeFavoriteService(serviceId);
      } catch (e) {
        print('Ошибка удаления из избранного: $e');
      }
    } else {
      favoritesSet.add(serviceId);
      try {
        await ApiService.favorites.addFavoriteService(serviceId);
      } catch (e) {
        print('Ошибка добавления в избранное: $e');
      }
    }

    await prefs.setStringList(_servicesFavoritesKey, favoritesSet.toList());
  }

  static Widget buildServiceFavoriteIcon(
      BuildContext context,
      String serviceId, {
        Color activeColor = Colors.amber,
        Color inactiveColor = Colors.grey,
      }) {
    return FutureBuilder<Set<String>>(
      future: getFavoriteServices(),
      builder: (context, snapshot) {
        final favorites = snapshot.data ?? <String>{};
        final isFavorite = favorites.contains(serviceId);

        return IconButton(
          onPressed: () async {
            await toggleServiceFavorite(serviceId);
            // Trigger rebuild by calling setState if widget is mounted
            if (context.mounted) {
              (context as Element).markNeedsBuild();
            }
          },
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? activeColor : inactiveColor,
          ),
        );
      },
    );
  }

  // Jobs favorites
  static Future<Set<String>> getFavoriteJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_jobsFavoritesKey) ?? [];
    return favoritesList.toSet();
  }

  static Future<void> toggleJobFavorite(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_jobsFavoritesKey) ?? [];
    final favoritesSet = favoritesList.toSet();

    if (favoritesSet.contains(jobId)) {
      favoritesSet.remove(jobId);
      try {
        await ApiService.favorites.removeFavoriteJob(jobId);
      } catch (e) {
        print('Ошибка удаления объявления из избранного: $e');
      }
    } else {
      favoritesSet.add(jobId);
      try {
        await ApiService.favorites.addFavoriteJob(jobId);
      } catch (e) {
        print('Ошибка добавления объявления в избранное: $e');
      }
    }

    await prefs.setStringList(_jobsFavoritesKey, favoritesSet.toList());
  }

  static Widget buildJobFavoriteIcon(
      BuildContext context,
      String jobId, {
        Color activeColor = Colors.amber,
        Color inactiveColor = Colors.grey,
      }) {
    return FutureBuilder<Set<String>>(
      future: getFavoriteJobs(),
      builder: (context, snapshot) {
        final favorites = snapshot.data ?? <String>{};
        final isFavorite = favorites.contains(jobId);

        return IconButton(
          onPressed: () async {
            await toggleJobFavorite(jobId);
            // Trigger rebuild by calling setState if widget is mounted
            if (context.mounted) {
              (context as Element).markNeedsBuild();
            }
          },
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? activeColor : inactiveColor,
          ),
        );
      },
    );
  }

  // Get all favorites for display
  static Future<List<Map<String, dynamic>>> getAllFavoriteServices() async {
    try {
      return await ApiService.favorites.getFavoriteServices();
    } catch (e) {
      print('Ошибка загрузки избранных сервисов: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllFavoriteJobs() async {
    try {
      return await ApiService.favorites.getFavoriteJobs();
    } catch (e) {
      print('Ошибка загрузки избранных объявлений: $e');
      return [];
    }
  }

  // Clear all favorites (for logout, etc.)
  static Future<void> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_servicesFavoritesKey);
    await prefs.remove(_jobsFavoritesKey);
  }
}