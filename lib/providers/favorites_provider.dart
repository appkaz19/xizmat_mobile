import 'package:flutter/material.dart';
import '../services/api/service.dart';

class FavoritesProvider extends ChangeNotifier {
  // Множества для быстрого поиска
  final Set<String> _favoriteServiceIds = {};
  final Set<String> _favoriteJobIds = {};

  bool _isLoading = false;
  bool _isInitialized = false;

  // Геттеры
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  Set<String> get favoriteServiceIds => Set.unmodifiable(_favoriteServiceIds);
  Set<String> get favoriteJobIds => Set.unmodifiable(_favoriteJobIds);

  // Проверка избранного
  bool isServiceFavorite(String serviceId) => _favoriteServiceIds.contains(serviceId);
  bool isJobFavorite(String jobId) => _favoriteJobIds.contains(jobId);

  // Инициализация - загрузка избранного с сервера
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Загружаем избранные сервисы
      final favoriteServices = await ApiService.favorites.getFavoriteServices();
      _favoriteServiceIds.clear();
      for (final service in favoriteServices) {
        final id = service['id']?.toString();
        if (id != null) {
          _favoriteServiceIds.add(id);
        }
      }

      // Загружаем избранные работы
      final favoriteJobs = await ApiService.favorites.getFavoriteJobs();
      _favoriteJobIds.clear();
      for (final job in favoriteJobs) {
        final id = job['id']?.toString();
        if (id != null) {
          _favoriteJobIds.add(id);
        }
      }

      _isInitialized = true;
    } catch (e) {
      print('Ошибка загрузки избранного: $e');
      // В случае ошибки все равно помечаем как инициализированное
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Переключение избранного для сервиса
  Future<bool> toggleServiceFavorite(String serviceId) async {
    final wasInFavorites = _favoriteServiceIds.contains(serviceId);

    // Оптимистичное обновление UI
    if (wasInFavorites) {
      _favoriteServiceIds.remove(serviceId);
    } else {
      _favoriteServiceIds.add(serviceId);
    }
    notifyListeners();

    try {
      bool success;
      if (wasInFavorites) {
        success = await ApiService.favorites.removeFavoriteService(serviceId);
      } else {
        success = await ApiService.favorites.addFavoriteService(serviceId);
      }

      if (!success) {
        // Откатываем изменения при ошибке
        if (wasInFavorites) {
          _favoriteServiceIds.add(serviceId);
        } else {
          _favoriteServiceIds.remove(serviceId);
        }
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      print('Ошибка изменения избранного сервиса: $e');

      // Откатываем изменения при ошибке
      if (wasInFavorites) {
        _favoriteServiceIds.add(serviceId);
      } else {
        _favoriteServiceIds.remove(serviceId);
      }
      notifyListeners();
      return false;
    }
  }

  // Переключение избранного для работы
  Future<bool> toggleJobFavorite(String jobId) async {
    final wasInFavorites = _favoriteJobIds.contains(jobId);

    // Оптимистичное обновление UI
    if (wasInFavorites) {
      _favoriteJobIds.remove(jobId);
    } else {
      _favoriteJobIds.add(jobId);
    }
    notifyListeners();

    try {
      bool success;
      if (wasInFavorites) {
        success = await ApiService.favorites.removeFavoriteJob(jobId);
      } else {
        success = await ApiService.favorites.addFavoriteJob(jobId);
      }

      if (!success) {
        // Откатываем изменения при ошибке
        if (wasInFavorites) {
          _favoriteJobIds.add(jobId);
        } else {
          _favoriteJobIds.remove(jobId);
        }
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      print('Ошибка изменения избранного работы: $e');

      // Откатываем изменения при ошибке
      if (wasInFavorites) {
        _favoriteJobIds.add(jobId);
      } else {
        _favoriteJobIds.remove(jobId);
      }
      notifyListeners();
      return false;
    }
  }

  // Принудительное обновление с сервера
  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }

  // Очистка при выходе из аккаунта
  void clear() {
    _favoriteServiceIds.clear();
    _favoriteJobIds.clear();
    _isInitialized = false;
    _isLoading = false;
    notifyListeners();
  }

  // Добавить в избранное без API запроса (для случаев когда уже знаем результат)
  void addServiceToFavoritesLocal(String serviceId) {
    _favoriteServiceIds.add(serviceId);
    notifyListeners();
  }

  void removeServiceFromFavoritesLocal(String serviceId) {
    _favoriteServiceIds.remove(serviceId);
    notifyListeners();
  }

  void addJobToFavoritesLocal(String jobId) {
    _favoriteJobIds.add(jobId);
    notifyListeners();
  }

  void removeJobFromFavoritesLocal(String jobId) {
    _favoriteJobIds.remove(jobId);
    notifyListeners();
  }
}