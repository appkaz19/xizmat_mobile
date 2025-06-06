// lib/screens/main/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api/service.dart';
import '../auth/profile_setup_screen.dart';
import '../profile/settings_screen.dart';
import '../profile/wallet_top_up_screen.dart';
import '../profile/security_screen.dart';
import '../profile/language_screen.dart';
import '../profile/privacy_policy_screen.dart';
import '../profile/support_screen.dart';
import '../profile/invite_friends_screen.dart';
import '../profile/wallet_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkTheme = false;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _walletData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Загружаем профиль и кошелек параллельно
      final profileFuture = ApiService.user.getProfile();
      final walletFuture = ApiService.wallet.getWallet();

      final results = await Future.wait([profileFuture, walletFuture]);

      if (mounted) {
        setState(() {
          _userProfile = results[0];
          _walletData = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Ошибка загрузки данных профиля: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String get _displayName {
    if (_userProfile == null) return 'Пользователь';

    final fullName = _userProfile!['fullName'];
    final nickname = _userProfile!['nickname'];

    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    } else if (nickname != null && nickname.isNotEmpty) {
      return '@$nickname';
    } else {
      return 'Пользователь';
    }
  }

  String get _displayEmail {
    if (_userProfile == null) return 'Загружается...';

    final email = _userProfile!['email'];
    final phone = _userProfile!['phone'];

    if (email != null && email.isNotEmpty) {
      return email;
    } else if (phone != null && phone.isNotEmpty) {
      return phone;
    } else {
      return 'Не указано';
    }
  }

  String? get _avatarUrl {
    return _userProfile?['avatarUrl'];
  }

  String get _balanceText {
    if (_walletData == null) return '';

    final balance = _walletData!['balance'];
    if (balance == null) return '';

    final balanceInt = balance is int ? balance : int.tryParse(balance.toString()) ?? 0;
    return '$balanceInt монет';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _avatarUrl != null
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: _avatarUrl == null
                        ? (_isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.person, size: 40, color: Colors.grey))
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _displayEmail,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_balanceText.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.account_balance_wallet,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                _balanceText,
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileSetupScreen(
                            phone: _userProfile?['phone'],
                            isEditing: true,
                          ),
                        ),
                      ).then((result) {
                        // Обновляем данные после возврата из редактирования
                        if (result == true) {
                          _loadUserData();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu Items
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Редактировать профиль',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileSetupScreen(
                      phone: _userProfile?['phone'],
                      isEditing: true,
                    ),
                  ),
                ).then((result) {
                  // Обновляем данные после возврата из редактирования
                  if (result == true) {
                    _loadUserData();
                  }
                });
              },
            ),

            _buildMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Уведомления',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: 'Платежи',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Кошелек',
              subtitle: _balanceText.isNotEmpty ? _balanceText : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletTopUpScreen(),
                  ),
                ).then((_) {
                  // Обновляем баланс после пополнения
                  _loadUserData();
                });
              },
            ),

            _buildMenuItem(
              icon: Icons.security_outlined,
              title: 'Безопасность',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecurityScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.language_outlined,
              title: 'Язык',
              subtitle: 'Русский (RU)',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageScreen(),
                  ),
                );
              },
            ),

            _buildMenuItemWithSwitch(
              icon: Icons.dark_mode_outlined,
              title: 'Тёмная тема',
              value: _isDarkTheme,
              onChanged: (value) {
                setState(() {
                  _isDarkTheme = value;
                });
                // TODO: Реализовать сохранение настройки темы
              },
            ),

            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Политика конфиденциальности',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Служба поддержки',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportScreen(),
                  ),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.group_add_outlined,
              title: 'Пригласить друзей',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InviteFriendsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _buildMenuItem(
              icon: Icons.logout,
              title: 'Выйти из аккаунта',
              textColor: Colors.red,
              onTap: () => _showLogoutDialog(context),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? Colors.grey[700]),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMenuItemWithSwitch({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[700]),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2E7D5F),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы действительно хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text(
              'Да, выйти',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}