import 'package:flutter/material.dart';
import '../../services/api/service.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedMethod = 'SMS';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
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
        title: const Text('Восстановление пароля'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Illustration
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Phone with lock icon
                        Positioned(
                          left: 60,
                          top: 40,
                          child: Container(
                            width: 80,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[600]!, width: 2),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  width: 30,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[600],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.lock_reset,
                                        color: Color(0xFF2E7D5F),
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[600],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // SMS icon
                        Positioned(
                          right: 30,
                          bottom: 30,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D5F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sms,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Введите номер телефона для восстановления пароля',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                // Phone Number Input
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Номер телефона',
                    prefixIcon: const Icon(Icons.phone),
                    hintText: '+998 90 123 45 67',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2E7D5F),
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Введите номер телефона';
                    }
                    if (value!.length < 9) {
                      return 'Некорректный номер телефона';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  'Способ восстановления:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 16),

                // SMS Method
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedMethod == 'SMS'
                          ? const Color(0xFF2E7D5F)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RadioListTile<String>(
                    value: 'SMS',
                    groupValue: _selectedMethod,
                    onChanged: _isLoading ? null : (value) {
                      setState(() {
                        _selectedMethod = value!;
                      });
                    },
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedMethod == 'SMS'
                                ? const Color(0xFF2E7D5F)
                                : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.sms,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('SMS на номер телефона'),
                      ],
                    ),
                    activeColor: const Color(0xFF2E7D5F),
                  ),
                ),

                const SizedBox(height: 16),

                // Email Method (disabled for now)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RadioListTile<String>(
                    value: 'Email',
                    groupValue: _selectedMethod,
                    onChanged: null, // Disabled
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.email,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Email (в разработке)',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    activeColor: const Color(0xFF2E7D5F),
                  ),
                ),

                const SizedBox(height: 32),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _selectedMethod != 'SMS') ? null : _sendResetCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D5F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Отправить код',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info text
                Center(
                  child: Text(
                    'На указанный номер будет отправлен код подтверждения',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final phone = _phoneController.text.trim();

      final success = await ApiService.auth.requestResetPassword(phone);

      if (!mounted) return;

      if (success) {
        // Показываем подтверждение
        _showSuccessDialog();

        // Переходим к верификации OTP
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phone: phone,
              isRegistration: false,
              isPasswordReset: true,
            ),
          ),
        );
      } else {
        _showErrorDialog('Ошибка отправки кода. Проверьте номер телефона.');
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

  void _showSuccessDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Код отправлен на номер ${_phoneController.text}'),
        backgroundColor: const Color(0xFF2E7D5F),
        duration: const Duration(seconds: 2),
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
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF2E7D5F)),
            ),
          ),
        ],
      ),
    );
  }
}