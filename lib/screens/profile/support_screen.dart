import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> faqItems = [
    {
      'question': 'Что такое QYZMET?',
      'answer': 'QYZMET — это платформа, которая соединяет исполнителей и заказчиков услуг. У нас не требуется оплата через приложение.',
    },
    {
      'question': 'Как пользоваться QYZMET?',
      'answer': 'Зарегистрируйтесь, найдите нужную услугу или разместите объявление, свяжитесь с исполнителем напрямую.',
    },
    {
      'question': 'Как разместить вакансию или объявление?',
      'answer': 'Перейдите в раздел "Добавить услугу" и заполните форму с описанием вашей задачи.',
    },
    {
      'question': 'Как найти специалиста?',
      'answer': 'Используйте поиск по категориям или введите ключевые слова в строку поиска.',
    },
    {
      'question': 'Нужно ли платить за использование QYZMET?',
      'answer': 'Базовое использование приложения бесплатно. Премиум функции доступны по подписке.',
    },
  ];

  final List<Map<String, dynamic>> contactOptions = [
    {
      'title': 'Служба поддержки',
      'icon': Icons.headset_mic,
      'action': 'chat',
    },
    {
      'title': 'WhatsApp',
      'icon': Icons.message,
      'action': 'whatsapp',
    },
    {
      'title': 'Веб-сайт',
      'icon': Icons.language,
      'action': 'website',
    },
    {
      'title': 'Facebook',
      'icon': Icons.facebook,
      'action': 'facebook',
    },
    {
      'title': 'Twitter',
      'icon': Icons.alternate_email,
      'action': 'twitter',
    },
    {
      'title': 'Instagram',
      'icon': Icons.camera_alt,
      'action': 'instagram',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Служба поддержки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Частые вопросы'),
            Tab(text: 'Связаться с нами'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Category Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildCategoryChip('Общие', true),
                const SizedBox(width: 8),
                _buildCategoryChip('Аккаунт', false),
                const SizedBox(width: 8),
                _buildCategoryChip('Сервис', false),
                const SizedBox(width: 8),
                _buildCategoryChip('Оплата', false),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.tune),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // FAQ Items
          ...faqItems.map((item) => _buildFAQItem(item['question']!, item['answer']!)),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...contactOptions.map((option) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ListTile(
              leading: Icon(
                option['icon'],
                color: const Color(0xFF2E7D5F),
              ),
              title: Text(option['title']),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Handle contact option tap
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Открываем ${option['title']}')),
                );
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2E7D5F) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}