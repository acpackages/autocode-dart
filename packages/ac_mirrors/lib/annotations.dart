/// An annotation to mark classes and other annotations for which reflection
/// metadata should be generated.
///
/// Use this on any class you want to inspect at runtime. You can also use this
/// to create your own "meta-annotations".
class AcReflectable {
  const AcReflectable();
}

/// A convenient top-level constant instance of [AcReflectable].
const acReflectable = AcReflectable();
