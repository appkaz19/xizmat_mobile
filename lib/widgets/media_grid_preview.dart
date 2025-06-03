import 'package:flutter/material.dart';
import 'video_thumbnail_widget.dart';

class MediaGridPreview extends StatelessWidget {
  final List<dynamic> media;
  final Function(List<dynamic>) onTap;

  const MediaGridPreview({
    super.key,
    required this.media,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: media.length > 6 ? 6 : media.length,
        itemBuilder: (context, index) {
          final item = media[index];
          final isLast = index == 5 && media.length > 6;

          return GestureDetector(
            onTap: () => onTap(media),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item['type'] == 'video'
                        ? VideoThumbnailWidget(
                      videoUrl: item['url'],
                      width: double.infinity,
                      height: double.infinity,
                      showPlayIcon: false,
                      showVideoIcon: true,
                    )
                        : Image.network(
                      item['url'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  if (isLast)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withOpacity(0.6),
                      ),
                      child: Center(
                        child: Text(
                          '+${media.length - 5}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}