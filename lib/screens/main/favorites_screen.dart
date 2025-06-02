import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/services_provider.dart';
import '../../widgets/service_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Избранное'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Все'),
              Tab(text: 'Дом'),
              Tab(text: 'Ремонт'),
              Tab(text: 'Строительство'),
            ],
          ),
        ),
        body: Consumer<ServicesProvider>(
          builder: (context, provider, child) {
            if (provider.favorites.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Нет избранных услуг',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Добавьте услуги в избранное для быстрого доступа',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                _buildFavoritesList(provider.favorites),
                _buildFavoritesList(provider.favorites), // Filter by category
                _buildFavoritesList(provider.favorites), // Filter by category
                _buildFavoritesList(provider.favorites), // Filter by category
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavoritesList(List<Service> services) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ServiceCard(service: services[index]),
        );
      },
    );
  }
}