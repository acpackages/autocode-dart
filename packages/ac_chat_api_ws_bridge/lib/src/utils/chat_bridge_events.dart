/// Constants for WebSocket event names used across the Chat Bridge.
class ChatBridgeEvents {
  // RPC Requests (Client -> Server)
  static const String getConversations = 'chat:getConversations';
  static const String getMessages = 'chat:getMessages';
  static const String sendMessage = 'chat:sendMessage';
  static const String insertConversation = 'chat:insertConversation';
  static const String deleteConversation = 'chat:deleteConversation';
  static const String editMessage = 'chat:editMessage';
  static const String deleteMessageForMe = 'chat:deleteMessageForMe';
  static const String deleteMessageForEveryone = 'chat:deleteMessageForEveryone';
  static const String notifyConversationRead = 'chat:notifyConversationRead';
  static const String sendTyping = 'chat:sendTyping';
  static const String getUserById = 'chat:getUserById';
  static const String getUsers = 'chat:getUsers';
  static const String getRemoteUsers = 'chat:getRemoteUsers';
  static const String getConversationUsers = 'chat:getConversationUsers';
  static const String addReaction = 'chat:addReaction';
  static const String removeReaction = 'chat:removeReaction';
  static const String sync = 'chat:sync';

  // Push Events (Server -> Client)
  static const String messageReceived = 'chat:messageReceived';
  static const String dataChanged = 'chat:dataChanged';
  static const String typingChanged = 'chat:typingChanged';
  static const String messagesRead = 'chat:messagesRead';
  static const String messagesDelivered = 'chat:messagesDelivered';
  static const String conversationUpdated = 'chat:conversationUpdated';
}
