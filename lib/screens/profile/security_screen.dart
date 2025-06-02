import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _rememberMe = true;
  bool _faceId = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Безопасность'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Remember Me Switch
            _buildSwitchTile(
              'Запомнить меня',
              _rememberMe,
                  (value) => setState(() => _rememberMe = value),
            ),

            const SizedBox(height: 16),

            // Face ID Switch
            _buildSwitchTile(
              'Face ID',
              _faceId,
                  (value) => setState(() => _faceId = value),
            ),

            const SizedBox(height: 16),

            // Google Authenticator
            ListTile(
              title: const Text('Google Authenticator'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to Google Authenticator setup
              },
            ),

            const SizedBox(height: 32),

            // Change PIN Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: _changePinCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  foregroundColor: const Color(0xFF2E7D5F),
                ),
                child: const Text('Изменить PIN-код'),
              ),
            ),

            // Change Password Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  foregroundColor: const Color(0xFF2E7D5F),
                ),
                child: const Text('Изменить пароль'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2E7D5F),
      ),
    );
  }

  void _changePinCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить PIN-код'),
        content: const Text('Функция изменения PIN-кода будет доступна в следующей версии.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить пароль'),
        content: const Text('Функция изменения пароля будет доступна в следующей версии.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}