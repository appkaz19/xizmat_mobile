import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../utils/app_theme.dart';

class ServiceMediaCarousel extends StatefulWidget {
  final List<dynamic> media;

  const ServiceMediaCarousel({super.key, required this.media});

  @override
  State<ServiceMediaCarousel> createState() => _ServiceMediaCarouselState();
}

class _ServiceMediaCarouselState extends State<ServiceMediaCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeVideoControllers();
  }

  Future<void> _initializeVideoControllers() async {
    for (int i = 0; i < widget.media.length; i++) {
      final item = widget.media[i];
      if (item['type'] == 'video') {
        try {
          final videoController = VideoPlayerController.networkUrl(Uri.parse(item['url']));
          await videoController.initialize();

          final chewieController = ChewieController(
            videoPlayerController: videoController,
            autoPlay: false,
            looping: false,
            aspectRatio: videoController.value.aspectRatio,
            showControls: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: AppColors.primary,
              handleColor: AppColors.primary,
            ),
          );

          _videoControllers[i] = videoController;
          _chewieControllers[i] = chewieController;
        } catch (e) {
          print('Ошибка инициализации видео $i: $e');
        }
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    for (final controller in _chewieControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.media.length,
          onPageChanged: (index) {
            setState(() => _currentPage = index);

            // Останавливаем все видео при смене страницы
            for (final controller in _videoControllers.values) {
              if (controller.value.isPlaying) {
                controller.pause();
              }
            }
          },
          itemBuilder: (context, index) {
            final item = widget.media[index];

            if (item['type'] == 'video') {
              final chewieController = _chewieControllers[index];
              if (chewieController != null) {
                return Container(
                  color: Colors.black,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: chewieController.videoPlayerController.value.aspectRatio,
                      child: Chewie(controller: chewieController),
                    ),
                  ),
                );
              } else {
                return Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }
            }

            return Image.network(
              item['url'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 80, color: Colors.grey),
                );
              },
            );
          },
        ),

        // Page indicators
        if (widget.media.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.media.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}