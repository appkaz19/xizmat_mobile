import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _generalNotifications = true;
  bool _soundNotifications = true;
  bool _vibrationNotifications = false;
  bool _specialOffers = true;
  bool _promoDiscounts = false;
  bool _paymentsNotifications = true;
  bool _appUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Общие уведомления',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            _buildSwitchTile(
              'Общие уведомления',
              _generalNotifications,
                  (value) => setState(() => _generalNotifications = value),
            ),

            _buildSwitchTile(
              'Звук',
              _soundNotifications,
                  (value) => setState(() => _soundNotifications = value),
            ),

            _buildSwitchTile(
              'Вибрация',
              _vibrationNotifications,
                  (value) => setState(() => _vibrationNotifications = value),
            ),

            _buildSwitchTile(
              'Специальные предложения',
              _specialOffers,
                  (value) => setState(() => _specialOffers = value),
            ),

            _buildSwitchTile(
              'Промо и скидки',
              _promoDiscounts,
                  (value) => setState(() => _promoDiscounts = value),
            ),

            _buildSwitchTile(
              'Платежи',
              _paymentsNotifications,
                  (value) => setState(() => _paymentsNotifications = value),
            ),

            _buildSwitchTile(
              'Обновления приложения',
              _appUpdates,
                  (value) => setState(() => _appUpdates = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2E7D5F),
      ),
    );
  }
}