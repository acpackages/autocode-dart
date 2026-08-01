import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/ac_chat.dart';
import '../../../common/chat_colors.dart';

class ImageMessageBubble extends StatelessWidget {
  final AcChatMessage message;
  final AcChatTheme ct;
  const ImageMessageBubble({required this.message, required this.ct});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (message.byteData != null) {
      imageWidget = Image.memory(
        message.byteData!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
      );
    } else {
      final pathOrUrl = message.text;
      if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
        imageWidget = Image.network(
          pathOrUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoader();
          },
        );
      } else if (!kIsWeb && pathOrUrl.isNotEmpty) {
        imageWidget = Image.file(
          io.File(pathOrUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
        );
      } else {
        imageWidget = _buildErrorIcon();
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 200,
        height: 160,
        color: ct.subText.withOpacity(0.15),
        child: Stack(children: [
          Positioned.fill(child: imageWidget),
          if (message.mediaCaption != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: ct.black.withOpacity(0.5),
                padding: const EdgeInsets.all(6),
                child: Text(
                  message.mediaCaption!,
                  style: TextStyle(color: ct.white, fontSize: 12),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return Center(
      child: Icon(Icons.image_rounded, size: 48, color: ct.subText),
    );
  }

  Widget _buildLoader() {
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
  }
}