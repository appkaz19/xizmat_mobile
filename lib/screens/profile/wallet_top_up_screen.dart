import 'package:flutter/material.dart';

class WalletTopUpScreen extends StatefulWidget {
  const WalletTopUpScreen({super.key});

  @override
  State<WalletTopUpScreen> createState() => _WalletTopUpScreenState();
}

class _WalletTopUpScreenState extends State<WalletTopUpScreen> {
  int _selectedAmount = 1000;
  String _selectedPaymentMethod = 'PayPal';

  final List<int> amounts = [500, 1000, 2000, 5000, 10000, 20000];

  final List<Map<String, dynamic>> paymentMethods = [
    {'name': 'PayPal', 'icon': Icons.paypal},
    {'name': 'Apple Pay', 'icon': Icons.apple},
    {'name': 'Google Pay', 'icon': Icons.payment},
    {'name': '•••• •••• •••• 4679', 'icon': Icons.credit_card},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пополнение кошелька'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Selection
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: amounts.length,
              itemBuilder: (context, index) {
                final amount = amounts[index];
                final isSelected = amount == _selectedAmount;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAmount = amount;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2E7D5F)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? const Color(0xFF2E7D5F).withOpacity(0.1)
                          : Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2E7D5F),
                            size: 20,
                          ),
                        if (isSelected) const SizedBox(width: 8),
                        Text(
                          '$amount монет',
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF2E7D5F)
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Payment Method Selection
            const Text(
              'Выберите способ оплаты',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ...paymentMethods.map((method) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                value: method['name'],
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
                title: Text(method['name']),
                secondary: Icon(
                  method['icon'],
                  color: const Color(0xFF2E7D5F),
                ),
                activeColor: const Color(0xFF2E7D5F),
              ),
            )),

            const SizedBox(height: 32),

            // Top Up Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _topUpWallet,
                child: const Text('Пополнить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _topUpWallet() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пополнение кошелька'),
        content: Text(
          'Пополнить кошелек на $_selectedAmount монет через $_selectedPaymentMethod?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Кошелек пополнен на $_selectedAmount монет'),
                ),
              );
            },
            child: const Text('Оплатить'),
          ),
        ],
      ),
    );
  }
}