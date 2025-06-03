import 'package:flutter/material.dart';
import '../../../utils/video_manager.dart';
import 'video_thumbnail_widget.dart';
import 'package:chewie/chewie.dart';

class FullGalleryModal extends StatefulWidget {
  final List<dynamic> media;

  const FullGalleryModal({super.key, required this.media});

  @override
  State<FullGalleryModal> createState() => _FullGalleryModalState();
}

class _FullGalleryModalState extends State<FullGalleryModal> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            '${_currentIndex + 1} из ${widget.media.length}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.media.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = widget.media[index];
                  return Center(
                    child: item['type'] == 'video'
                        ? FullScreenVideoPlayer(videoUrl: item['url'])
                        : InteractiveViewer(
                      child: Image.network(
                        item['url'],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 60,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            // Thumbnail strip
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.media.length,
                itemBuilder: (context, index) {
                  final item = widget.media[index];
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
                      width: 64,
                      height: 64,
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
                        child: item['type'] == 'video'
                            ? VideoThumbnailWidget(
                          videoUrl: item['url'],
                          width: 64,
                          height: 64,
                          showPlayIcon: false,
                          showVideoIcon: true,
                        )
                            : Image.network(
                          item['url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image,
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
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({super.key, required this.videoUrl});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
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
      autoPlay: false,
      showControls: true,
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
        fit: BoxFit.contain,
        onTap: _showVideoPlayer,
        showPlayIcon: true,
        showVideoIcon: false,
      );
    }

    // Показываем плеер
    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _chewieController = await VideoManager().getChewieController(widget.videoUrl);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _chewieController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }
}