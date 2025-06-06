import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api/service.dart';
import '../../services/api/apis/wallet.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<PaymentCard> _paymentCards = [];
  bool _isLoading = true;
  String? _error;

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
        title: const Text('Способы оплаты'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true), // Возвращаем true для обновления родительского экрана
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPaymentMethods,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                _buildErrorState()
              else if (_paymentCards.isEmpty)
                  _buildEmptyState()
                else
                  _buildPaymentMethodsList(),

              const SizedBox(height: 24),

              // Add New Card Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddCardDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить карту'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
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

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.credit_card_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'У вас пока нет добавленных карт',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Добавьте карту для удобного пополнения кошелька',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      children: _paymentCards.map((card) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: card.isDefault ? const Color(0xFF2E7D5F) : Colors.grey[200]!,
            width: card.isDefault ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(
            _getCardIcon(card.cardType),
            color: const Color(0xFF2E7D5F),
            size: 28,
          ),
          title: Text(
            card.maskedNumber,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.cardHolder),
              Row(
                children: [
                  Text(
                    card.expiryDate,
                    style: const TextStyle(fontSize: 12),
                  ),
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
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'default':
                  _setDefaultCard(card.id);
                  break;
                case 'delete':
                  _deleteCard(card.id, card.maskedNumber);
                  break;
              }
            },
            itemBuilder: (context) => [
              if (!card.isDefault)
                const PopupMenuItem(
                  value: 'default',
                  child: Row(
                    children: [
                      Icon(Icons.star_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Сделать основной'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Удалить', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: card.isDefault
                ? const Icon(Icons.star, color: Color(0xFF2E7D5F))
                : const Icon(Icons.more_vert),
          ),
        ),
      )).toList(),
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

  Future<void> _setDefaultCard(String cardId) async {
    try {
      final success = await ApiService.wallet.setDefaultPaymentCard(cardId);
      if (success) {
        await _loadPaymentMethods();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Карта установлена как основная'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Не удалось установить карту как основную');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCard(String cardId, String cardNumber) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить карту'),
        content: Text('Вы уверены, что хотите удалить карту $cardNumber?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await ApiService.wallet.deletePaymentCard(cardId);
        if (success) {
          await _loadPaymentMethods();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Карта удалена'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Не удалось удалить карту');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCardDialog(
        onCardAdded: () {
          _loadPaymentMethods();
        },
      ),
    );
  }
}

class AddCardDialog extends StatefulWidget {
  final VoidCallback onCardAdded;

  const AddCardDialog({super.key, required this.onCardAdded});

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить новую карту'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card Number
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Номер карты',
                    hintText: '1234 5678 9012 3456',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19),
                    _CardNumberFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите номер карты';
                    }
                    final digits = value.replaceAll(' ', '');
                    if (digits.length < 13) {
                      return 'Номер карты слишком короткий';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Card Holder
                TextFormField(
                  controller: _cardHolderController,
                  decoration: const InputDecoration(
                    labelText: 'Имя владельца карты',
                    hintText: 'IVAN IVANOV',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите имя владельца карты';
                    }
                    if (value.length < 2) {
                      return 'Имя слишком короткое';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    // Expiry Date
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        decoration: const InputDecoration(
                          labelText: 'Срок действия',
                          hintText: 'MM/YY',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ExpiryDateFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите срок действия';
                          }
                          if (value.length < 5) {
                            return 'Неверный формат';
                          }

                          // Проверка даты
                          final parts = value.split('/');
                          if (parts.length != 2) return 'Неверный формат';

                          final month = int.tryParse(parts[0]);
                          final year = int.tryParse(parts[1]);

                          if (month == null || year == null) return 'Неверный формат';
                          if (month < 1 || month > 12) return 'Неверный месяц';

                          final now = DateTime.now();
                          final expiryDate = DateTime(2000 + year, month);

                          if (expiryDate.isBefore(now)) {
                            return 'Карта просрочена';
                          }

                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // CVV
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите CVV';
                          }
                          if (value.length < 3) {
                            return 'CVV слишком короткий';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addCard,
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Добавить'),
        ),
      ],
    );
  }

  Future<void> _addCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.wallet.addPaymentCard(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardHolder: _cardHolderController.text,
        expiryDate: _expiryDateController.text,
        cvv: _cvvController.text,
      );

      if (result.success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Карта добавлена'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onCardAdded();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Ошибка добавления карты'),
              backgroundColor: Colors.red,
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
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.length == 2 && oldValue.text.length == 1) {
      return TextEditingValue(
        text: '$text/',
        selection: const TextSelection.collapsed(offset: 3),
      );
    }

    return newValue;
  }
}