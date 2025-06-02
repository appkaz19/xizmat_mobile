import 'package:flutter/foundation.dart';

class Service {
  final String id;
  final String title;
  final String description;
  final double price;
  final String providerId;
  final String providerName;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final String category;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.providerId,
    required this.providerName,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.category,
  });
}

class ServicesProvider with ChangeNotifier {
  List<Service> _services = [];
  List<Service> _favorites = [];

  List<Service> get services => _services;
  List<Service> get favorites => _favorites;

  ServicesProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _services = [
      Service(
        id: '1',
        title: 'Уборка дома',
        description: 'Качественная уборка дома',
        price: 25000,
        providerId: '1',
        providerName: 'Пример Примеров',
        rating: 4.8,
        reviewCount: 8289,
        images: [],
        category: 'cleaning',
      ),
      Service(
        id: '2',
        title: 'Ремонт кондиционеров',
        description: 'Профессиональный ремонт кондиционеров',
        price: 7000,
        providerId: '2',
        providerName: 'Пример Примеров',
        rating: 4.9,
        reviewCount: 6182,
        images: [],
        category: 'repair',
      ),
      Service(
        id: '3',
        title: 'Чистка стекол',
        description: 'Мытье окон и стеклянных поверхностей',
        price: 5000,
        providerId: '3',
        providerName: 'Пример Примеров',
        rating: 4.7,
        reviewCount: 7938,
        images: [],
        category: 'cleaning',
      ),
      Service(
        id: '4',
        title: 'Ремонт кабелей',
        description: 'Ремонт и замена кабелей',
        price: 4000,
        providerId: '4',
        providerName: 'Пример Примеров',
        rating: 4.9,
        reviewCount: 6182,
        images: [],
        category: 'repair',
      ),
    ];
    notifyListeners();
  }

  Future<void> fetchServices() async {
    // Implement API call
    notifyListeners();
  }

  void toggleFavorite(Service service) {
    if (_favorites.any((fav) => fav.id == service.id)) {
      _favorites.removeWhere((fav) => fav.id == service.id);
    } else {
      _favorites.add(service);
    }
    notifyListeners();
  }

  bool isFavorite(Service service) {
    return _favorites.any((fav) => fav.id == service.id);
  }
}