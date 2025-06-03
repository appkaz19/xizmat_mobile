import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoManager {
  static final VideoManager _instance = VideoManager._internal();
  factory VideoManager() => _instance;
  VideoManager._internal();

  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<String, ChewieController> _chewieControllers = {};
  final Map<String, Uint8List?> _thumbnails = {};
  final Map<String, bool> _isInitialized = {};

  // Получить или создать VideoController
  Future<VideoPlayerController?> getVideoController(String videoUrl) async {
    if (_videoControllers.containsKey(videoUrl)) {
      return _videoControllers[videoUrl];
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();

      _videoControllers[videoUrl] = controller;
      _isInitialized[videoUrl] = true;

      return controller;
    } catch (e) {
      print('Ошибка инициализации видео: $e');
      _isInitialized[videoUrl] = false;
      return null;
    }
  }

  // Получить или создать ChewieController
  Future<ChewieController?> getChewieController(String videoUrl, {
    bool autoPlay = false,
    bool showControls = true,
    Color? primaryColor,
  }) async {
    final controllerKey = '${videoUrl}_${autoPlay}_$showControls';

    if (_chewieControllers.containsKey(controllerKey)) {
      return _chewieControllers[controllerKey];
    }

    final videoController = await getVideoController(videoUrl);
    if (videoController == null) return null;

    final chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: autoPlay,
      looping: false,
      showControls: showControls,
      aspectRatio: videoController.value.aspectRatio,
      materialProgressColors: primaryColor != null
          ? ChewieProgressColors(
        playedColor: primaryColor,
        handleColor: primaryColor,
      )
          : null,
    );

    _chewieControllers[controllerKey] = chewieController;
    return chewieController;
  }

  // Получить превью видео
  Future<Uint8List?> getVideoThumbnail(String videoUrl) async {
    if (_thumbnails.containsKey(videoUrl)) {
      return _thumbnails[videoUrl];
    }

    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        maxHeight: 300,
        quality: 85,
      );

      _thumbnails[videoUrl] = thumbnail;
      return thumbnail;
    } catch (e) {
      print('Ошибка генерации превью: $e');
      _thumbnails[videoUrl] = null;
      return null;
    }
  }

  // Проверить инициализацию видео
  bool isVideoInitialized(String videoUrl) {
    return _isInitialized[videoUrl] ?? false;
  }

  // Остановить все видео
  void pauseAllVideos() {
    for (final controller in _videoControllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  // Остановить конкретное видео
  void pauseVideo(String videoUrl) {
    final controller = _videoControllers[videoUrl];
    if (controller != null && controller.value.isPlaying) {
      controller.pause();
    }
  }

  // Очистить ресурсы (вызывать при закрытии экрана)
  void dispose() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    for (final controller in _chewieControllers.values) {
      controller.dispose();
    }

    _videoControllers.clear();
    _chewieControllers.clear();
    _thumbnails.clear();
    _isInitialized.clear();
  }

  // Очистить конкретное видео
  void disposeVideo(String videoUrl) {
    final videoController = _videoControllers.remove(videoUrl);
    videoController?.dispose();

    // Удаляем все chewie контроллеры для этого видео
    final keysToRemove = _chewieControllers.keys
        .where((key) => key.startsWith(videoUrl))
        .toList();

    for (final key in keysToRemove) {
      final chewieController = _chewieControllers.remove(key);
      chewieController?.dispose();
    }

    _thumbnails.remove(videoUrl);
    _isInitialized.remove(videoUrl);
  }
}