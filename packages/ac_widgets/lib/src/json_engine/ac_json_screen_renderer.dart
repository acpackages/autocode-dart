import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'ac_action_registry.dart';
import 'ac_register_default_builders.dart';
import 'ac_screen_context.dart';
import 'ac_widget_registry.dart';

/// Root widget that dynamically interprets and renders a JSON screen descriptor.
class AcJsonScreenRenderer extends StatefulWidget {
  final Map<String, dynamic> descriptor;
  final Map<String, dynamic> params;
  final String accounteeId;
  final String currencyCode;
  final Map<String, dynamic> rights;

  const AcJsonScreenRenderer({
    super.key,
    required this.descriptor,
    this.params = const {},
    this.accounteeId = '',
    this.currencyCode = 'INR',
    this.rights = const {},
  });

  /// Factory from a raw JSON string.
  static AcJsonScreenRenderer fromJson(
    String jsonString, {
    Map<String, dynamic> params = const {},
    String accounteeId = '',
    String currencyCode = 'INR',
    Map<String, dynamic> rights = const {},
    Key? key,
  }) {
    final descriptor = json.decode(jsonString) as Map<String, dynamic>;
    return AcJsonScreenRenderer(
      key: key,
      descriptor: descriptor,
      params: params,
      accounteeId: accounteeId,
      currencyCode: currencyCode,
      rights: rights,
    );
  }

  @override
  State<AcJsonScreenRenderer> createState() => _AcJsonScreenRendererState();
}

class _AcJsonScreenRendererState extends State<AcJsonScreenRenderer> {
  late AcScreenContext _ctx;
  late bool _initialized;
  static bool _buildersRegistered = false;

  @override
  void initState() {
    super.initState();
    final hasOnInit = (widget.descriptor['lifecycle'] as Map?)?['onInit'] != null;
    _initialized = !hasOnInit;

    if (!_buildersRegistered) {
      acRegisterDefaultBuilders();
      _buildersRegistered = true;
    }

    _initContext();
    _registerNavigationAndPanelHandlers();
    if (hasOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _runLifecycle('onInit');
      });
    }
  }

  void _initContext() {
    final initialState = Map<String, dynamic>.from(
      widget.descriptor['state'] as Map? ?? {},
    );
    _ctx = AcScreenContext(
      screenId: widget.descriptor['id']?.toString() ?? '',
      params: Map<String, dynamic>.from(widget.params),
      accounteeId: widget.accounteeId,
      currencyCode: widget.currencyCode,
      rights: Map<String, dynamic>.from(widget.rights),
      initialState: initialState,
      onStateChange: () {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _runLifecycle(String event) async {
    final lifecycle = widget.descriptor['lifecycle'] as Map? ?? {};
    final action = lifecycle[event];
    if (action != null) {
      await AcActionRegistry.execute(action, _ctx);
    }
    if (event == 'onInit' && mounted && !_initialized) {
      setState(() => _initialized = true);
    }
  }

  void _registerNavigationAndPanelHandlers() {
    AcActionRegistry.addHandler('nav.open', (action, ctx, {event}) async {
      if (!mounted) return;
      final screen = ctx.resolveString(action['screen']);
      final params = ctx.resolveMap(Map<String, dynamic>.from(action['params'] ?? {}));
      Navigator.of(context).pushNamed(screen, arguments: params);
    });

    AcActionRegistry.addHandler('nav.back', (action, ctx, {event}) async {
      if (!mounted) return;
      final result = action['result'] != null ? ctx.resolve(action['result']) : null;
      Navigator.of(context).pop(result);
    });

    AcActionRegistry.addHandler('panel.toast', (action, ctx, {event}) async {
      if (!mounted) return;
      final message = ctx.resolveString(action['message'] ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    });

    AcActionRegistry.addHandler('panel.confirm', (action, ctx, {event}) async {
      if (!mounted) return;
      final title = ctx.resolveString(action['title'] ?? 'Confirm');
      final message = ctx.resolveString(action['message'] ?? '');
      final confirmLabel = ctx.resolveString(action['confirmLabel'] ?? 'Confirm');
      final cancelLabel = ctx.resolveString(action['cancelLabel'] ?? 'Cancel');

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: Text(cancelLabel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final onConfirm = action['onConfirm'];
        if (onConfirm != null) await AcActionRegistry.execute(onConfirm, ctx, event: event);
      } else {
        final onCancel = action['onCancel'];
        if (onCancel != null) await AcActionRegistry.execute(onCancel, ctx, event: event);
      }
    });

    AcActionRegistry.addHandler('panel.modal', (action, ctx, {event}) async {
      if (!mounted) return;
      final screenId = ctx.resolveString(action['screen'] ?? '');
      final params = ctx.resolveMap(Map<String, dynamic>.from(action['params'] ?? {}));

      final modals = widget.descriptor['modals'] as Map? ?? {};
      final modalDescriptor = modals[screenId];

      if (modalDescriptor is Map) {
        final result = await showModalBottomSheet<dynamic>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => AcJsonScreenRenderer(
            descriptor: Map<String, dynamic>.from(modalDescriptor),
            params: params,
            accounteeId: widget.accounteeId,
            currencyCode: widget.currencyCode,
            rights: widget.rights,
          ),
        );
        final onClose = action['onClose'];
        if (onClose != null) {
          await AcActionRegistry.execute(onClose, ctx, event: {'result': result});
        }
      }
    });

    AcActionRegistry.addHandler('panel.close', (action, ctx, {event}) async {
      if (!mounted) return;
      final result = action['result'] != null ? ctx.resolve(action['result']) : null;
      Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final header = widget.descriptor['header'] as Map?;
    final title = widget.descriptor['title'];
    final body = widget.descriptor['body'];
    final fab = widget.descriptor['fab'];
    final bottomBar = widget.descriptor['bottomBar'];

    final hasAppBar = header != null || title != null;

    return Scaffold(
      appBar: hasAppBar
          ? _buildAppBar(header != null ? Map<String, dynamic>.from(header) : <String, dynamic>{'title': title})
          : null,
      body: body is Map ? _buildBody(Map<String, dynamic>.from(body)) : const SizedBox.shrink(),
      floatingActionButton: fab is Map ? AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(fab), _ctx) : null,
      bottomNavigationBar: bottomBar is Map ? _buildBottomBar(Map<String, dynamic>.from(bottomBar)) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(Map<String, dynamic> header) {
    final titleExpr = header['title'] ?? widget.descriptor['title'] ?? '';
    final title = _ctx.resolveString(titleExpr);
    final actions = header['actions'] as List? ?? [];

    return PreferredSize(
      preferredSize: const Size.fromHeight(42),
      child: Container(
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFD8DBE0))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF23282D),
              ),
            ),
            const Spacer(),
            for (final a in actions)
              if (a is Map) ...[
                const SizedBox(width: 6),
                AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(a), _ctx),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> bodyDesc) {
    final key = bodyDesc['element']?.toString() ?? bodyDesc['widget']?.toString() ?? '';
    final isList = key == 'act-list' || key == 'list' || key == 'act-repeater' || key == 'repeater';

    if (isList) {
      return AcWidgetRegistry.buildWidget(bodyDesc, _ctx);
    }

    final children = bodyDesc['children'] as List?;
    if (key == 'act-column' || key == 'column') {
      if (children != null) {
        int listIndex = -1;
        for (int i = 0; i < children.length; i++) {
          final c = children[i];
          if (c is Map) {
            final ck = c['element']?.toString() ?? c['widget']?.toString();
            if (ck == 'act-list' || ck == 'list' || ck == 'act-repeater' || ck == 'repeater') {
              listIndex = i;
              break;
            }
          }
        }

        if (listIndex != -1) {
          final preList = children.sublist(0, listIndex);
          final listChild = children[listIndex] as Map;
          final postList = children.sublist(listIndex + 1);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (preList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final c in preList)
                        if (c is Map) AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(c), _ctx),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(listChild), _ctx),
                ),
              ),
              if (postList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final c in postList)
                        if (c is Map) AcWidgetRegistry.buildWidget(Map<String, dynamic>.from(c), _ctx),
                    ],
                  ),
                ),
            ],
          );
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AcWidgetRegistry.buildWidget(bodyDesc, _ctx),
    );
  }

  Widget _buildBottomBar(Map<String, dynamic> bottomBarDesc) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AcWidgetRegistry.buildWidget(bottomBarDesc, _ctx),
    );
  }
}
