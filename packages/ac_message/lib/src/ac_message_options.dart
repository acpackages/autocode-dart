import 'package:flutter/material.dart';
import 'ac_message_type.dart';

enum ToastPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

class AcMessageOptions {
  final String? title;
  final String? message;
  final Widget? content; // Replaces 'html' in TS
  final IconData? icon; // Replaces 'iconSvg' in TS
  final Duration? timer; // Replaces 'timer' in ms
  final bool toast;
  final ToastPosition position;
  final bool showCloseButton;
  final bool pauseOnHover;
  final bool progressBar;
  final AcMessageType type;
  final String? className; // Kept for consistency, could be used for styling keys
  
  // for confirm:
  final bool showConfirmButton;
  final bool showCancelButton;
  final String confirmText;
  final String denyText;
  final bool showInput;
  final String? inputPlaceholder;
  final String? inputValue;
  final bool allowOutsideClick;
  final bool allowEscapeKey;
  
  // callback hooks
  final Function(AcConfirmResult)? onConfirm;
  final Function(AcConfirmResult)? onCancel;
  final Function(BuildContext)? onOpen;
  final Function(BuildContext)? onClose;
  
  // arbitrary extra data
  final Map<String, dynamic>? data;

  const AcMessageOptions({
    this.title,
    this.message,
    this.content,
    this.icon,
    this.timer,
    this.toast = true,
    this.position = ToastPosition.topRight,
    this.showCloseButton = true,
    this.pauseOnHover = true,
    this.progressBar = true,
    this.type = AcMessageType.none,
    this.className,
    this.showConfirmButton = true,
    this.showCancelButton = true,
    this.confirmText = 'OK',
    this.denyText = 'Cancel',
    this.showInput = false,
    this.inputPlaceholder,
    this.inputValue,
    this.allowOutsideClick = false,
    this.allowEscapeKey = true,
    this.onConfirm,
    this.onCancel,
    this.onOpen,
    this.onClose,
    this.data,
  });

  AcMessageOptions copyWith({
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
    String? className,
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
    return AcMessageOptions(
      title: title ?? this.title,
      message: message ?? this.message,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      timer: timer ?? this.timer,
      toast: toast ?? this.toast,
      position: position ?? this.position,
      showCloseButton: showCloseButton ?? this.showCloseButton,
      pauseOnHover: pauseOnHover ?? this.pauseOnHover,
      progressBar: progressBar ?? this.progressBar,
      type: type ?? this.type,
      className: className ?? this.className,
      showConfirmButton: showConfirmButton ?? this.showConfirmButton,
      showCancelButton: showCancelButton ?? this.showCancelButton,
      confirmText: confirmText ?? this.confirmText,
      denyText: denyText ?? this.denyText,
      showInput: showInput ?? this.showInput,
      inputPlaceholder: inputPlaceholder ?? this.inputPlaceholder,
      inputValue: inputValue ?? this.inputValue,
      allowOutsideClick: allowOutsideClick ?? this.allowOutsideClick,
      allowEscapeKey: allowEscapeKey ?? this.allowEscapeKey,
      onConfirm: onConfirm ?? this.onConfirm,
      onCancel: onCancel ?? this.onCancel,
      onOpen: onOpen ?? this.onOpen,
      onClose: onClose ?? this.onClose,
      data: data ?? this.data,
    );
  }
}

class AcConfirmResult {
  final bool confirmed;
  final String? value;
  final bool dismissed;

  AcConfirmResult({
    required this.confirmed,
    this.value,
    this.dismissed = false,
  });
}
