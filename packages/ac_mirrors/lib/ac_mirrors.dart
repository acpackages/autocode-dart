/// The main entry point for the ac_mirrors library.
///
/// This file exports the public API and uses conditional exports to provide
/// the correct underlying implementation based on the platform.
library ac_mirrors;

// Export the public API and annotations
export 'src/api.dart';
export 'annotations.dart';

// Conditionally export the correct implementation.
// - If `dart:mirrors` is available (i.e., on the Dart VM), it uses the `vm.dart` implementation.
// - Otherwise (i.e., Flutter, Web, AOT), it uses the `generated.dart` implementation which
//   relies on code generation.
export 'src/impl/generated.dart' if (dart.library.mirrors) 'src/impl/vm.dart';
