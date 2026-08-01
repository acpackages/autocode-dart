import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../common/chat_colors.dart';

class InputBar extends StatefulWidget {
  final TextEditingController controller;
  final AcChatTheme ct;
  final bool isDark;
  final bool isRecording;
  final AnimationController micAnim;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onMicStart;
  final VoidCallback onMicStop;
  final FocusNode focusNode;
  final bool showEmojiPicker;
  final VoidCallback onEmojiToggle;

  const InputBar({
    required this.controller,
    required this.ct,
    required this.isDark,
    required this.isRecording,
    required this.micAnim,
    required this.onSend,
    required this.onAttach,
    required this.onMicStart,
    required this.onMicStop,
    required this.focusNode,
    required this.showEmojiPicker,
    required this.onEmojiToggle,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final has = widget.controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.ct;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      color: ct.scaffold,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Payment quick action (only when not recording)
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          // Input field container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ct.inputFill,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Emoji
                    IconButton(
                      padding: const EdgeInsets.all(8),
                      icon: Icon(
                          widget.showEmojiPicker
                              ? Icons.keyboard_rounded
                              : Icons.emoji_emotions_outlined,
                          color: ct.iconColor,
                          size: 22),
                      onPressed: widget.onEmojiToggle,
                    ),
                    // Text field
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        style: TextStyle(color: ct.inputText, fontSize: 15),
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: widget.isRecording
                              ? 'Recording…'
                              : 'Message',
                          hintStyle:
                          TextStyle(color: ct.inputHint, fontSize: 15),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 9),
                        ),
                        onSubmitted: (_) => widget.onSend(),
                      ),
                    ),
                    // Attach
                    _buildAttachButton(context, ct),
                    // Camera
                    IconButton(
                      padding: const EdgeInsets.all(8),
                      icon: Icon(Icons.camera_alt_outlined,
                          color: ct.iconColor, size: 22),
                      onPressed: () {},
                    ),
                  ]),
            ),
          ),
          const SizedBox(width: 8),
          // Send / Mic button
          GestureDetector(
            onTap: _hasText ? widget.onSend : null,
            onLongPressStart: _hasText
                ? null
                : (_) => widget.onMicStart(),
            onLongPressEnd: _hasText
                ? null
                : (_) => widget.onMicStop(),
            child: AnimatedBuilder(
              animation: widget.micAnim,
              builder: (_, __) {
                final scale = widget.isRecording
                    ? 1.0 + widget.micAnim.value * 0.15
                    : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: ct.activeTabColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ct.activeTabColor.withOpacity(0.4),
                          blurRadius: widget.isRecording ? 10 : 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _hasText
                          ? Icons.send_rounded
                          : (widget.isRecording
                          ? Icons.stop_rounded
                          : Icons.mic_rounded),
                      color: ct.white,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildAttachButton(BuildContext context, AcChatTheme ct) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 768; // Desktop mode

    if (isDesktop) {
      // Return a PopupMenuButton that shows attachment options
      return PopupMenuButton<String>(
        icon: Icon(Icons.attach_file_rounded, color: ct.iconColor, size: 22),
        color: ct.surface,
        offset: const Offset(0, -280), // Show dropdown above the input bar
        onSelected: (label) {
          _toast(context, '$label — coming soon');
        },
        itemBuilder: (context) => [
          _attachMenuItem(Icons.description, ct.attachDocumentBg, 'Document', ct),
          _attachMenuItem(Icons.camera_alt, ct.attachCameraBg, 'Camera', ct),
          _attachMenuItem(Icons.image, ct.attachGalleryBg, 'Gallery', ct),
          _attachMenuItem(Icons.headset, ct.attachAudioBg, 'Audio', ct),
          _attachMenuItem(Icons.location_on, ct.attachLocationBg, 'Location', ct),
          _attachMenuItem(Icons.person, ct.attachContactBg, 'Contact', ct),
        ],
      );
    } else {
      // Bottom sheet (on mobile/tablet)
      return IconButton(
        padding: const EdgeInsets.all(8),
        icon: Icon(Icons.attach_file_rounded, color: ct.iconColor, size: 22),
        onPressed: widget.onAttach,
      );
    }
  }

  PopupMenuItem<String> _attachMenuItem(IconData icon, Color color, String label, AcChatTheme ct) {
    return PopupMenuItem<String>(
      value: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: ct.text, fontSize: 14)),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}