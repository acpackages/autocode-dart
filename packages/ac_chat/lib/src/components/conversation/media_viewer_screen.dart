import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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
  int _currentPage = 1;
  final int _totalPages = 3;
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing $title...'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.file_download_outlined, color: widget.ct.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading $title to downloads directory...'),
                  duration: const Duration(seconds: 5),
                ),
              );
            },
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
      } else {
        if (text.startsWith('http://') || text.startsWith('https://')) {
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
        } else if (!kIsWeb && text.isNotEmpty) {
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
      final fileName = widget.message.fileName ?? 'Document.pdf';
      final lowerName = fileName.toLowerCase();
      
      String previewTitle = 'Document Preview';
      List<Widget> pages = [];

      if (lowerName.endsWith('.pdf')) {
        previewTitle = 'Invoice Details';
        pages = [
          _buildMockPdfPage(1, 'Accountea Pro Invoice', 'Invoice ID: INV-2026-098\nDate: 2026-08-01\nDue Date: 2026-08-15', [
            _buildTableRow('Consulting Services', '15 hrs', '₹10,500'),
            _buildTableRow('Database Migration', '1 Unit', '₹15,000'),
            _buildTableRow('Support Plan', '1 Month', '₹2,500'),
          ], 'Total: ₹28,000'),
          _buildMockPdfPage(2, 'Payment Instructions', 'Please wire payment to the following bank details:\nBank: HDFC Bank Accountea Corp\nA/C: 50200045239108\nIFSC: HDFC0000240\nUPI: accountea@hdfcbank', [], ''),
          _buildMockPdfPage(3, 'Terms & Conditions', '1. Payments are due within 15 days of invoice date.\n2. Interest of 1.5% per month will be charged on late payments.\n3. Thank you for your business!', [], ''),
        ];
      } else if (lowerName.endsWith('.xlsx') || lowerName.endsWith('.xls')) {
        previewTitle = 'Q2 Expense Sheet';
        pages = [
          _buildMockExcelPage('Office Splits', [
            ['Category', 'Amount', 'Date', 'Paid By'],
            ['Office Rent', '₹45,000', '01 Jun', 'HDFC Bank'],
            ['Electricity', '₹4,200', '03 Jun', 'GPay'],
            ['Snacks & Tea', '₹2,100', '08 Jun', 'Cash'],
            ['WiFi Router', '₹1,500', '12 Jun', 'Credit Card'],
            ['Software Subs', '₹8,500', '15 Jun', 'Credit Card'],
          ]),
          _buildMockExcelPage('Marketing', [
            ['Campaign', 'Budget', 'Spent', 'ROAS'],
            ['Google Ads', '₹25,000', '₹24,100', '2.8x'],
            ['Meta Ads', '₹35,000', '₹35,000', '3.4x'],
            ['Newsletters', '₹5,000', '₹4,800', '1.5x'],
            ['Sponsorships', '₹15,000', '₹15,000', '1.1x'],
          ]),
        ];
      } else {
        // Word, Zip, Text files
        previewTitle = fileName;
        pages = [
          _buildMockTextPage(fileName, text),
        ];
      }

      return Container(
        color: widget.ct.black,
        child: Column(
          children: [
            // Top Reader Options
            Container(
              color: widget.ct.greyShade900,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    previewTitle,
                    style: TextStyle(color: widget.ct.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.zoom_in, color: widget.ct.white70, size: 20),
                      const SizedBox(width: 16),
                      Text(
                        'Page $_currentPage of ${pages.length}',
                        style: TextStyle(color: widget.ct.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Document Page View Canvas
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx + 1;
                  });
                },
                children: pages,
              ),
            ),
            // Navigation Dots/Arrows
            if (pages.length > 1)
              Container(
                color: widget.ct.greyShade900,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: widget.ct.white),
                      onPressed: _currentPage > 1
                          ? () {
                              _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            }
                          : null,
                    ),
                    ...List.generate(pages.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index + 1 ? widget.ct.activeTabColor : widget.ct.divider,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: widget.ct.white),
                      onPressed: _currentPage < pages.length
                          ? () {
                              _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }
  }

  Widget _buildMockPdfPage(int pageNum, String header, String metadata, List<Widget> items, String footer) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.ct.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: widget.ct.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  header,
                  style: TextStyle(color: widget.ct.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Page $pageNum',
                  style: TextStyle(color: widget.ct.grey, fontSize: 12),
                ),
              ],
            ),
            Divider(color: widget.ct.black54, thickness: 1.5, height: 20),
            Text(
              metadata,
              style: TextStyle(color: widget.ct.black54, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 16),
            if (items.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Description', style: TextStyle(color: widget.ct.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Qty', style: TextStyle(color: widget.ct.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Amount', style: TextStyle(color: widget.ct.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Divider(color: widget.ct.black38),
              ...items,
            ],
            const Spacer(),
            if (footer.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  footer,
                  style: TextStyle(color: widget.ct.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            Divider(color: widget.ct.grey),
            Center(
              child: Text(
                'Confidential Document • Accountea Corporate',
                style: TextStyle(color: widget.ct.grey, fontSize: 9),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(String desc, String qty, String amt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(desc, style: TextStyle(color: widget.ct.black54, fontSize: 11))),
          Text(qty, style: TextStyle(color: widget.ct.black54, fontSize: 11)),
          const SizedBox(width: 40),
          Text(amt, style: TextStyle(color: widget.ct.black, fontWeight: FontWeight.w600, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMockExcelPage(String sheetName, List<List<String>> grid) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.ct.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.ct.docIconExcel, // Excel green
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(Icons.table_chart_outlined, color: widget.ct.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  sheetName,
                  style: TextStyle(color: widget.ct.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: widget.ct.grey),
                  defaultColumnWidth: const FixedColumnWidth(100),
                  children: List.generate(grid.length, (rowIdx) {
                    final row = grid[rowIdx];
                    final isHeader = rowIdx == 0;
                    return TableRow(
                      decoration: BoxDecoration(
                        color: isHeader ? widget.ct.grey : widget.ct.white,
                      ),
                      children: List.generate(row.length, (colIdx) {
                        final val = row[colIdx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Text(
                            val,
                            style: TextStyle(
                              color: widget.ct.black54,
                              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockTextPage(String title, String content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.ct.grey,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: widget.ct.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Type: ${title.split('.').last.toUpperCase()}',
              style: TextStyle(color: widget.ct.activeTabColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              'Raw Content URL:\n$content',
              style: TextStyle(color: widget.ct.white70, fontSize: 12, fontStyle: FontStyle.italic),
            ),
            Divider(color: widget.ct.white12, height: 24),
            Text(
              'Mock Metadata:',
              style: TextStyle(color: widget.ct.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              '- Document verified: Yes\n- Secure Signature: Valid\n- Scanned via Accountea AI OCR\n- Status: Settle Pending',
              style: TextStyle(color: widget.ct.white70, fontSize: 12, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
