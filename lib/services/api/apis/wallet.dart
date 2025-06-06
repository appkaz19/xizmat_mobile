import 'dart:convert';

import '../core.dart';

class PaymentCard {
  final String id;
  final String last4;
  final String cardHolder;
  final String cardType;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;

  PaymentCard({
    required this.id,
    required this.last4,
    required this.cardHolder,
    required this.cardType,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'],
      last4: json['last4'],
      cardHolder: json['cardHolder'],
      cardType: json['cardType'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  String get expiryDate => '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}';
  String get maskedNumber => '•••• •••• •••• $last4';
}

class TopUpResult {
  final bool success;
  final String? message;
  final String? transactionId;
  final int? newBalance;

  TopUpResult({
    required this.success,
    this.message,
    this.transactionId,
    this.newBalance,
  });

  factory TopUpResult.fromJson(int statusCode, String body) {
    try {
      final json = jsonDecode(body);

      if (statusCode == 200) {
        return TopUpResult(
          success: json['success'] ?? true,
          message: json['message'],
          transactionId: json['transactionId'],
          newBalance: json['newBalance'],
        );
      } else {
        return TopUpResult(
          success: false,
          message: json['error'] ?? 'Ошибка пополнения',
        );
      }
    } catch (e) {
      return TopUpResult(success: false, message: 'Ошибка разбора ответа');
    }
  }
}

class AddCardResult {
  final bool success;
  final String? message;
  final PaymentCard? card;

  AddCardResult({
    required this.success,
    this.message,
    this.card,
  });

  factory AddCardResult.fromJson(int statusCode, String body) {
    try {
      final json = jsonDecode(body);

      if (statusCode == 200) {
        return AddCardResult(
          success: true,
          message: json['message'],
          card: json['card'] != null ? PaymentCard.fromJson(json['card']) : null,
        );
      } else {
        return AddCardResult(
          success: false,
          message: json['error'] ?? 'Ошибка добавления карты',
        );
      }
    } catch (e) {
      return AddCardResult(success: false, message: 'Ошибка разбора ответа');
    }
  }
}

class WalletApi {
  Future<Map<String, dynamic>?> getWallet() async {
    final res = await CoreApi.sendRequest(
        path: '/wallet',
        method: 'GET',
        auth: true
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }

  Future<List<PaymentCard>> getPaymentMethods() async {
    final res = await CoreApi.sendRequest(
      path: '/wallet/payment-methods',
      method: 'GET',
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final json = jsonDecode(responseString);
      final List<dynamic> cardsJson = json['cards'] ?? [];

      return cardsJson.map((cardJson) => PaymentCard.fromJson(cardJson)).toList();
    }

    return [];
  }

  Future<AddCardResult> addPaymentCard({
    required String cardNumber,
    required String cardHolder,
    required String expiryDate,
    required String cvv,
  }) async {
    final res = await CoreApi.sendRequest(
      path: '/wallet/payment-methods',
      method: 'POST',
      auth: true,
      body: {
        'cardNumber': cardNumber,
        'cardHolder': cardHolder,
        'expiryDate': expiryDate,
        'cvv': cvv,
      },
    );

    final body = await res.transform(utf8.decoder).join();
    return AddCardResult.fromJson(res.statusCode, body);
  }

  Future<bool> deletePaymentCard(String cardId) async {
    final res = await CoreApi.sendRequest(
      path: '/wallet/payment-methods/$cardId',
      method: 'DELETE',
      auth: true,
    );

    return res.statusCode == 200;
  }

  Future<bool> setDefaultPaymentCard(String cardId) async {
    final res = await CoreApi.sendRequest(
      path: '/wallet/payment-methods/$cardId/set-default',
      method: 'POST',
      auth: true,
    );

    return res.statusCode == 200;
  }

  Future<TopUpResult> topUpWallet({
    required int amount,
    required String paymentMethodId,
  }) async {
    final res = await CoreApi.sendRequest(
      path: '/wallet/top-up',
      method: 'POST',
      auth: true,
      body: {
        'amount': amount,
        'paymentMethodId': paymentMethodId,
      },
    );

    final body = await res.transform(utf8.decoder).join();
    return TopUpResult.fromJson(res.statusCode, body);
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory({int limit = 50, int offset = 0}) async {
    final res = await CoreApi.sendRequest(
      path: '/wallet/transactions?limit=$limit&offset=$offset',
      method: 'GET',
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final json = jsonDecode(responseString);
      return List<Map<String, dynamic>>.from(json['transactions'] ?? []);
    }

    return [];
  }

  // Дополнительные методы для работы с кошельком
  Future<Map<String, dynamic>?> spendFromWallet({
    required int amount,
    String? description,
  }) async {
    final res = await CoreApi.sendRequest(
      path: '/wallet/spend',
      method: 'POST',
      auth: true,
      body: {
        'amount': amount,
        if (description != null) 'description': description,
      },
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }
}