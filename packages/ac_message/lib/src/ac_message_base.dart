import 'package:flutter/material.dart';
import 'dart:async';
import 'ac_message_type.dart';
import 'ac_message_options.dart';
import 'ac_message_theme.dart';

class AcMessage {
  static GlobalKey<NavigatorState>? _navigatorKey;

  static AcMessageOptions defaultConfig = const AcMessageOptions(
    timer: Duration(milliseconds: 3000),
    toast: true,
    position: ToastPosition.topRight,
    showCloseButton: true,
    pauseOnHover: true,
    progressBar: true,
    showConfirmButton: true,
    showCancelButton: true,
    confirmText: 'OK',
    denyText: 'Cancel',
    allowOutsideClick: false,
    allowEscapeKey: true,
  );

  // Toast management
  static final Map<ToastPosition, OverlayEntry> _containers = {};
  static final Map<ToastPosition, List<_ToastData>> _activeToasts = {};
  
  // Modal management
  static final List<Function()> _modalQueue = [];
  static bool _modalOpen = false;

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  static BuildContext get _context {
    if (_navigatorKey?.currentContext == null) {
      throw Exception(
          'AcMessage is not initialized. Call AcMessage.init(navigatorKey) or provide a BuildContext.');
    }
    return _navigatorKey!.currentContext!;
  }

  static void configure(AcMessageOptions cfg) {
    defaultConfig = cfg;
  }

  // Convenience methods
  static Future<dynamic> success({
    String? title,
    String? message,
    Widget? content,
    IconData? icon,
    Duration? timer,
    ToastPosition? position,
    bool? showCloseButton,
    bool? pauseOnHover,
    bool? progressBar,
    bool? showConfirmButton,
    bool? showCancelButton,
    String? confirmText,
    String? denyText,
    bool? showInput,
    String? inputPlaceholder,
    String? inputValue,
    bool? allowOutsideClick,
    bool? allowEscapeKey,
    Function(AcConfirmResult)? onConfirm,
    Function(AcConfirmResult)? onCancel,
    Function(BuildContext)? onOpen,
    Function(BuildContext)? onClose,
    Map<String, dynamic>? data,
  }) => fire(
    type: AcMessageType.success,
    title: title,
    message: message,
    content: content,
    icon: icon,
    timer: timer,
    position: position,
    showCloseButton: showCloseButton,
    pauseOnHover: pauseOnHover,
    progressBar: progressBar,
    showConfirmButton: showConfirmButton,
    showCancelButton: showCancelButton,
    confirmText: confirmText,
    denyText: denyText,
    showInput: showInput,
    inputPlaceholder: inputPlaceholder,
    inputValue: inputValue,
    allowOutsideClick: allowOutsideClick,
    allowEscapeKey: allowEscapeKey,
    onConfirm: onConfirm,
    onCancel: onCancel,
    onOpen: onOpen,
    onClose: onClose,
    data: data,
  );

  static Future<dynamic> error({
    String? title,
    String? message,
    Widget? content,
    IconData? icon,
    Duration? timer,
    ToastPosition? position,
    bool? showCloseButton,
    bool? pauseOnHover,
    bool? progressBar,
    bool? showConfirmButton,
    bool? showCancelButton,
    String? confirmText,
    String? denyText,
    bool? showInput,
    String? inputPlaceholder,
    String? inputValue,
    bool? allowOutsideClick,
    bool? allowEscapeKey,
    Function(AcConfirmResult)? onConfirm,
    Function(AcConfirmResult)? onCancel,
    Function(BuildContext)? onOpen,
    Function(BuildContext)? onClose,
    Map<String, dynamic>? data,
  }) => fire(
    type: AcMessageType.error,
    title: title,
    message: message,
    content: content,
    icon: icon,
    timer: timer,
    position: position,
    showCloseButton: showCloseButton,
    pauseOnHover: pauseOnHover,
    progressBar: progressBar,
    showConfirmButton: showConfirmButton,
    showCancelButton: showCancelButton,
    confirmText: confirmText,
    denyText: denyText,
    showInput: showInput,
    inputPlaceholder: inputPlaceholder,
    inputValue: inputValue,
    allowOutsideClick: allowOutsideClick,
    allowEscapeKey: allowEscapeKey,
    onConfirm: onConfirm,
    onCancel: onCancel,
    onOpen: onOpen,
    onClose: onClose,
    data: data,
  );

  static Future<dynamic> info({
    String? title,
    String? message,
    Widget? content,
    IconData? icon,
    Duration? timer,
    ToastPosition? position,
    bool? showCloseButton,
    bool? pauseOnHover,
    bool? progressBar,
    bool? showConfirmButton,
    bool? showCancelButton,
    String? confirmText,
    String? denyText,
    bool? showInput,
    String? inputPlaceholder,
    String? inputValue,
    bool? allowOutsideClick,
    bool? allowEscapeKey,
    Function(AcConfirmResult)? onConfirm,
    Function(AcConfirmResult)? onCancel,
    Function(BuildContext)? onOpen,
    Function(BuildContext)? onClose,
    Map<String, dynamic>? data,
  }) => fire(
    type: AcMessageType.info,
    title: title,
    message: message,
    content: content,
    icon: icon,
    timer: timer,
    position: position,
    showCloseButton: showCloseButton,
    pauseOnHover: pauseOnHover,
    progressBar: progressBar,
    showConfirmButton: showConfirmButton,
    showCancelButton: showCancelButton,
    confirmText: confirmText,
    denyText: denyText,
    showInput: showInput,
    inputPlaceholder: inputPlaceholder,
    inputValue: inputValue,
    allowOutsideClick: allowOutsideClick,
    allowEscapeKey: allowEscapeKey,
    onConfirm: onConfirm,
    onCancel: onCancel,
    onOpen: onOpen,
    onClose: onClose,
    data: data,
  );

  static Future<dynamic> warning({
    String? title,
    String? message,
    Widget? content,
    IconData? icon,
    Duration? timer,
    ToastPosition? position,
    bool? showCloseButton,
    bool? pauseOnHover,
    bool? progressBar,
    bool? showConfirmButton,
    bool? showCancelButton,
    String? confirmText,
    String? denyText,
    bool? showInput,
    String? inputPlaceholder,
    String? inputValue,
    bool? allowOutsideClick,
    bool? allowEscapeKey,
    Function(AcConfirmResult)? onConfirm,
    Function(AcConfirmResult)? onCancel,
    Function(BuildContext)? onOpen,
    Function(BuildContext)? onClose,
    Map<String, dynamic>? data,
  }) => fire(
    type: AcMessageType.warning,
    title: title,
    message: message,
    content: content,
    icon: icon,
    timer: timer,
    position: position,
    showCloseButton: showCloseButton,
    pauseOnHover: pauseOnHover,
    progressBar: progressBar,
    showConfirmButton: showConfirmButton,
    showCancelButton: showCancelButton,
    confirmText: confirmText,
    denyText: denyText,
    showInput: showInput,
    inputPlaceholder: inputPlaceholder,
    inputValue: inputValue,
    allowOutsideClick: allowOutsideClick,
    allowEscapeKey: allowEscapeKey,
    onConfirm: onConfirm,
    onCancel: onCancel,
    onOpen: onOpen,
    onClose: onClose,
    data: data,
  );

  static Future<dynamic> fire({
    String? title,
    String? message,
    Widget? content,
    IconData? icon,
    Duration? timer,
    bool? toast,
    ToastPosition? position,
    bool? showCloseButton,
    bool? pauseOnHover,
    bool? progressBar,
    AcMessageType? type,
    bool? showConfirmButton,
    bool? showCancelButton,
    String? confirmText,
    String? denyText,
    bool? showInput,
    String? inputPlaceholder,
    String? inputValue,
    bool? allowOutsideClick,
    bool? allowEscapeKey,
    Function(AcConfirmResult)? onConfirm,
    Function(AcConfirmResult)? onCancel,
    Function(BuildContext)? onOpen,
    Function(BuildContext)? onClose,
    Map<String, dynamic>? data,
  }) {
    final opts = defaultConfig.copyWith(
      title: title,
      message: message,
      content: content,
      icon: icon,
      timer: timer,
      toast: toast,
      position: position,
      showCloseButton: showCloseButton,
      pauseOnHover: pauseOnHover,
      progressBar: progressBar,
      type: type,
      showConfirmButton: showConfirmButton,
      showCancelButton: showCancelButton,
      confirmText: confirmText,
      denyText: denyText,
      showInput: showInput,
      inputPlaceholder: inputPlaceholder,
      inputValue: inputValue,
      allowOutsideClick: allowOutsideClick,
      allowEscapeKey: allowEscapeKey,
      onConfirm: onConfirm,
      onCancel: onCancel,
      onOpen: onOpen,
      onClose: onClose,
      data: data,
    );

    if (opts.toast) {
      return Future.value(AcMessage.toast(
        title: title,
        message: message,
        content: content,
        icon: icon,
        timer: timer,
        position: position,
        showCloseButton: showCloseButton,
        pauseOnHover: pauseOnHover,
        progressBar: progressBar,
        type: type,
        onOpen: onOpen,
        onClose: onClose,
        data: data,
      ));
    } else {
      return confirm(
        title: title,
        message: message,
        content: content,
        icon: icon,
        timer: timer,
        type: type,
        progressBar: progressBar,
        showConfirmButton: showConfirmButton,
        showCancelButton: showCancelButton,
        confirmText: confirmText,
        denyText: denyText,
        showInput: showInput,
        inputPlaceholder: inputPlaceholder,
        inputValue: inputValue,
        allowOutsideClick: allowOutsideClick,
        allowEscapeKey: allowEscapeKey,
        onConfirm: onConfirm,
        onCancel: onCancel,
        onOpen: onOpen,
        onClose: onClose,
        data: data,
      );
    }
  }

  static AcToastHandle toast({
    String? title,
    String? message,
    Widget? content,
    IconData? icon,
    Duration? timer,
    ToastPosition? position,
    bool? showCloseButton,
    bool? pauseOnHover,
    bool? progressBar,
    AcMessageType? type,
    Function(BuildContext)? onOpen,
    Function(BuildContext)? onClose,
    Map<String, dynamic>? data,
  }) {
    final opts = defaultConfig.copyWith(
      title: title,
      message: message,
      content: content,
      icon: icon,
      timer: timer,
      position: position,
      showCloseButton: showCloseButton,
      pauseOnHover: pauseOnHover,
      progressBar: progressBar,
      type: type,
      onOpen: onOpen,
      onClose: onClose,
      data: data,
      toast: true,
    );

    final context = _context;
    final pos = opts.position;
    if (!_activeToasts.containsKey(pos)) {
      _activeToasts[pos] = [];
    }

    final id = DateTime.now().millisecondsSinceEpoch;
    final toastData = _ToastData(id: id, options: opts);
    
    _activeToasts[pos]!.add(toastData);
    _refreshContainer(pos, context);

    return AcToastHandle(
      id: id,
      close: () {
        _activeToasts[pos]?.removeWhere((t) => t.id == id);
        _refreshContainer(pos, context);
      },
    );
  }

  static Future<AcConfirmResult> confirm({
    String? title,
    String? message,
    Widget? content,
    IconData? icon,
    Duration? timer,
    AcMessageType? type,
    bool? progressBar,
    bool? showConfirmButton,
    bool? showCancelButton,
    String? confirmText,
    String? denyText,
    bool? showInput,
    String? inputPlaceholder,
    String? inputValue,
    bool? allowOutsideClick,
    bool? allowEscapeKey,
    Function(AcConfirmResult)? onConfirm,
    Function(AcConfirmResult)? onCancel,
    Function(BuildContext)? onOpen,
    Function(BuildContext)? onClose,
    Map<String, dynamic>? data,
  }) {
    final opts = defaultConfig.copyWith(
      title: title,
      message: message,
      content: content,
      icon: icon,
      timer: timer,
      type: type,
      progressBar: progressBar,
      showConfirmButton: showConfirmButton,
      showCancelButton: showCancelButton,
      confirmText: confirmText,
      denyText: denyText,
      showInput: showInput,
      inputPlaceholder: inputPlaceholder,
      inputValue: inputValue,
      allowOutsideClick: allowOutsideClick,
      allowEscapeKey: allowEscapeKey,
      onConfirm: onConfirm,
      onCancel: onCancel,
      onOpen: onOpen,
      onClose: onClose,
      data: data,
      toast: false,
    );

    final completer = Completer<AcConfirmResult>();

    void openFn() {
      _modalOpen = true;
      showDialog<AcConfirmResult>(
        context: _context,
        barrierDismissible: opts.allowOutsideClick,
        builder: (context) => _AcMessageModal(
          options: opts,
          onResult: (result) {
            Navigator.pop(_context, result);
          },
        ),
      ).then((result) {
        final finalResult = result ?? AcConfirmResult(confirmed: false, dismissed: true);
        completer.complete(finalResult);
        _modalOpen = false;
        if (_modalQueue.isNotEmpty) {
          final next = _modalQueue.removeAt(0);
          next();
        }
      });
    }

    if (_modalOpen) {
      _modalQueue.add(openFn);
    } else {
      openFn();
    }

    return completer.future;
  }

  static void _refreshContainer(ToastPosition position, BuildContext context) {
    _containers[position]?.remove();
    
    if (_activeToasts[position] == null || _activeToasts[position]!.isEmpty) {
      _containers.remove(position);
      return;
    }

    final entry = OverlayEntry(
      builder: (context) => _ToastContainer(
        position: position,
        toasts: List.from(_activeToasts[position]!),
        onRemove: (id) {
          _activeToasts[position]?.removeWhere((t) => t.id == id);
          _refreshContainer(position, context);
        },
      ),
    );

    _containers[position] = entry;
    Overlay.of(context).insert(entry);
  }

  static void closeAllToasts() {
    for (final entry in _containers.values) {
      entry.remove();
    }
    _containers.clear();
    _activeToasts.clear();
  }
}

class AcToastHandle {
  final int id;
  final VoidCallback close;
  AcToastHandle({required this.id, required this.close});
}

class _ToastData {
  final int id;
  final AcMessageOptions options;
  _ToastData({required this.id, required this.options});
}

class _ToastContainer extends StatelessWidget {
  final ToastPosition position;
  final List<_ToastData> toasts;
  final Function(int) onRemove;

  const _ToastContainer({
    required this.position,
    required this.toasts,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isCenter = position.name.contains('Center');
    
    return Positioned(
      top: position.name.contains('top') ? 20 : null,
      bottom: position.name.contains('bottom') ? 20 : null,
      left: position.name.contains('Left') ? 20 : (isCenter ? 0 : null),
      right: position.name.contains('Right') ? 20 : (isCenter ? 0 : null),
      child: IgnorePointer(
        ignoring: false, // The container itself is invisible, but we want toasts to be clickable
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: position.name.contains('Left') 
                ? CrossAxisAlignment.start 
                : (position.name.contains('Right') ? CrossAxisAlignment.end : CrossAxisAlignment.center),
            children: toasts.map((t) => _AcMessageToast(
              key: ValueKey(t.id),
              options: t.options,
              onClose: () => onRemove(t.id),
            )).toList(),
          ),
        ),
      ),
    );
  }
}

class _AcMessageToast extends StatefulWidget {
  final AcMessageOptions options;
  final VoidCallback onClose;

  const _AcMessageToast({super.key, required this.options, required this.onClose});

  @override
  State<_AcMessageToast> createState() => _AcMessageToastState();
}

class _AcMessageToastState extends State<_AcMessageToast> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.options.timer,
    );

    if (widget.options.timer != null && widget.options.timer! > Duration.zero) {
      _startTimer();
    }
    
    widget.options.onOpen?.call(context);
  }

  void _startTimer() {
    _progressController.forward(from: _progressController.value);
    _timer = Timer(widget.options.timer! * (1 - _progressController.value), () {
      _close();
    });
  }

  void _pauseTimer() {
    if (!widget.options.pauseOnHover) return;
    _timer?.cancel();
    _progressController.stop();
  }

  void _resumeTimer() {
    if (!widget.options.pauseOnHover) return;
    _startTimer();
  }

  void _close() {
    widget.options.onClose?.call(context);
    widget.onClose();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AcMessageTheme.getColor(widget.options.type);
    final icon = widget.options.icon ?? AcMessageTheme.getIcon(widget.options.type);

    return MouseRegion(
      onEnter: (_) => _pauseTimer(),
      onExit: (_) => _resumeTimer(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.options.type != AcMessageType.none)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.options.title != null)
                          Text(widget.options.title!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (widget.options.message != null)
                          Text(widget.options.message!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        if (widget.options.content != null) widget.options.content!,
                      ],
                    ),
                  ),
                  if (widget.options.showCloseButton)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _close,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
            if (widget.options.progressBar && widget.options.timer != null)
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: 1 - _progressController.value,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.3)),
                    minHeight: 4,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AcMessageModal extends StatefulWidget {
  final AcMessageOptions options;
  final Function(AcConfirmResult) onResult;

  const _AcMessageModal({required this.options, required this.onResult});

  @override
  State<_AcMessageModal> createState() => _AcMessageModalState();
}

class _AcMessageModalState extends State<_AcMessageModal> with SingleTickerProviderStateMixin {
  late TextEditingController _inputController;
  late AnimationController _progressController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.options.inputValue);
    _progressController = AnimationController(
      vsync: this,
      duration: widget.options.timer,
    );

    if (widget.options.timer != null && widget.options.timer! > Duration.zero) {
      _startTimer();
    }
    
    widget.options.onOpen?.call(context);
  }

  void _startTimer() {
    _progressController.forward(from: _progressController.value);
    _timer = Timer(widget.options.timer! * (1 - _progressController.value), () {
      _close(confirmed: false, dismissed: true);
    });
  }

  void _pauseTimer() {
    if (!widget.options.pauseOnHover) return;
    _timer?.cancel();
    _progressController.stop();
  }

  void _resumeTimer() {
    if (!widget.options.pauseOnHover) return;
    _startTimer();
  }

  void _close({required bool confirmed, String? value, bool dismissed = false}) {
    final result = AcConfirmResult(confirmed: confirmed, value: value, dismissed: dismissed);
    if (confirmed) {
      widget.options.onConfirm?.call(result);
    } else if (dismissed) {
      widget.options.onCancel?.call(result);
    }
    widget.options.onClose?.call(context);
    widget.onResult(result);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AcMessageTheme.getColor(widget.options.type);
    final icon = widget.options.icon ?? AcMessageTheme.getIcon(widget.options.type);

    return MouseRegion(
      onEnter: (_) => _pauseTimer(),
      onExit: (_) => _resumeTimer(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (widget.options.type != AcMessageType.none) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 40),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (widget.options.title != null)
                        Text(
                          widget.options.title!, 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      if (widget.options.message != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          widget.options.message!, 
                          textAlign: TextAlign.center, 
                          style: const TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                      ],
                      if (widget.options.content != null) ...[
                        const SizedBox(height: 16),
                        widget.options.content!,
                      ],
                      if (widget.options.showInput) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _inputController,
                          decoration: InputDecoration(
                            hintText: widget.options.inputPlaceholder,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          autofocus: true,
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.options.showCancelButton) ...[
                            Expanded(
                              child: TextButton(
                                onPressed: () => _close(confirmed: false, dismissed: true),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(widget.options.denyText, style: const TextStyle(color: Colors.grey)),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (widget.options.showConfirmButton)
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color == Colors.transparent ? Theme.of(context).primaryColor : color,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                onPressed: () => _close(
                                  confirmed: true, 
                                  value: widget.options.showInput ? _inputController.text : null,
                                ),
                                child: Text(widget.options.confirmText),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.options.progressBar && widget.options.timer != null)
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: 1 - _progressController.value,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.3)),
                        minHeight: 4,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
