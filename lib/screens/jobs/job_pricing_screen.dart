import 'package:flutter/material.dart';
import '../../services/api/service.dart';
import '../../utils/app_theme.dart';

class JobPricingScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;

  const JobPricingScreen({
    super.key,
    required this.jobData,
  });

  @override
  State<JobPricingScreen> createState() => _JobPricingScreenState();
}

class _JobPricingScreenState extends State<JobPricingScreen> {
  String? _selectedPlan;
  bool _isCreatingJob = false;

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
        title: const Text('Публикация объявления'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.work_outline,
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
                          widget.jobData['title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'до ${widget.jobData['price']} тенге',
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
                      ? Colors.orange
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
                          color: Colors.amber,
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
                                color: plan['price'] > 0 ? Colors.orange : Colors.green,
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
                activeColor: Colors.orange,
                contentPadding: const EdgeInsets.all(16),
              ),
            )),

            const SizedBox(height: 32),

            // Publish Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreatingJob ? null : _publishJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCreatingJob ? Colors.grey : Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isCreatingJob
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
                        'Ваше объявление будет продвигаться ${_getSelectedPlan()['days']} дней',
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
    );
  }

  Map<String, dynamic> _getSelectedPlan() {
    return pricingPlans.firstWhere((plan) => plan['id'] == _selectedPlan);
  }

  Future<void> _publishJob() async {
    setState(() => _isCreatingJob = true);

    try {
      // Создаем объявление
      final jobResponse = await ApiService.job.createJob(widget.jobData);

      if (jobResponse == null) {
        throw Exception('Не удалось создать объявление');
      }

      final jobId = jobResponse['id'];
      final selectedPlan = _getSelectedPlan();

      // Если выбран платный план, продвигаем объявление
      if (selectedPlan['price'] > 0 && selectedPlan['days'] > 0) {
        final promoteSuccess = await ApiService.job.promoteJob(
          jobId,
          selectedPlan['days'],
        );

        if (!promoteSuccess) {
          // Объявление создано, но продвижение не удалось
          _showPartialSuccessDialog();
          return;
        }
      }

      // Все прошло успешно
      _showSuccessDialog();

    } catch (e) {
      setState(() => _isCreatingJob = false);
      print('Ошибка публикации объявления: $e');

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
              ? 'Ваше объявление успешно опубликовано и продвигается ${selectedPlan['days']} дней!'
              : 'Ваше объявление успешно опубликовано!',
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
          'Объявление опубликовано, но продвижение не удалось. Возможно, недостаточно монет на счету.',
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