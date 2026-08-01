import 'package:flutter/material.dart';
import '../../../core/ac_chat.dart';

class VideoMessageBubble extends StatelessWidget {
  final AcChatMessage message;
  final AcChatTheme ct;

  const VideoMessageBubble({
    super.key,
    required this.message,
    required this.ct,
  });

  @override
  Widget build(BuildContext context) {
    Widget posterWidget;

    if (message.byteData != null) {
      posterWidget = Image.memory(
        message.byteData!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: ct.black12,
          child: Icon(Icons.video_collection, size: 48, color: ct.subText),
        ),
      );
    } else {
      // Choose a nice thumbnail matching the video URL or message content
      String thumbUrl = 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400';
      if (message.text.contains('BigBuckBunny')) {
        thumbUrl = 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400'; // bunny/forest-like
      } else if (message.text.contains('ForBiggerBlazes')) {
        thumbUrl = 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400'; // receipt/flame-like/finance
      }

      posterWidget = Image.network(
        thumbUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: ct.black12,
          child: Icon(Icons.video_collection, size: 48, color: ct.subText),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ct.subText.withOpacity(0.5)),
              ),
            ),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 240,
        height: 160,
        color: ct.subText.withOpacity(0.15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            posterWidget,
            // Play overlay button
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ct.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                  border: Border.all(color: ct.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: ct.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: ct.white,
                  size: 32,
                ),
              ),
            ),
            // Video Caption or Duration
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ct.transparent, ct.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        message.mediaCaption ?? 'Video clip',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ct.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ct.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_fill, size: 10, color: ct.white70),
                          const SizedBox(width: 3),
                          Text(
                            message.duration ?? '0:15',
                            style: TextStyle(color: ct.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
