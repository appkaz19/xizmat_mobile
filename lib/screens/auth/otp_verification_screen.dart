import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../services/api/service.dart';
import '../../services/api/apis/auth.dart'; // Для OtpVerificationResult
import 'create_new_password_screen.dart';
import '../main/main_navigation.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final bool isRegistration;
  final bool isPasswordReset;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.isRegistration = false,
    this.isPasswordReset = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
        (index) => FocusNode(),
  );

  bool _isLoading = false;
  int _resendTimer = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _resendTimer = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  String get _maskedPhone {
    if (widget.phone.length >= 4) {
      return '+7 XXX ***${widget.phone.substring(widget.phone.length - 2)}';
    }
    return widget.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Подтверждение номера'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Код отправлен на номер $_maskedPhone',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return SizedBox(
                          width: 60,
                          height: 60,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            keyboardType: TextInputType.none, // Отключаем системную клавиатуру
                            maxLength: 1,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              counterText: '',
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
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onTap: () {
                              // Убираем фокус с полей при тапе, используем только нашу клавиатуру
                              FocusScope.of(context).unfocus();
                            },
                            onChanged: (value) {
                              // Этот callback теперь будет срабатывать только от нашей цифровой клавиатуры
                              if (value.isNotEmpty && index < 3) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }

                              // Auto verify when all fields are filled
                              if (_otpCode.length == 4) {
                                _verifyOtp();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 40),

                    // Resend Timer/Button
                    if (!_canResend)
                      Text(
                        'Повторно отправить через $_resendTimer сек',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _isLoading ? null : _resendOtp,
                        child: const Text(
                          'Отправить код повторно',
                          style: TextStyle(
                            color: Color(0xFF2E7D5F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Number Pad
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
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
                        'Подтвердить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Number Pad
                  _buildNumberPad(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _otpCode {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCode;
    if (otp.length != 4) {
      _showErrorDialog('Введите полный код');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;

      if (widget.isPasswordReset) {
        final result = await ApiService.auth.verifyResetOtp(widget.phone, otp);
        if (result.success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNewPasswordScreen(), // БЕЗ параметров!
            ),
          );
        } else {
          _showErrorDialog(result.message ?? 'Неверный код. Попробуйте еще раз.');
        }
      }

      if (!success && mounted) {
        _showErrorDialog('Неверный код. Попробуйте еще раз.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Ошибка верификации. Проверьте соединение.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    try {
      // В зависимости от контекста вызываем разные методы
      if (widget.isPasswordReset) {
        await ApiService.auth.requestResetPassword(widget.phone);
      } else {
        // Для регистрации может потребоваться отдельный метод
        // await ApiService.auth.resendOtp(widget.phone);
      }

      if (mounted) {
        _showInfoDialog('Код отправлен повторно');
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Ошибка отправки кода');
      }
    }
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        // Numbers 1-3
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('1'),
            _buildNumberButton('2'),
            _buildNumberButton('3'),
          ],
        ),
        const SizedBox(height: 16),

        // Numbers 4-6
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
          ],
        ),
        const SizedBox(height: 16),

        // Numbers 7-9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
          ],
        ),
        const SizedBox(height: 16),

        // Bottom row: *, 0, backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton(''),
            _buildNumberButton('0'),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: number.isEmpty || _isLoading ? null : () => _addNumber(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: _isLoading ? Colors.grey : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return InkWell(
      onTap: _isLoading ? null : _removeNumber,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 24,
            color: _isLoading ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }

  void _addNumber(String number) {
    if (_isLoading) return;

    for (int i = 0; i < _controllers.length; i++) {
      if (_controllers[i].text.isEmpty) {
        setState(() {
          _controllers[i].text = number;
        });
        if (i < 3) {
          _focusNodes[i + 1].requestFocus();
        } else {
          _focusNodes[i].unfocus();
          // Auto verify when all fields are filled
          if (_otpCode.length == 4) {
            _verifyOtp();
          }
        }
        break;
      }
    }
  }

  void _removeNumber() {
    if (_isLoading) return;

    for (int i = _controllers.length - 1; i >= 0; i--) {
      if (_controllers[i].text.isNotEmpty) {
        setState(() {
          _controllers[i].text = '';
        });
        if (i > 0) {
          _focusNodes[i - 1].requestFocus();
        } else {
          _focusNodes[i].requestFocus();
        }
        break;
      }
    }
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