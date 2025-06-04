import 'package:flutter/material.dart';

class FullGalleryModal extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullGalleryModal({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullGalleryModal> createState() => _FullGalleryModalState();
}

class _FullGalleryModalState extends State<FullGalleryModal> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            '${_currentIndex + 1} из ${widget.images.length}',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // TODO: Implement sharing functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Функция поделиться будет добавлена позже'),
                    backgroundColor: Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Main photo viewer
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Загрузка фото...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                  size: 80,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Не удалось загрузить фото',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Thumbnail strip (only show if more than 1 image)
            if (widget.images.length > 1)
              Container(
                height: 90,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;

                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 74,
                        height: 74,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[800],
                                child: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),

        // Bottom navigation hints
        bottomNavigationBar: Container(
          color: Colors.black,
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe_left, color: Colors.white54, size: 16),
              SizedBox(width: 8),
              Text(
                'Смахните для просмотра других фото',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.swipe_right, color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}