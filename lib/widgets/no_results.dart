import 'package:flutter/material.dart';

class NoResults extends StatelessWidget {
  final VoidCallback onRetry;

  const NoResults({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const NoResultsIllustration(),
          const SizedBox(height: 24),
          const NoResultsTitle(),
          const SizedBox(height: 8),
          const NoResultsDescription(),
          const SizedBox(height: 24),
          RetryButton(onRetry: onRetry),
        ],
      ),
    );
  }
}

class NoResultsIllustration extends StatelessWidget {
  const NoResultsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D5F),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sentiment_dissatisfied,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Icon(
            Icons.search_off,
            size: 30,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class NoResultsTitle extends StatelessWidget {
  const NoResultsTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Ничего не найдено',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class NoResultsDescription extends StatelessWidget {
  const NoResultsDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        'К сожалению, по вашему запросу ничего не найдено. Попробуйте изменить ключевое слово или настройки фильтра.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey[600],
          height: 1.5,
        ),
      ),
    );
  }
}

class RetryButton extends StatelessWidget {
  final VoidCallback onRetry;

  const RetryButton({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onRetry,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D5F),
        foregroundColor: Colors.white,
      ),
      child: const Text('Попробовать другой запрос'),
    );
  }
}