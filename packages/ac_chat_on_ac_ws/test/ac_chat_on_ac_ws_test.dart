// import 'package:test/test.dart';
// import 'package:ac_chat_on_ac_ws/ac_chat_on_ac_ws.dart';
//
// void main() {
//   group('WsChatEvents', () {
//     test('all event name constants are non-empty strings', () {
//       expect(WsChatEvents.messageSend, isNotEmpty);
//       expect(WsChatEvents.deliveryAck, isNotEmpty);
//       expect(WsChatEvents.readAck, isNotEmpty);
//       expect(WsChatEvents.messageEdit, isNotEmpty);
//       expect(WsChatEvents.messageDelete, isNotEmpty);
//       expect(WsChatEvents.conversationCreate, isNotEmpty);
//       expect(WsChatEvents.typing, isNotEmpty);
//       expect(WsChatEvents.messageReceived, isNotEmpty);
//       expect(WsChatEvents.statusUpdated, isNotEmpty);
//       expect(WsChatEvents.conversationReceived, isNotEmpty);
//       expect(WsChatEvents.error, isNotEmpty);
//     });
//
//     test('client-to-server events are distinct from server-to-client events', () {
//       final clientToServer = {
//         WsChatEvents.messageSend,
//         WsChatEvents.deliveryAck,
//         WsChatEvents.readAck,
//         WsChatEvents.messageEdit,
//         WsChatEvents.messageDelete,
//         WsChatEvents.conversationCreate,
//       };
//       final serverToClient = {
//         WsChatEvents.messageReceived,
//         WsChatEvents.statusUpdated,
//         WsChatEvents.conversationReceived,
//         WsChatEvents.error,
//       };
//       expect(clientToServer.intersection(serverToClient), isEmpty);
//     });
//   });
//
//   group('AcChatOnAcWs', () {
//     test('can be constructed with url and token callback', () {
//       final transport = AcChatOnAcWs(
//         wsUrl: 'ws://localhost:3002',
//         getJwtToken: () => 'test-jwt-token',
//       );
//       expect(transport, isNotNull);
//     });
//
//     test('stopListening does not throw when not connected', () async {
//       final transport = AcChatOnAcWs(
//         wsUrl: 'ws://localhost:3002',
//         getJwtToken: () => 'test-jwt-token',
//       );
//       // Should complete without error even though connect was never called
//       await expectLater(transport.stopListening(), completes);
//     });
//
//     test('acknowledgeUpdate is a no-op and does not throw', () async {
//       final transport = AcChatOnAcWs(
//         wsUrl: 'ws://localhost:3002',
//         getJwtToken: () => 'test-jwt-token',
//       );
//       await expectLater(
//         transport.acknowledgeUpdate(updateId: 'some-update-id'),
//         completes,
//       );
//     });
//
//     test('sendTypingIndicator does not throw when not connected', () async {
//       final transport = AcChatOnAcWs(
//         wsUrl: 'ws://localhost:3002',
//         getJwtToken: () => 'token',
//       );
//       // _socket is null — volatile emit should be a no-op
//       await expectLater(
//         transport.sendTypingIndicator(
//           conversationId: 'conv-1',
//           recipientIds: ['user-2'],
//           isTyping: true,
//         ),
//         completes,
//       );
//     });
//   });
// }
