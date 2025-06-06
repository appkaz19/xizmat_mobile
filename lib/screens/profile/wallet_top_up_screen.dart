import 'package:flutter/material.dart';
import '../../services/api/service.dart';
import '../../services/api/apis/wallet.dart';

class WalletTopUpScreen extends StatefulWidget {
  const WalletTopUpScreen({super.key});

  @override
  State<WalletTopUpScreen> createState() => _WalletTopUpScreenState();
}

class _WalletTopUpScreenState extends State<WalletTopUpScreen> {
  int _selectedAmount = 1000;
  String? _selectedPaymentMethodId;
  List<PaymentCard> _paymentCards = [];
  bool _isLoading = true;
  bool _isTopUpLoading = false;
  String? _error;

  final List<int> amounts = [500, 1000, 2000, 5000, 10000, 20000];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final cards = await ApiService.wallet.getPaymentMethods();

      setState(() {
        _paymentCards = cards;
        _isLoading = false;

        // Автоматически выбираем основную карту или первую доступную
        if (cards.isNotEmpty) {
          final defaultCard = cards.firstWhere(
                (card) => card.isDefault,
            orElse: () => cards.first,
          );
          _selectedPaymentMethodId = defaultCard.id;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки способов оплаты: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : _paymentCards.isEmpty
          ? _buildNoCardsState()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPaymentMethods,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCardsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Нет добавленных карт',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Добавьте карту для пополнения кошелька',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/wallet');
                if (result == true) {
                  _loadPaymentMethods();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Добавить карту'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount Selection
          const Text(
            'Выберите сумму',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

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

          ..._paymentCards.map((card) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedPaymentMethodId == card.id
                    ? const Color(0xFF2E7D5F)
                    : Colors.grey[300]!,
                width: _selectedPaymentMethodId == card.id ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: _selectedPaymentMethodId == card.id
                  ? const Color(0xFF2E7D5F).withOpacity(0.1)
                  : Colors.white,
            ),
            child: RadioListTile<String>(
              value: card.id,
              groupValue: _selectedPaymentMethodId,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethodId = value;
                });
              },
              title: Text(card.maskedNumber),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.cardHolder),
                  Row(
                    children: [
                      Text(card.expiryDate),
                      if (card.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D5F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Основная',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              secondary: Icon(
                _getCardIcon(card.cardType),
                color: const Color(0xFF2E7D5F),
              ),
              activeColor: const Color(0xFF2E7D5F),
            ),
          )),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(context, '/wallet');
                    if (result == true) {
                      _loadPaymentMethods();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить карту'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Top Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedPaymentMethodId != null && !_isTopUpLoading
                  ? _topUpWallet
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isTopUpLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Пополнить на $_selectedAmount монет',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Средства поступят на ваш кошелек мгновенно после успешной оплаты',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'uzcard':
        return Icons.credit_card;
      case 'humo':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  Future<void> _topUpWallet() async {
    if (_selectedPaymentMethodId == null) return;

    final selectedCard = _paymentCards.firstWhere(
          (card) => card.id == _selectedPaymentMethodId,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение пополнения'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сумма: $_selectedAmount монет'),
            const SizedBox(height: 8),
            Text('Карта: ${selectedCard.maskedNumber}'),
            const SizedBox(height: 8),
            Text('Владелец: ${selectedCard.cardHolder}'),
            const SizedBox(height: 16),
            const Text(
              'Подтвердите пополнение кошелька',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Оплатить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isTopUpLoading = true;
      });

      try {
        final result = await ApiService.wallet.topUpWallet(
          amount: _selectedAmount,
          paymentMethodId: _selectedPaymentMethodId!,
        );

        if (result.success) {
          if (mounted) {
            Navigator.pop(context, {
              'success': true,
              'amount': _selectedAmount,
              'newBalance': result.newBalance,
              'transactionId': result.transactionId,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result.message ?? 'Кошелек пополнен на $_selectedAmount монет',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message ?? 'Ошибка пополнения кошелька'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isTopUpLoading = false;
          });
        }
      }
    }
  }
}