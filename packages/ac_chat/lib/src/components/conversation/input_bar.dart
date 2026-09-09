import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../../ac_chat.dart';

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
  final bool enableTyping;
  final void Function(String)? onAttachOption;
  final AcChatApi api;
  final List<AcChatUser> mentionCandidates;
  final ValueChanged<AcChatUser>? onMentionSelected;

  const InputBar({
    super.key,
    required this.controller,
    required this.ct,
    required this.api,
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
    this.enableTyping = true,
    this.onAttachOption,
    this.mentionCandidates = const [],
    this.onMentionSelected,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  bool _hasText = false;
  int _secondsElapsed = 0;
  Timer? _recordingTimer;
  late final RecorderController _recorderController;
  String _mentionQuery = '';
  bool _showMentions = false;

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
    final text = widget.controller.text;
    final has = text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);

    if (widget.api.enableMentions && text.contains('@')) {
      final lastAt = text.lastIndexOf('@');
      final query = text.substring(lastAt + 1).toLowerCase();
      if (!query.contains(' ')) {
        setState(() {
          _showMentions = true;
          _mentionQuery = query;
        });
        return;
      }
    }
    if (_showMentions) {
      setState(() => _showMentions = false);
    }
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

    final filteredMentions = widget.mentionCandidates.where((u) {
      if (_mentionQuery.isEmpty) return true;
      return u.name.toLowerCase().contains(_mentionQuery) ||
          u.username.toLowerCase().contains(_mentionQuery);
    }).toList();

    return Column(
        children: [
    Container(
    decoration:BoxDecoration(color: ct.inputBarTopBorder) ,height: 3,
    ),
        Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      color: ct.scaffold,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Mentions autocomplete popup
          if (_showMentions && filteredMentions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: ct.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ct.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filteredMentions.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: ct.divider),
                itemBuilder: (ctx, idx) {
                  final u = filteredMentions[idx];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: avatarColor(u.userId),
                      child: Text(
                        u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                        style: TextStyle(color: ct.white, fontSize: 12),
                      ),
                    ),
                    title: Text(u.name, style: TextStyle(color: ct.text, fontSize: 13)),
                    subtitle: u.username.isNotEmpty
                        ? Text('@${u.username}', style: TextStyle(color: ct.subText, fontSize: 11))
                        : null,
                    onTap: () {
                      final text = widget.controller.text;
                      final lastAt = text.lastIndexOf('@');
                      final newText = '${text.substring(0, lastAt)}@${u.name} ';
                      widget.controller.text = newText;
                      widget.controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: newText.length),
                      );
                      setState(() => _showMentions = false);
                      widget.onMentionSelected?.call(u);
                    },
                  );
                },
              ),
            ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.isRecording) ...[
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
                // Attachment Button (only rendered if media attachments enabled)
                if (widget.api.enableMediaAttachments)
                  _buildAttachButton(context, ct, widget.api),

                // Emoji Picker Button
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

                // Input field container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ct.inputFill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      enabled: widget.enableTyping,
                      style: TextStyle(fontSize: 15,),
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: widget.enableTyping ? 'Message' : 'Typing is disabled',
                        hintStyle: TextStyle(color: ct.inputHint, fontSize: 15),
                        border: InputBorder.none,

                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      onSubmitted: (_) => widget.onSend(),
                    ),
                  ),
                ),
              ],
              if(widget.api.enableVoiceNotes)
              const SizedBox(width: 4),
              if(widget.api.enableVoiceNotes)
              // Send / Mic button
              GestureDetector(
                onTap: () {
                  if (_hasText) {
                    widget.onSend();
                  } else if (widget.api.enableVoiceNotes) {
                    widget.onMicTap?.call();
                  }
                },
                onLongPressStart: (_hasText || !widget.api.enableVoiceNotes) ? null : (_) => widget.onMicStart(),
                onLongPressEnd: (_hasText || !widget.api.enableVoiceNotes) ? null : (_) => widget.onMicStop(),
                child: AnimatedBuilder(
                  animation: widget.micAnim,
                  builder: (_, __) {
                    final scale = widget.isRecording ? 1.0 + widget.micAnim.value * 0.15 : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          _hasText || !widget.api.enableVoiceNotes
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
    )]);
  }

  Widget _buildAttachButton(BuildContext context, AcChatTheme ct, AcChatApi cfg) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 768;

    if (isDesktop) {
      final items = <PopupMenuItem<String>>[];
      if (cfg.enableDocumentAttachments) {
        items.add(_attachMenuItem(Icons.description, ct.attachDocumentBg, 'Document', ct));
      }
      if (cfg.enableImageAttachments || cfg.enableVideoAttachments) {
        items.add(_attachMenuItem(Icons.camera_alt, ct.attachCameraBg, 'Camera', ct));
        items.add(_attachMenuItem(Icons.image, ct.attachGalleryBg, 'Gallery', ct));
      }
      if (cfg.enableVoiceNotes) {
        items.add(_attachMenuItem(Icons.headset, ct.attachAudioBg, 'Audio', ct));
      }
      if(cfg.enableLocationAttachments){
        items.add(_attachMenuItem(Icons.location_on, ct.attachLocationBg, 'Location', ct));
      }
      if(cfg.enableContactAttachments){
        items.add(_attachMenuItem(Icons.person, ct.attachContactBg, 'Contact', ct));
      }

      return PopupMenuButton<String>(
        icon: Icon(Icons.add, color: ct.iconColor, size: 22),
        color: ct.surface,

        offset: Offset(0, double.parse(items.length.toString()) * -46.67),
        // position: PopupMenuPosition.over,
        onSelected: (label) {
          if (widget.onAttachOption != null) {
            widget.onAttachOption!(label);
          } else {
            widget.onAttach();
          }
        },
        itemBuilder: (context) => items,
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
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: ct.text, fontSize: 14)),
        ],
      ),
    );
  }
}