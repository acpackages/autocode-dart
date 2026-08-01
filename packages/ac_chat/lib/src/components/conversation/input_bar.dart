import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
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
  final VoidCallback? onMicCancel;
  final VoidCallback? onMicTap;
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
    this.onMicCancel,
    this.onMicTap,
    required this.focusNode,
    required this.showEmojiPicker,
    required this.onEmojiToggle,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  bool _hasText = false;
  int _secondsElapsed = 0;
  Timer? _recordingTimer;
  late final RecorderController _recorderController;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
    _recorderController = RecorderController()
      ..updateFrequency = const Duration(milliseconds: 50);
  }

  @override
  void didUpdateWidget(InputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _startRecordingTimers();
      } else {
        _stopRecordingTimers();
      }
    }
  }

  void _handleTextChanged() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  Future<void> _startRecordingTimers() async {
    _secondsElapsed = 0;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });

    final hasPermission = await _recorderController.checkPermission();
    if (hasPermission) {
      await _recorderController.record();
    }
  }

  Future<void> _stopRecordingTimers() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    await _recorderController.stop();
    _secondsElapsed = 0;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    _recordingTimer?.cancel();
    _recorderController.dispose();
    super.dispose();
  }

  String _formatRecordingTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.ct;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      color: ct.scaffold,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.isRecording) ...[
                // Pulsing recording indicator
                AnimatedBuilder(
                  animation: widget.micAnim,
                  builder: (context, _) {
                    return Opacity(
                      opacity: widget.micAnim.value,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  _formatRecordingTime(_secondsElapsed),
                  style: TextStyle(
                    color: ct.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Live Waveform visualizer
                Expanded(
                  child: AudioWaveforms(
                    enableGesture: false,
                    size: Size(MediaQuery.of(context).size.width * 0.4, 40.0),
                    recorderController: _recorderController,
                    waveStyle: WaveStyle(
                      waveColor: ct.unreadBadgeBg,
                      spacing: 4.0,
                      showMiddleLine: false,
                      extendWaveform: true,
                    ),
                  ),
                ),
                
                // Cancel Button
                TextButton(
                  onPressed: widget.onMicCancel,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: ct.messageDestructive,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ] else ...[
                // Attachment Button (left most, '+' icon)
                _buildAttachButton(context, ct),
                // Emoji Picker Button (next to it)
                IconButton(
                  padding: const EdgeInsets.all(8),
                  icon: Icon(
                    widget.showEmojiPicker
                        ? Icons.keyboard_rounded
                        : Icons.emoji_emotions_outlined,
                    color: ct.iconColor,
                    size: 22,
                  ),
                  onPressed: widget.onEmojiToggle,
                ),
                const SizedBox(width: 4),
                // Input field container (flat/inline)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ct.inputFill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            focusNode: widget.focusNode,
                            style: TextStyle(color: ct.inputText, fontSize: 15),
                            maxLines: 5,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Message',
                              hintStyle: TextStyle(color: ct.inputHint, fontSize: 15),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 9),
                            ),
                            onSubmitted: (_) => widget.onSend(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              // Send / Mic button (inline, right most)
              GestureDetector(
                onTap: () {
                  if (_hasText) {
                    widget.onSend();
                  } else {
                    widget.onMicTap?.call();
                  }
                },
                onLongPressStart: _hasText ? null : (_) => widget.onMicStart(),
                onLongPressEnd: _hasText ? null : (_) => widget.onMicStop(),
                child: AnimatedBuilder(
                  animation: widget.micAnim,
                  builder: (_, __) {
                    final scale = widget.isRecording ? 1.0 + widget.micAnim.value * 0.15 : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          _hasText
                              ? Icons.send_rounded
                              : (widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded),
                          color: _hasText
                              ? ct.activeTabColor
                              : (widget.isRecording ? Colors.red : ct.iconColor),
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachButton(BuildContext context, AcChatTheme ct) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 768; // Desktop mode

    if (isDesktop) {
      return PopupMenuButton<String>(
        icon: Icon(Icons.add, color: ct.iconColor, size: 22),
        color: ct.surface,
        offset: const Offset(0, -280),
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
      return IconButton(
        padding: const EdgeInsets.all(8),
        icon: Icon(Icons.add, color: ct.iconColor, size: 22),
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