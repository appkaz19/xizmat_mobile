import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/video_manager.dart';
import 'video_thumbnail_widget.dart';
import 'package:chewie/chewie.dart';

class ServiceMediaCarousel extends StatefulWidget {
  final List<dynamic> media;

  const ServiceMediaCarousel({super.key, required this.media});

  @override
  State<ServiceMediaCarousel> createState() => _ServiceMediaCarouselState();
}

class _ServiceMediaCarouselState extends State<ServiceMediaCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final VideoManager _videoManager = VideoManager();

  @override
  void dispose() {
    _pageController.dispose();
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
            _videoManager.pauseAllVideos();
          },
          itemBuilder: (context, index) {
            final item = widget.media[index];

            if (item['type'] == 'video') {
              return VideoCarouselItem(videoUrl: item['url']);
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

// Компонент для отображения видео в карусели
class VideoCarouselItem extends StatefulWidget {
  final String videoUrl;

  const VideoCarouselItem({super.key, required this.videoUrl});

  @override
  State<VideoCarouselItem> createState() => _VideoCarouselItemState();
}

class _VideoCarouselItemState extends State<VideoCarouselItem> {
  ChewieController? _chewieController;
  bool _showPlayer = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _chewieController = await VideoManager().getChewieController(
      widget.videoUrl,
      primaryColor: AppColors.primary,
    );
    if (mounted) setState(() {});
  }

  void _showVideoPlayer() {
    setState(() {
      _showPlayer = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showPlayer) {
      // Показываем превью с кнопкой воспроизведения
      return VideoThumbnailWidget(
        videoUrl: widget.videoUrl,
        fit: BoxFit.cover,
        onTap: _showVideoPlayer,
      );
    }

    // Показываем плеер
    if (_chewieController != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: AspectRatio(
            aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}