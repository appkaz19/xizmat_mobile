import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  final List<Map<String, dynamic>> friends = const [
    {
      'name': 'Tynisha Obey',
      'phone': '+1-300-555-0135',
      'status': 'invite',
      'avatar': 'https://example.com/avatar1.jpg',
    },
    {
      'name': 'Florencio Dorrance',
      'phone': '+1-202-555-0136',
      'status': 'sent',
      'avatar': 'https://example.com/avatar2.jpg',
    },
    {
      'name': 'Chantal Shelburne',
      'phone': '+1-300-555-0119',
      'status': 'invite',
      'avatar': 'https://example.com/avatar3.jpg',
    },
    {
      'name': 'Maryland Winkles',
      'phone': '+1-300-555-0161',
      'status': 'invited',
      'avatar': 'https://example.com/avatar4.jpg',
    },
    {
      'name': 'Rodolfo Goode',
      'phone': '+1-300-555-0136',
      'status': 'invited',
      'avatar': 'https://example.com/avatar5.jpg',
    },
    {
      'name': 'Benny Spanbauer',
      'phone': '+1-202-555-0167',
      'status': 'invite',
      'avatar': 'https://example.com/avatar6.jpg',
    },
    {
      'name': 'Tyra Dhillon',
      'phone': '+1-202-555-0119',
      'status': 'invite',
      'avatar': 'https://example.com/avatar7.jpg',
    },
    {
      'name': 'Jamel Eusebio',
      'phone': '+1-300-555-0171',
      'status': 'invited',
      'avatar': 'https://example.com/avatar8.jpg',
    },
    {
      'name': 'Pedro Huard',
      'phone': '+1-202-555-0171',
      'status': 'invite',
      'avatar': 'https://example.com/avatar9.jpg',
    },
    {
      'name': 'Clinton Mcclure',
      'phone': '+1-300-555-0119',
      'status': 'invite',
      'avatar': 'https://example.com/avatar10.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пригласить друзей'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300],
                child: Text(
                  friend['name'].toString().substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              title: Text(
                friend['name'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                friend['phone'],
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: _buildActionButton(friend['status'], context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(String status, BuildContext context) {
    switch (status) {
      case 'invite':
        return ElevatedButton(
          onPressed: () {
            _sendInvite(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D5F),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Пригласить',
            style: TextStyle(fontSize: 12),
          ),
        );
      case 'sent':
        return OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Отправлено',
            style: TextStyle(fontSize: 12),
          ),
        );
      case 'invited':
        return OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Invited',
            style: TextStyle(fontSize: 12),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _sendInvite(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Приглашение отправлено'),
        content: const Text('Приглашение успешно отправлено другу!'),
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