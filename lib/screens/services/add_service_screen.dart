import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'service_pricing_screen.dart';
import '../../services/api/service.dart';
import '../../utils/city_autocomplete.dart';
import '../../utils/app_theme.dart';
import '../../services/s3_uploader.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Data lists
  List<Map<String, String>> categories = [];
  List<Map<String, String>> subcategories = [];
  List<Map<String, dynamic>> cities = [];

  // Selected values
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  String? _selectedCityId;

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isUploading = false;
  String _uploadProgress = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      final results = await Future.wait([
        ApiService.category.getCategories(),
        ApiService.location.getRegionsWithCities(),
      ]);

      setState(() {
        categories = results[0] as List<Map<String, String>>;
        cities = results[1] as List<Map<String, dynamic>>;
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

  Future<void> _loadSubcategories(String categoryId) async {
    try {
      final subcategoriesData = await ApiService.subcategory.getSubcategoriesByCategory(categoryId);
      setState(() {
        subcategories = subcategoriesData;
        _selectedSubcategoryId = null;
      });
    } catch (e) {
      print('Ошибка загрузки подкатегорий: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка загрузки подкатегорий'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getCategoryName(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat['id'] == categoryId)['name'] ?? '';
    } catch (e) {
      return '';
    }
  }

  String _getSubcategoryName(String subcategoryId) {
    try {
      return subcategories.firstWhere((sub) => sub['id'] == subcategoryId)['name'] ?? '';
    } catch (e) {
      return '';
    }
  }

  bool _isFormValid() {
    return _selectedCategoryId != null &&
        _selectedSubcategoryId != null &&
        _selectedCityId != null &&
        _serviceNameController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _selectedImages.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Добавление услуги'),
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
        title: const Text('Добавление услуги'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selection
              const Text(
                'Категория',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Выберите категорию',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Выберите категорию'),
                  ),
                  ...categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['id'],
                      child: Text(category['name'] ?? ''),
                    );
                  }),
                ],
                onChanged: _isUploading ? null : (value) {
                  setState(() {
                    _selectedCategoryId = value;
                    _selectedSubcategoryId = null;
                    subcategories.clear();
                  });
                  if (value != null) {
                    _loadSubcategories(value);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Пожалуйста, выберите категорию';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Subcategory Selection
              if (_selectedCategoryId != null) ...[
                const Text(
                  'Подкатегория',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _selectedSubcategoryId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Выберите подкатегорию',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Выберите подкатегорию'),
                    ),
                    ...subcategories.map((subcategory) {
                      return DropdownMenuItem<String>(
                        value: subcategory['id'],
                        child: Text(subcategory['name'] ?? ''),
                      );
                    }),
                  ],
                  onChanged: _isUploading ? null : (value) {
                    setState(() {
                      _selectedSubcategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Пожалуйста, выберите подкатегорию';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
              ],

              // Service Name
              const Text(
                'Название услуги',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _serviceNameController,
                enabled: !_isUploading,
                decoration: const InputDecoration(
                  hintText: 'Например: Поклейка обоев',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, введите название услуги';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
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
                  hintText: 'Укажите точный адрес',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, введите адрес';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),

              const SizedBox(height: 24),

              // Price
              const Text(
                'Цена (тенге)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _priceController,
                enabled: !_isUploading,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Укажите стоимость услуги',
                  suffixText: '₸',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, укажите цену';
                  }
                  final price = int.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return 'Введите корректную цену';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),

              const SizedBox(height: 24),

              // Description
              const Text(
                'Описание услуги',
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
                  hintText: 'Расскажите подробнее о вашей услуге',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, добавьте описание';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
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
                      style: BorderStyle.solid,
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
                        'Добавить фото',
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
                        'Можно выбрать несколько фото',
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

              const SizedBox(height: 12),

              Text(
                'Первое фото станет обложкой',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
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
                        if (index == 0)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Обложка',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
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

              // Publish Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isFormValid() && !_isUploading) ? _proceedToPricing : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_isFormValid() && !_isUploading)
                        ? AppColors.secondary
                        : Colors.grey,
                    foregroundColor: Colors.black,
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
                              valueColor: AlwaysStoppedAnimation(Colors.black),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Загрузка фото...',
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
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  )
                      : const Text(
                    'Далее',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Required fields info
              if (!_isFormValid() && !_isUploading)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Заполните все поля и добавьте минимум одно фото',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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
          S3Uploader.uploadFile(image, 'services/images')
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

      // Собираем данные для передачи на следующий экран
      final serviceData = {
        'categoryId': _selectedCategoryId,
        'subcategoryId': _selectedSubcategoryId,
        'cityId': _selectedCityId,
        'title': _serviceNameController.text.trim(),
        'address': _addressController.text.trim(),
        'price': int.parse(_priceController.text.trim()),
        'description': _descriptionController.text.trim(),
        'images': imageUrls,
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
          builder: (context) => ServicePricingScreen(serviceData: serviceData),
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