import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/ac_chat.dart';

class ImageMessageBubble extends StatelessWidget {
  final AcChatMessage message;
  final AcChatTheme ct;
  const ImageMessageBubble({required this.message, required this.ct});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    final localFilePath = message.localPath;
    final remoteUrl = (message.filePath != null && message.filePath!.startsWith('http'))
        ? message.filePath
        : (message.fileUrl ?? (message.text.startsWith('http') ? message.text : null));

    if (message.byteData != null && message.byteData!.isNotEmpty) {
      imageWidget = Image.memory(
        message.byteData!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
      );
    } else if (!kIsWeb &&
        localFilePath != null &&
        localFilePath.isNotEmpty &&
        io.File(localFilePath).existsSync()) {
      imageWidget = Image.file(
        io.File(localFilePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
      );
    } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
      imageWidget = Image.network(
        remoteUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoader();
        },
      );
    } else {
      imageWidget = _buildErrorIcon();
    }

    final captionText = message.mediaCaption ?? (message.text.isNotEmpty && !message.text.startsWith('http') ? message.text : null);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 200,
        height: 160,
        color: ct.subText.withOpacity(0.15),
        child: Stack(children: [
          Positioned.fill(child: imageWidget),
          if (captionText != null && captionText.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: ct.black.withOpacity(0.5),
                padding: const EdgeInsets.all(6),
                child: Text(
                  captionText,
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