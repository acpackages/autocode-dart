import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/ac_chat.dart';

class MediaDownloadWrapper extends StatefulWidget {
  final AcChatMessage message;
  final AcChatTheme ct;
  final Widget child;

  const MediaDownloadWrapper({
    super.key,
    required this.message,
    required this.ct,
    required this.child,
  });

  @override
  State<MediaDownloadWrapper> createState() => _MediaDownloadWrapperState();
}

class _MediaDownloadWrapperState extends State<MediaDownloadWrapper> {
  bool _isDownloading = false;
  double _progress = 0.0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startDownload() {
    if (_isDownloading) return;
    final api = AcChatApiProvider.of(context);
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        _progress += 0.1;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _isDownloading = false;
          widget.message.isDownloaded = true;
          widget.message.localPath = widget.message.text;
          api.updateMessage?.call(widget.message.messageId, {
            'isDownloaded': true,
            'localPath': widget.message.text,
          });
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.isDownloaded) {
      return widget.child;
    }

    return GestureDetector(
      onTap: _startDownload,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Underlying dimmed content
          Opacity(
            opacity: 0.6,
            child: AbsorbPointer(
              child: widget.child,
            ),
          ),
          // Download icon or progress tracker
          if (!_isDownloading)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: widget.ct.black.withOpacity(0.55),
                shape: BoxShape.circle,
                border: Border.all(color: widget.ct.white70, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: widget.ct.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: Icon(
                Icons.arrow_downward_rounded,
                color: widget.ct.white,
                size: 24,
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: widget.ct.black.withOpacity(0.65),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.ct.activeTabColor),
                    backgroundColor: widget.ct.divider,
                  ),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: TextStyle(
                      color: widget.ct.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          // File Size Chip
          if (!_isDownloading)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.ct.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.message.fileSize ?? '1.2 MB',
                  style: TextStyle(
                    color: widget.ct.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
