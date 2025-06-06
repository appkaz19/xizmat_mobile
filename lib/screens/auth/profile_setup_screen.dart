import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import '../main/main_navigation.dart';
import '../../services/s3_uploader.dart';
import '../../services/api/service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String? phone; // Номер телефона передается извне
  final bool isEditing; // Флаг редактирования

  const ProfileSetupScreen({
    super.key,
    this.phone,
    this.isEditing = false,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isLoadingProfile = true;
  DateTime? _selectedDate;
  Map<String, dynamic>? _currentProfile;
  String? _currentAvatarUrl; // Добавляем отдельную переменную для текущего аватара

  @override
  void initState() {
    super.initState();
    // Предзаполняем номер телефона если он передан
    if (widget.phone != null) {
      _phoneController.text = widget.phone!;
    }

    // Если это редактирование, загружаем текущий профиль
    if (widget.isEditing) {
      _loadCurrentProfile();
    } else {
      _isLoadingProfile = false;
    }
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final profile = await ApiService.user.getProfile();
      print('🔍 Загружен профиль: $profile');
      if (profile != null && mounted) {
        _currentProfile = profile;

        // ВАЖНО: Заполняем поля до setState
        _prefillFieldsWithoutSetState();

        // Теперь обновляем UI одним setState
        setState(() {
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('🔥 Ошибка загрузки профиля: $e');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _prefillFieldsWithoutSetState() {
    if (_currentProfile == null) {
      print('❌ _currentProfile is null');
      return;
    }

    print('✅ Заполняем поля данными: $_currentProfile');

    // Предзаполняем поля
    if (_currentProfile!['fullName'] != null) {
      _fullNameController.text = _currentProfile!['fullName'];
      print('✅ FullName: ${_currentProfile!['fullName']}');
    }

    if (_currentProfile!['nickname'] != null) {
      _nicknameController.text = _currentProfile!['nickname'];
      print('✅ Nickname: ${_currentProfile!['nickname']}');
    }

    if (_currentProfile!['email'] != null) {
      _emailController.text = _currentProfile!['email'];
      print('✅ Email: ${_currentProfile!['email']}');
    }

    if (_currentProfile!['phone'] != null) {
      _phoneController.text = _currentProfile!['phone'];
      print('✅ Phone: ${_currentProfile!['phone']}');
    }

    // Сохраняем URL текущего аватара
    if (_currentProfile!['avatarUrl'] != null && _currentProfile!['avatarUrl'].toString().isNotEmpty) {
      _currentAvatarUrl = _currentProfile!['avatarUrl'];
      print('✅ Avatar URL найден: $_currentAvatarUrl');
    } else {
      print('❌ AvatarUrl пустой или null: ${_currentProfile!['avatarUrl']}');
    }

    // Предзаполняем дату рождения
    if (_currentProfile!['birthdate'] != null) {
      try {
        final birthDate = DateTime.parse(_currentProfile!['birthdate']);
        _selectedDate = birthDate;
        _birthdateController.text = '${birthDate.day.toString().padLeft(2, '0')}/${birthDate.month.toString().padLeft(2, '0')}/${birthDate.year}';
        print('✅ Birthdate: ${_birthdateController.text}');
      } catch (e) {
        print('🔥 Ошибка парсинга даты: $e');
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _birthdateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Редактировать профиль' : 'Заполните профиль'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoadingProfile
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Загружаем данные профиля...'),
            ],
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Photo - ИСПРАВЛЕННАЯ ВЕРСИЯ
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          image: _getDecorationImage(),
                        ),
                        child: _getDecorationImage() == null
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D5F),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    hintText: 'Полное имя',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Введите ваше полное имя';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    hintText: 'Никнейм (a-z, 0-9, _)',
                    prefixIcon: Icon(Icons.alternate_email),
                    helperText: 'Только латинские буквы, цифры и подчеркивание',
                  ),
                  textCapitalization: TextCapitalization.none,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9_]*$')),
                    LengthLimitingTextInputFormatter(20),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      // Проверяем, что никнейм начинается с буквы
                      if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
                        return 'Никнейм должен начинаться с буквы';
                      }
                      // Проверяем минимальную длину
                      if (value.length < 3) {
                        return 'Минимум 3 символа';
                      }
                      // Проверяем что не заканчивается на подчеркивание
                      if (value.endsWith('_')) {
                        return 'Не может заканчиваться на _';
                      }
                      // Проверяем что нет двойных подчеркиваний
                      if (value.contains('__')) {
                        return 'Нельзя использовать __ подряд';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Автоматически приводим к нижнему регистру
                    if (value != value.toLowerCase()) {
                      _nicknameController.value = _nicknameController.value.copyWith(
                        text: value.toLowerCase(),
                        selection: TextSelection.collapsed(offset: value.toLowerCase().length),
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _birthdateController,
                  decoration: const InputDecoration(
                    hintText: 'Дата рождения',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _selectDate,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Эл. почта',
                    suffixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // Показываем поле телефона только если номер НЕ передан
                if (widget.phone == null) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/us_flag.png',
                              width: 24,
                              height: 16,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 24,
                                  height: 16,
                                  color: Colors.blue,
                                  child: const Icon(Icons.flag, size: 12, color: Colors.white),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text('+1'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            hintText: 'Номер телефона',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Если номер телефона уже известен, показываем его как read-only
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.phone, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Text(
                          widget.phone!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF2E7D5F),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeProfile,
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
                        : Text(
                      widget.isEditing ? 'Сохранить' : 'Продолжить',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  DecorationImage? _getDecorationImage() {
    print('🖼️ _getDecorationImage called');
    print('   _profileImage: ${_profileImage != null ? "есть" : "нет"}');
    print('   _currentAvatarUrl: $_currentAvatarUrl');

    if (_profileImage != null) {
      print('   → Возвращаем FileImage');
      return DecorationImage(
        image: FileImage(_profileImage!),
        fit: BoxFit.cover,
      );
    } else if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
      print('   → Возвращаем NetworkImage для: $_currentAvatarUrl');
      return DecorationImage(
        image: NetworkImage(_currentAvatarUrl!),
        fit: BoxFit.cover,
        onError: (error, stackTrace) {
          print('❌ Ошибка DecorationImage: $error');
        },
      );
    }
    print('   → Возвращаем null');
    return null;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // Ограничиваем размер уже при выборе
      maxHeight: 1024,
      imageQuality: 85, // Начальное сжатие
    );

    if (image != null) {
      // Показываем индикатор сжатия
      _showUploadingSnackBar('Обрабатываем фото...');

      try {
        // Сжимаем изображение
        final compressedFile = await _compressImage(File(image.path));

        if (compressedFile != null) {
          setState(() {
            _profileImage = compressedFile;
          });

          // Показываем размер сжатого файла
          final sizeInKB = (await compressedFile.length()) / 1024;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Фото готово! Размер: ${sizeInKB.toStringAsFixed(0)} КБ'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _showErrorDialog('Ошибка обработки фото. Попробуйте другое изображение.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showErrorDialog('Ошибка обработки фото: $e');
      }
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = p.join(
          dir.path,
          'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg'
      );

      // Сжимаем изображение
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 80,
        minWidth: 400,
        minHeight: 400,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null) {
        return File(compressedFile.path);
      }
    } catch (e) {
      print('Ошибка сжатия изображения: $e');
    }
    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Показываем пользователю дату в читаемом формате
        _birthdateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        // Сохраняем выбранную дату для отправки на сервер
        _selectedDate = picked;
      });
    }
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? avatarUrl;

      // Загружаем аватар в S3, если выбран
      if (_profileImage != null) {
        _showUploadingSnackBar('Загружаем фото...');
        avatarUrl = await S3Uploader.uploadFile(_profileImage!, 'avatars');
        if (avatarUrl == null) {
          _showErrorDialog('Ошибка загрузки фото. Попробуйте еще раз.');
          return;
        }
      }

      // Отправляем данные профиля на бэкенд
      _showUploadingSnackBar('Сохраняем профиль...');

      // Формируем объект с данными
      final Map<String, dynamic> profileData = {};

      if (_fullNameController.text.trim().isNotEmpty) {
        profileData['fullName'] = _fullNameController.text.trim();
      }
      if (_nicknameController.text.trim().isNotEmpty) {
        profileData['nickname'] = _nicknameController.text.trim();
      }
      if (_emailController.text.trim().isNotEmpty) {
        profileData['email'] = _emailController.text.trim();
      }
      if (_selectedDate != null) {
        // Отправляем дату в ISO-8601 формате
        profileData['birthdate'] = _selectedDate!.toIso8601String();
      }

      // Отправляем аватар только если он был изменен
      if (avatarUrl != null) {
        profileData['avatarUrl'] = avatarUrl;
      } else if (widget.isEditing && _currentAvatarUrl != null) {
        // При редактировании сохраняем существующий аватар
        profileData['avatarUrl'] = _currentAvatarUrl;
      }

      final success = await ApiService.user.updateProfile(profileData);

      if (!mounted) return;

      if (success) {
        _showSuccessSnackBar('Профиль успешно сохранен!');

        // Небольшая задержка для показа сообщения
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          if (widget.isEditing) {
            // Если редактируем, просто возвращаемся назад
            Navigator.pop(context, true); // true означает что данные обновились
          } else {
            // Если первое заполнение, идем на главный экран
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
                  (route) => false,
            );
          }
        }
      } else {
        _showErrorDialog('Ошибка сохранения профиля');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Ошибка соединения. Проверьте интернет-подключение.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUploadingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D5F),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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