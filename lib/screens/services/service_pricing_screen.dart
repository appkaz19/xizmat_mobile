import 'package:flutter/material.dart';
import '../../services/api/service.dart';
import '../../utils/app_theme.dart';

class ServicePricingScreen extends StatefulWidget {
  final Map<String, dynamic> serviceData;

  const ServicePricingScreen({
    super.key,
    required this.serviceData,
  });

  @override
  State<ServicePricingScreen> createState() => _ServicePricingScreenState();
}

class _ServicePricingScreenState extends State<ServicePricingScreen> {
  String? _selectedPlan;
  bool _isCreatingService = false;

  final List<Map<String, dynamic>> pricingPlans = [
    {
      'id': 'free',
      'title': 'Бесплатная публикация',
      'subtitle': 'Без продвижения',
      'price': 0,
      'days': 0,
      'features': [
        'Обычное размещение',
        'Стандартная видимость',
        'Без временных ограничений',
      ],
      'icon': '📝',
    },
    {
      'id': 'basic',
      'title': 'Базовое продвижение',
      'subtitle': 'Повышенная видимость',
      'price': 400,
      'days': 3,
      'features': [
        'ТОП размещение на 3 дня',
        'Повышенная видимость',
        'Больше просмотров',
      ],
      'icon': '⭐',
    },
    {
      'id': 'premium',
      'title': 'Премиум продвижение',
      'subtitle': 'Максимальная видимость',
      'price': 600,
      'days': 7,
      'features': [
        'ТОП размещение на 7 дней',
        'Максимальная видимость',
        'Приоритетный показ',
      ],
      'icon': '🚀',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlan = 'free'; // По умолчанию выбрана бесплатная публикация
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Публикация услуги'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.build,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceData['title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.serviceData['price']} тенге',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Выберите тип публикации',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Pricing Plans
            ...pricingPlans.map((plan) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedPlan == plan['id']
                      ? AppColors.primary
                      : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                value: plan['id'],
                groupValue: _selectedPlan,
                onChanged: (value) {
                  setState(() {
                    _selectedPlan = value;
                  });
                },
                title: Row(
                  children: [
                    Text(
                      plan['icon'],
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            plan['subtitle'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (plan['price'] > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${plan['price']} монет',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Бесплатно',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 36, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (plan['features'] as List<String>).map((feature) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                size: 16,
                                color: plan['price'] > 0 ? AppColors.primary : Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                feature,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                    ).toList(),
                  ),
                ),
                activeColor: AppColors.primary,
                contentPadding: const EdgeInsets.all(16),
              ),
            )),

            const SizedBox(height: 32),

            // Publish Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreatingService ? null : _publishService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCreatingService ? Colors.grey : AppColors.secondary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isCreatingService
                    ? const Row(
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
                      'Публикация...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    : Text(
                  _getSelectedPlan()['price'] > 0
                      ? 'Опубликовать за ${_getSelectedPlan()['price']} монет'
                      : 'Опубликовать бесплатно',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info about selected plan
            if (_getSelectedPlan()['price'] > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ваша услуга будет продвигаться ${_getSelectedPlan()['days']} дней',
                        style: TextStyle(
                          color: AppColors.primary,
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
    );
  }

  Map<String, dynamic> _getSelectedPlan() {
    return pricingPlans.firstWhere((plan) => plan['id'] == _selectedPlan);
  }

  Future<void> _publishService() async {
    setState(() => _isCreatingService = true);

    try {
      // Создаем услугу
      final serviceResponse = await ApiService.service.createService(widget.serviceData);

      if (serviceResponse == null) {
        throw Exception('Не удалось создать услугу');
      }

      final serviceId = serviceResponse['id'];
      final selectedPlan = _getSelectedPlan();

      // Если выбран платный план, продвигаем услугу
      if (selectedPlan['price'] > 0 && selectedPlan['days'] > 0) {
        final promoteSuccess = await ApiService.service.promoteService(
          serviceId,
          selectedPlan['days'],
        );

        if (!promoteSuccess) {
          // Услуга создана, но продвижение не удалось
          _showPartialSuccessDialog();
          return;
        }
      }

      // Все прошло успешно
      _showSuccessDialog();

    } catch (e) {
      setState(() => _isCreatingService = false);
      print('Ошибка публикации услуги: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка публикации: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    final selectedPlan = _getSelectedPlan();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Успешно!'),
        content: Text(
          selectedPlan['price'] > 0
              ? 'Ваша услуга успешно опубликована и продвигается ${selectedPlan['days']} дней!'
              : 'Ваша услуга успешно опубликована!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Отлично!'),
          ),
        ],
      ),
    );
  }

  void _showPartialSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text('Частично успешно'),
        content: const Text(
          'Услуга опубликована, но продвижение не удалось. Возможно, недостаточно монет на счету.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}