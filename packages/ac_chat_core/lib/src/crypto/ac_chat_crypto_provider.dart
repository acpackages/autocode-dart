/// Abstract interface for client-side zero-knowledge end-to-end encryption
/// with strictly named parameters.
abstract class AcChatCryptoProvider {
  /// Encrypts [plainText] for the intended [recipientUserIds] in [conversationId].
  Future<String> encryptPayload({
    required String conversationId,
    required String plainText,
    required List<String> recipientUserIds,
  });

  /// Decrypts [cipherText] received from [senderUserId] in [conversationId].
  Future<String> decryptPayload({
    required String conversationId,
    required String cipherText,
    required String senderUserId,
  });
}
