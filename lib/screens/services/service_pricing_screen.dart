import 'package:flutter/material.dart';
import 'service_payment_screen.dart';

class ServicePricingScreen extends StatefulWidget {
  const ServicePricingScreen({super.key});

  @override
  State<ServicePricingScreen> createState() => _ServicePricingScreenState();
}

class _ServicePricingScreenState extends State<ServicePricingScreen> {
  String? _selectedPlan;

  final List<Map<String, dynamic>> pricingPlans = [
    {
      'id': 'light',
      'title': 'Легкий старт',
      'subtitle': '(4x просмотров)',
      'price': 700,
      'features': [
        'ТОП-объявление на 3 дня',
        'Поднятие в верх списка',
        'VIP-объявление',
      ],
      'icon': '💡',
    },
    {
      'id': 'fast',
      'title': 'Быстрая продажа',
      'subtitle': '(16x просмотров)',
      'price': 1500,
      'features': [
        'ТОП-объявление на 7 дней',
        '3 поднятия в верх списка',
        'VIP-объявление',
      ],
      'icon': '⚡',
    },
    {
      'id': 'turbo',
      'title': 'Турбо продажа',
      'subtitle': '(30x просмотров)',
      'price': 3000,
      'features': [
        'ТОП-объявление на 30 дней',
        '9 поднятий в верх списка',
        'VIP-объявление на 7 дней',
      ],
      'icon': '🚀',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Добавление услуги'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show help
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Наборы платных услуг',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Pricing Plans
            ...pricingPlans.map((plan) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedPlan == plan['id']
                      ? const Color(0xFF2E7D5F)
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${plan['price']} монет',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                              const Icon(
                                Icons.check,
                                size: 16,
                                color: Color(0xFF2E7D5F),
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
                activeColor: const Color(0xFF2E7D5F),
                contentPadding: const EdgeInsets.all(16),
              ),
            )),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Publish without paid services
                      _showSuccessDialog();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF2E7D5F)),
                    ),
                    child: const Text(
                      'Опубликовать\nбез услуг',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF2E7D5F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedPlan != null ? _proceedToPayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedPlan != null
                          ? const Color(0xFFFFC107)
                          : Colors.grey,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Опубликовать\nс услугой',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToPayment() {
    final selectedPlan = pricingPlans.firstWhere(
          (plan) => plan['id'] == _selectedPlan,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicePaymentScreen(
          planTitle: selectedPlan['title'],
          planPrice: selectedPlan['price'],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Успешно!'),
        content: const Text('Ваша услуга успешно опубликована!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}