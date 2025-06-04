import 'package:flutter/material.dart';
import '../../widgets/social_login_button.dart';
import '../../services/api/service.dart';
import 'profile_setup_screen.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Создайте\nаккаунт',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 42
                ),
              ),

              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Номер телефона',
                        prefixIcon: Icon(Icons.phone),
                        hintText: '+998 90 123 45 67',
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Введите номер телефона';
                        }
                        // Можно добавить валидацию формата номера
                        if (value!.length < 9) {
                          return 'Некорректный номер телефона';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Введите пароль';
                        }
                        if (value!.length < 6) {
                          return 'Пароль должен содержать минимум 6 символов';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Подтвердите пароль',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Пароли не совпадают';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: _isLoading ? null : (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading ? null : () {
                              setState(() {
                                _agreeToTerms = !_agreeToTerms;
                              });
                            },
                            child: const Text(
                              'Я согласен с условиями использования и политикой конфиденциальности',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_agreeToTerms && !_isLoading) ? _register : null,
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text('Зарегистрироваться'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: Text(
                  'Или войдите через',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialIconButton(Icons.facebook, const Color(0xFF1877F2)),
                  _socialIconButton(Icons.g_mobiledata, const Color(0xFF4285F4)),
                  _socialIconButton(Icons.apple, Colors.black),
                ],
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Уже есть аккаунт? '),
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Войдите'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialIconButton(IconData icon, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: _isLoading ? null : () => _socialRegister(),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.auth.register(
        _phoneController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result.success) {
        // Успешная регистрация
        _showSuccessDialog(result.message);

        // Если регистрация успешна, переходим к верификации OTP
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phone: _phoneController.text.trim(),
              isRegistration: true,
              isPasswordReset: false,
            ),
          ),
        );
      } else {
        // Ошибка регистрации
        _showErrorDialog(result.message ?? 'Произошла ошибка при регистрации');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Ошибка соединения. Проверьте интернет-подключение.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _socialRegister() {
    // TODO: Реализовать социальную регистрацию
    _showInfoDialog('Социальная регистрация будет доступна в следующих версиях');
  }

  void _showSuccessDialog(String? message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Успешно!'),
        content: Text(message ?? 'Регистрация прошла успешно'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Информация'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}