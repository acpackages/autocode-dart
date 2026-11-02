/// AutoCode Multi-Window support for Flutter desktop.
///
/// All OS windows share one single Flutter engine instance and one Dart isolate.
/// Supports in-memory state sharing, zero-IPC serialization, and lightweight secondary views.
library ac_multiwindow;

export 'multiview_desktop.dart';
export 'src/multi_view_desktop.dart';
export 'src/run_multi_app.dart';
export 'src/window_options.dart';
export 'src/window_listener.dart';
export 'src/title_bar_style.dart';

import 'src/multi_view_desktop.dart';

/// AutoCode alias for [MultiViewDesktop].
typedef AcMultiWindow = MultiViewDesktop;
