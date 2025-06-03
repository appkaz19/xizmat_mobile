import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../utils/video_manager.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool showPlayIcon;
  final bool showVideoIcon;
  final VoidCallback? onTap;

  const VideoThumbnailWidget({
    super.key,
    required this.videoUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.showPlayIcon = true,
    this.showVideoIcon = true,
    this.onTap,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Uint8List? _thumbnail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final thumbnail = await VideoManager().getVideoThumbnail(widget.videoUrl);
    if (mounted) {
      setState(() {
        _thumbnail = thumbnail;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Фон/превью
            if (_isLoading)
              Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (_thumbnail != null)
              Image.memory(
                _thumbnail!,
                fit: widget.fit,
                width: widget.width,
                height: widget.height,
              )
            else
              Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

            // Иконка воспроизведения по центру
            if (widget.showPlayIcon)
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 60,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),

            // Иконка видео в углу
            if (widget.showVideoIcon)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 20,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}