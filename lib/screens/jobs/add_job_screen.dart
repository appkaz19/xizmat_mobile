import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'job_pricing_screen.dart';
import '../../services/api/service.dart';
import '../../utils/city_autocomplete.dart';
import '../../utils/app_theme.dart';
import '../../services/s3_uploader.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();

  // Data lists
  List<Map<String, dynamic>> cities = [];

  // Selected values
  String? _selectedCityId;

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isUploading = false;
  String _uploadProgress = '';

  // ДОБАВИЛИ: выбор способов связи
  bool _allowChat = true;
  bool _allowPhone = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      final cities = await ApiService.location.getRegionsWithCities();

      setState(() {
        this.cities = cities;
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки данных: $e');
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка загрузки данных'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isFormValid() {
    return _selectedCityId != null &&
        _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _selectedImages.isNotEmpty &&
        (_allowChat || _allowPhone); // ДОБАВИЛИ: хотя бы один способ связи должен быть выбран
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Создать объявление'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isUploading ? null : () => Navigator.pop(context),
        ),
        title: const Text('Создать объявление'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title
              const Text(
                'Заголовок',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _titleController,
                enabled: !_isUploading,
                decoration: const InputDecoration(
                  hintText: 'Например: Уборка дома, Ремонт окон',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, введите заголовок';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),

              const SizedBox(height: 24),

              // Description
              const Text(
                'Описание',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _descriptionController,
                enabled: !_isUploading,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Что нужно сделать?',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, добавьте описание';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),

              const SizedBox(height: 16),

              Text(
                'Указав описание подробнее, вам не придется уточнять информацию каждому специалисту',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 24),

              // Price
              const Text(
                'Ваша цена',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Text(
                    'до',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      enabled: !_isUploading,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '0',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Укажите цену';
                        }
                        final price = int.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'Введите корректную цену';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'За всю работу',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Address
              const Text(
                'Адрес',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _addressController,
                enabled: !_isUploading,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'г. Алматы, адрес не указан',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, введите адрес';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),

              const SizedBox(height: 16),

              Text(
                'Рекомендуем указать адрес, чтобы специалисты могли понять маршрут и время на дорогу',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 24),

              // City Selection
              const Text(
                'Город',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              IgnorePointer(
                ignoring: _isUploading,
                child: CityAutocomplete(
                  cities: cities,
                  selectedCityId: _selectedCityId,
                  onCityChanged: (cityId) {
                    setState(() {
                      _selectedCityId = cityId;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Photo Section
              GestureDetector(
                onTap: _isUploading ? null : _pickImages,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isUploading
                        ? Colors.grey.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isUploading
                          ? Colors.grey
                          : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: _isUploading
                            ? Colors.grey
                            : AppColors.primary,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Фото/Видео',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _isUploading
                              ? Colors.grey
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Добавьте фото или видео, мы можете показать и рассказать специалистам, что именно нужно сделать',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: _isUploading
                              ? Colors.grey
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Selected Images Grid
              if (_selectedImages.isNotEmpty) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      // Кнопка добавления фото
                      return GestureDetector(
                        onTap: _isUploading ? null : _pickImages,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isUploading
                                ? Colors.grey.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _isUploading
                                    ? Colors.grey
                                    : AppColors.primary
                            ),
                          ),
                          child: Icon(
                            Icons.add_photo_alternate,
                            color: _isUploading
                                ? Colors.grey
                                : AppColors.primary,
                            size: 40,
                          ),
                        ),
                      );
                    }

                    // Отображение выбранных изображений
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _isUploading ? null : () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _isUploading ? Colors.grey : Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                Text(
                  'Фото: ${_selectedImages.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ДОБАВИЛИ: Секция "Как с вами связаться?"
              const Text(
                'Как с вами связаться?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  // Кнопка "Чат"
                  Expanded(
                    child: GestureDetector(
                      onTap: _isUploading ? null : () {
                        setState(() {
                          _allowChat = !_allowChat;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _allowChat
                              ? AppColors.primary
                              : (_isUploading ? Colors.grey[300] : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Чат',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _allowChat ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Кнопка "Звонок"
                  Expanded(
                    child: GestureDetector(
                      onTap: _isUploading ? null : () {
                        setState(() {
                          _allowPhone = !_allowPhone;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _allowPhone
                              ? const Color(0xFF4FC3F7)
                              : (_isUploading ? Colors.grey[300] : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Звонок',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _allowPhone ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ДОБАВИЛИ: проверка что выбран хотя бы один способ связи
              if (!_allowChat && !_allowPhone) ...[
                const SizedBox(height: 8),
                Text(
                  'Выберите хотя бы один способ связи',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Create Job Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isFormValid() && !_isUploading) ? _proceedToPricing : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_isFormValid() && !_isUploading)
                        ? AppColors.primary
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isUploading
                      ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Создать заявку',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_uploadProgress.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _uploadProgress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  )
                      : const Text(
                    'Создать заявку',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _isUploading = true;
          _uploadProgress = 'Обрабатываем фото...';
        });

        // Обрабатываем изображения параллельно
        final futures = images.map((image) => _compressImage(File(image.path)));
        final compressedImages = await Future.wait(futures);

        // Добавляем только успешно обработанные изображения
        final validImages = compressedImages.where((img) => img != null).cast<File>();

        setState(() {
          _selectedImages.addAll(validImages);
          _isUploading = false;
          _uploadProgress = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Добавлено ${validImages.length} фото'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = '';
      });
      print('Ошибка выбора изображений: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка при выборе изображений'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<File?> _compressImage(File image) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        image.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      return compressedFile != null ? File(compressedFile.path) : null;
    } catch (e) {
      print('Ошибка сжатия изображения: $e');
      return image;
    }
  }

  Future<void> _proceedToPricing() async {
    if (!_formKey.currentState!.validate() || !_isFormValid()) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 'Загружаем фото...';
    });

    try {
      // Загружаем все изображения параллельно
      final uploadTasks = _selectedImages.map((image) =>
          S3Uploader.uploadFile(image, 'jobs/images')
      );

      setState(() {
        _uploadProgress = 'Загружаем ${uploadTasks.length} фото...';
      });

      final results = await Future.wait(uploadTasks);
      final imageUrls = results.where((url) => url != null).cast<String>().toList();

      print('Загружено изображений: ${imageUrls.length}/${_selectedImages.length}');

      if (imageUrls.isEmpty) {
        throw Exception('Не удалось загрузить ни одного изображения');
      }

      // ОБНОВИЛИ: добавляем allowChat и allowPhone в данные
      final jobData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': int.parse(_priceController.text.trim()),
        'cityId': _selectedCityId,
        'address': _addressController.text.trim(),
        'images': imageUrls,
        'allowChat': _allowChat,    // ДОБАВИЛИ
        'allowPhone': _allowPhone,  // ДОБАВИЛИ
      };

      setState(() {
        _isUploading = false;
        _uploadProgress = '';
      });

      // Показываем успех
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Загружено ${imageUrls.length} фото'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobPricingScreen(jobData: jobData),
        ),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = '';
      });
      print('Ошибка загрузки фото: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}