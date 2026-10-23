/// The main entry point for the ac_mirrors library.
///
/// This file exports the public API and uses conditional exports to provide
/// the correct underlying implementation based on the platform.
library ac_mirrors;

// Export the public API and annotations
export 'src/api.dart';
export 'annotations.dart';

// Export the static generated mirrors implementation
export 'src/impl/generated.dart';
