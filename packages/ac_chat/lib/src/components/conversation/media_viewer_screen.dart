import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/ac_chat.dart';

class MediaViewerScreen extends StatefulWidget {
  final AcChatMessage message;
  final AcChatTheme ct;
  final String senderName;

  const MediaViewerScreen({
    super.key,
    required this.ct,
    required this.message,
    required this.senderName,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  // Video Player state
  bool _isPlaying = false;
  double _videoPosition = 0.0;
  final double _videoDuration = 15.0; // 15 seconds mock duration
  Timer? _videoTimer;
  bool _isMuted = false;

  // Document state
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _videoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          setState(() {
            _videoPosition += 0.1;
            if (_videoPosition >= _videoDuration) {
              _videoPosition = 0.0;
              _isPlaying = false;
              timer.cancel();
            }
          });
        });
      } else {
        _videoTimer?.cancel();
      }
    });
  }

  String _formatTime(double seconds) {
    final minutesStr = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsStr = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final type = message.type;
    final title = message.fileName ?? message.mediaCaption ?? (type == 'image' ? 'Image' : type == 'video' ? 'Video' : 'Document');

    return Scaffold(
      backgroundColor: widget.ct.black,
      appBar: AppBar(
        backgroundColor: widget.ct.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: widget.ct.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: widget.ct.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Shared by ${widget.senderName}',
              style: TextStyle(color: widget.ct.white.withOpacity(0.6), fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: widget.ct.white),
            onPressed: () {
              final linkOrPath = widget.message.filePath ?? widget.message.fileUrl ?? widget.message.localPath ?? widget.message.text;
              Clipboard.setData(ClipboardData(text: linkOrPath));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File link copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.file_download_outlined, color: widget.ct.white),
            onPressed: () => _downloadMedia(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildViewerContent(),
            ),
            if (type == 'image' && message.mediaCaption != null)
              Container(
                color: widget.ct.surface,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  message.mediaCaption!,
                  textAlign: Alignment.center.x == 0 ? TextAlign.center : TextAlign.left,
                  style: TextStyle(color: widget.ct.text, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewerContent() {
    final type = widget.message.type;
    final localPath = widget.message.localPath;
    final remoteUrl = (widget.message.filePath != null && widget.message.filePath!.startsWith('http'))
        ? widget.message.filePath
        : (widget.message.fileUrl ?? (widget.message.text.startsWith('http') ? widget.message.text : null));
    final text = widget.message.text;

    if (type == 'image') {
      Widget imageWidget;
      if (widget.message.byteData != null) {
        imageWidget = Image.memory(
          widget.message.byteData!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.broken_image_rounded, size: 64, color: widget.ct.white30),
          ),
        );
      } else if (!kIsWeb && localPath != null && localPath.isNotEmpty && io.File(localPath).existsSync()) {
        imageWidget = Image.file(
          io.File(localPath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.broken_image_rounded, size: 64, color: widget.ct.white30),
          ),
        );
      } else if (remoteUrl != null && (remoteUrl.startsWith('http://') || remoteUrl.startsWith('https://'))) {
        imageWidget = Image.network(
          remoteUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(color: widget.ct.white),
            );
          },
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.broken_image_rounded, size: 64, color: widget.ct.white30),
          ),
        );
      } else if (text.startsWith('http://') || text.startsWith('https://')) {
        imageWidget = Image.network(
          text,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(color: widget.ct.white),
            );
          },
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.broken_image_rounded, size: 64, color: widget.ct.white30),
          ),
        );
      } else if (!kIsWeb && text.isNotEmpty && io.File(text).existsSync()) {
        imageWidget = Image.file(
          io.File(text),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.broken_image_rounded, size: 64, color: widget.ct.white30),
          ),
        );
      } else {
        imageWidget = Center(
          child: Icon(Icons.broken_image_rounded, size: 64, color: widget.ct.white30),
        );
      }

      return Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: imageWidget,
        ),
      );
    } else if (type == 'video') {
      Widget videoCanvas;
      if (widget.message.byteData != null) {
        videoCanvas = Image.memory(
          widget.message.byteData!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.video_collection,
            size: 80,
            color: widget.ct.white24,
          ),
        );
      } else {
        // Choose thumbnail
        String thumbUrl = 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800';
        if (text.contains('BigBuckBunny')) {
          thumbUrl = 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800';
        } else if (text.contains('ForBiggerBlazes')) {
          thumbUrl = 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800';
        }

        if (text.startsWith('http://') || text.startsWith('https://')) {
          videoCanvas = Image.network(
            thumbUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.video_collection,
              size: 80,
              color: widget.ct.white24,
            ),
          );
        } else if (!kIsWeb && text.isNotEmpty) {
          videoCanvas = Container(
            color: widget.ct.black26,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_file_rounded, size: 80, color: widget.ct.white24),
                  const SizedBox(height: 8),
                  Text(
                    text.split('/').last.split('\\').last,
                    style: TextStyle(color: widget.ct.white70, fontSize: 12),
                  )
                ],
              ),
            ),
          );
        } else {
          videoCanvas = Icon(
            Icons.video_collection,
            size: 80,
            color: widget.ct.white24,
          );
        }
      }

      return Container(
        color: widget.ct.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Opacity(
                opacity: 0.85,
                child: videoCanvas,
              ),
            ),
            // Video Play state animation mock
            if (_isPlaying)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.ct.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.ct.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Streaming HD...',
                        style: TextStyle(color: widget.ct.white.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            // Central Play/Pause Tap target
            GestureDetector(
              onTap: _togglePlay,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: widget.ct.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.ct.white, width: 2),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: widget.ct.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            // Video Controls Bottom Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.ct.transparent, widget.ct.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Slider
                    Row(
                      children: [
                        Text(
                          _formatTime(_videoPosition),
                          style: TextStyle(color: widget.ct.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Slider(
                            value: _videoPosition,
                            min: 0.0,
                            max: _videoDuration,
                            activeColor: widget.ct.activeTabColor,
                            inactiveColor: widget.ct.divider,
                            onChanged: (val) {
                              setState(() {
                                _videoPosition = val;
                              });
                            },
                          ),
                        ),
                        Text(
                          _formatTime(_videoDuration),
                          style: TextStyle(color: widget.ct.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // Actions Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: widget.ct.white,
                                size: 28,
                              ),
                              onPressed: _togglePlay,
                            ),
                            IconButton(
                              icon: Icon(Icons.replay_10_rounded, color: widget.ct.white),
                              onPressed: () {
                                setState(() {
                                  _videoPosition = (_videoPosition - 10).clamp(0.0, _videoDuration);
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.forward_10_rounded, color: widget.ct.white),
                              onPressed: () {
                                setState(() {
                                  _videoPosition = (_videoPosition + 10).clamp(0.0, _videoDuration);
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                color: widget.ct.white,
                              ),
                              onPressed: () {
                                setState(() => _isMuted = !_isMuted);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.fullscreen_rounded, color: widget.ct.white),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fullscreen simulator mode'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Document type
      return _buildDocumentViewer(context);
    }
  }

  Widget _buildDocumentViewer(BuildContext context) {
    final fileName = widget.message.fileName ?? 'Document.pdf';
    final lowerName = fileName.toLowerCase();
    final fileSize = widget.message.fileSize ?? '';

    Color iconColor;
    IconData iconData;
    Color bgColor;

    if (lowerName.endsWith('.pdf')) {
      iconColor = widget.ct.docIconPdf;
      iconData = Icons.picture_as_pdf_rounded;
      bgColor = widget.ct.docBgPdf;
    } else if (lowerName.endsWith('.xlsx') || lowerName.endsWith('.xls')) {
      iconColor = widget.ct.docIconExcel;
      iconData = Icons.grid_on_rounded;
      bgColor = widget.ct.docBgExcel;
    } else if (lowerName.endsWith('.docx') || lowerName.endsWith('.doc')) {
      iconColor = widget.ct.docIconWord;
      iconData = Icons.description_rounded;
      bgColor = widget.ct.docBgWord;
    } else if (lowerName.endsWith('.zip') || lowerName.endsWith('.rar')) {
      iconColor = widget.ct.docIconPpt;
      iconData = Icons.folder_zip_rounded;
      bgColor = widget.ct.docBgPpt;
    } else {
      iconColor = widget.ct.activeTabColor;
      iconData = Icons.article_rounded;
      bgColor = widget.ct.activeTabColor.withOpacity(0.15);
    }

    final hasLocal = !kIsWeb &&
        widget.message.localPath != null &&
        io.File(widget.message.localPath!).existsSync();

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: widget.ct.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.ct.divider.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: widget.ct.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(iconData, color: iconColor, size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              fileName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.ct.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (fileSize.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                fileSize,
                style: TextStyle(
                  color: widget.ct.subText,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (hasLocal ? Colors.green : widget.ct.activeTabColor).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hasLocal ? 'Saved locally' : 'Cloud attachment',
                style: TextStyle(
                  color: hasLocal ? Colors.green : widget.ct.activeTabColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                label: const Text('Open Document', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.ct.activeTabColor,
                  foregroundColor: widget.ct.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _openDocument,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download_rounded, size: 20),
                label: const Text('Save to Downloads'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.ct.text,
                  side: BorderSide(color: widget.ct.divider),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _downloadMedia(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDocument() async {
    final localPath = widget.message.localPath;
    final fileUrl = widget.message.fileUrl;
    final text = widget.message.text;

    try {
      if (localPath != null && !kIsWeb && io.File(localPath).existsSync()) {
        final uri = Uri.file(localPath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return;
        }
      }
      final urlToLaunch = (widget.message.filePath != null && widget.message.filePath!.startsWith('http'))
          ? widget.message.filePath
          : ((fileUrl != null && fileUrl.startsWith('http'))
              ? fileUrl
              : ((text.startsWith('http://') || text.startsWith('https://')) ? text : null));
      if (urlToLaunch != null) {
        final uri = Uri.parse(urlToLaunch);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
      if (!kIsWeb && text.isNotEmpty && io.File(text).existsSync()) {
        final uri = Uri.file(text);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return;
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open document: file path or URL not accessible.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening document: $e')),
        );
      }
    }
  }

  Future<void> _downloadMedia(BuildContext context) async {
    final message = widget.message;
    final localPath = message.localPath;
    final fileUrl = message.fileUrl;
    final text = message.text;
    final downloadUrl = (message.filePath != null && message.filePath!.startsWith('http'))
        ? message.filePath
        : ((fileUrl != null && fileUrl.startsWith('http'))
            ? fileUrl
            : ((text.startsWith('http://') || text.startsWith('https://')) ? text : null));
    final fileName = message.fileName ??
        (localPath != null && localPath.isNotEmpty
            ? localPath.split(RegExp(r'[/\\]')).last
            : (downloadUrl != null
                ? downloadUrl.split('?').first.split('/').last
                : 'downloaded_attachment'));

    try {
      Uint8List? bytes = message.byteData;
      if (bytes == null || bytes.isEmpty) {
        if (!kIsWeb && localPath != null && io.File(localPath).existsSync()) {
          bytes = await io.File(localPath).readAsBytes();
        } else if (downloadUrl != null) {
          final request = await io.HttpClient().getUrl(Uri.parse(downloadUrl));
          final response = await request.close();
          final chunks = <Uint8List>[];
          await for (final chunk in response) {
            chunks.add(chunk is Uint8List ? chunk : Uint8List.fromList(chunk));
          }
          final totalLen = chunks.fold<int>(0, (sum, c) => sum + c.length);
          final fullBytes = Uint8List(totalLen);
          var offset = 0;
          for (final c in chunks) {
            fullBytes.setRange(offset, offset + c.length, c);
            offset += c.length;
          }
          bytes = fullBytes;
        } else if (!kIsWeb && io.File(text).existsSync()) {
          bytes = await io.File(text).readAsBytes();
        }
      }

      if (bytes == null || bytes.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data found to download.')),
          );
        }
        return;
      }

      String saveDir = '';
      if (!kIsWeb) {
        if (io.Platform.isWindows) {
          final userProfile = io.Platform.environment['USERPROFILE'] ?? 'C:\\';
          saveDir = '$userProfile\\Downloads';
        } else {
          final home = io.Platform.environment['HOME'] ?? '';
          saveDir = home.isNotEmpty ? '$home/Downloads' : '';
        }
      }

      if (saveDir.isNotEmpty) {
        final targetDir = io.Directory(saveDir);
        if (!targetDir.existsSync()) {
          targetDir.createSync(recursive: true);
        }
        final targetPath = '$saveDir${io.Platform.pathSeparator}$fileName';
        final f = io.File(targetPath);
        await f.writeAsBytes(bytes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to Downloads: $fileName')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloaded ${bytes.length} bytes successfully.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }
}
