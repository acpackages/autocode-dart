import 'dart:async';
import 'package:ac_chat_core/ac_chat_core.dart';
import 'package:flutter/material.dart';
import '../ac_chat.dart';

/// Wraps media bubble content to display a sleek upload progress indicator overlay
/// over the local background preview while the attachment is uploading to the server.
class MediaUploadWrapper extends StatefulWidget {
  final AcChatMessage message;
  final AcChatTheme ct;
  final Widget child;
  final VoidCallback? onRetry;

  const MediaUploadWrapper({
    super.key,
    required this.message,
    required this.ct,
    required this.child,
    this.onRetry,
  });

  @override
  State<MediaUploadWrapper> createState() => _MediaUploadWrapperState();
}

class _MediaUploadWrapperState extends State<MediaUploadWrapper> {
  StreamSubscription<({String messageId, double progress})>? _progressSub;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _subscribeProgress();
  }

  @override
  void didUpdateWidget(covariant MediaUploadWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.messageId != widget.message.messageId) {
      _progressSub?.cancel();
      _subscribeProgress();
    }
  }

  void _subscribeProgress() {
    final messageId = widget.message.messageId;
    if (messageId.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final api = AcChatApiProvider.getApi(context);
      final current = api.getUploadProgress(messageId: messageId);
      if (current != null) {
        setState(() {
          _progress = current;
        });
      }

      _progressSub?.cancel();
      _progressSub = api.onUploadProgress.listen((event) {
        if (event.messageId == messageId && mounted) {
          setState(() {
            _progress = event.progress;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _progressSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.message.status;
    final bool hasRemoteUrl =
        widget.message.fileUrl != null && widget.message.fileUrl!.isNotEmpty;
    final bool isUploading = (status == 'sending' || status == 'uploading') && !hasRemoteUrl;
    final bool isFailed = status == 'failed' && !hasRemoteUrl;

    if (!isUploading && !isFailed) {
      return widget.child;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Underlying local preview
          widget.child,

          // Dark translucent tint over background preview
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // Upload progress circular overlay or failed retry button
          if (isUploading)
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _progress > 0.0 ? _progress : null,
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.ct.activeTabColor),
                    backgroundColor: Colors.white.withOpacity(0.25),
                  ),
                  if (_progress > 0.0)
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Icon(
                      Icons.cloud_upload_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                ],
              ),
            )
          else if (isFailed)
            GestureDetector(
              onTap: widget.onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.ct.messageDestructive,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: widget.ct.messageDestructive,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
