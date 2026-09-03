/// Abstract interface for monitoring device network connectivity.
abstract class AcChatConnectivityProvider {
  /// Stream emitting boolean values indicating if the device is currently online.
  Stream<bool> watchIsOnline();

  /// Synchronous snapshot of the current connectivity state.
  bool get isOnline;
}
