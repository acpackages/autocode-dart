import 'dart:io';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_web_socket/ac_web_socket.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_sync/ac_sync.dart';

class AcSyncOnWs {
  final String eventName;
  final AcWebSocket? socket;
  final AcSyncDestinationDatabase? syncDestinationDatabase;
  final AcSyncSourceDatabase? syncSourceDatabase;

  Future<void> Function({required AcSyncProgress progress})? onSyncProgress;
  List<int> _receivedSyncStream = [];
  Future<void> Function()? onSyncStart;
  Future<void> Function()? onSyncComplete;
  String? _destinationFilePath;

  AcLogger logger = AcLogger(logMessages: true,logDirectory: 'logs',logType: AcEnumLogType.console,logFileName: 'ac-web.log');

  AcSyncOnWs({
    this.socket,
    this.syncDestinationDatabase,
    this.syncSourceDatabase,
    this.eventName = 'acSync',
    this.onSyncStart,
    this.onSyncComplete,
    this.onSyncProgress,
  }) {
    _init();
  }

  Future<AcResult> sync({String? syncId}) async {
    AcResult result = AcResult();
    if (socket != null && syncDestinationDatabase != null) {
      logger.log("[AcSyncOnWs] Initiating sync request from database...");
      result = await this.syncDestinationDatabase!.sync(syncId: syncId);
    } else {
      result.setFailure(message: "Socket not set");
    }
    return result;
  }

  Future<AcResult> getDatabaseFileFromSource({required String destinationFilePath}) async {
    AcResult result = AcResult();
    if (socket != null && syncDestinationDatabase != null) {
      this._destinationFilePath = destinationFilePath;
      Map<String,dynamic> data = {
        'syncAction':'getDatabaseFileForDestination',
        'syncData':{
          'clientDeviceId': syncDestinationDatabase!.deviceId,
        }
      };
      this.socket!.emit(event: eventName,data:data );
      logger.log("[AcSyncOnWs] Getting database file from source...");
      result.setSuccess(message: "Database file request sent");
    } else {
      result.setFailure(message: "Socket not set");
    }
    return result;
  }

  void _init() {
    if (syncDestinationDatabase != null) {
      // Classic callbacks for compatibility
      Future<void> Function(AcNotifyChangesToSourceFunArgs callbackArgs) notifyChangesCallback = (AcNotifyChangesToSourceFunArgs callbackArgs) async {
        Map<String, dynamic> data = {
          'syncAction': 'notifyChangesFromDestination',
          'syncData': callbackArgs.toJson()
        };
        socket!.emit(event: eventName, data: data, callback: ({response}) {
          AcResult result = AcResult.instanceFromJson(jsonData: response);
          if (result.isSuccess()) {
            AcNotifyChangesCallbackArgs resultCallbackArgs = AcNotifyChangesCallbackArgs.instanceFromJson(jsonData: result.value);
            callbackArgs.notifyCallback!(resultCallbackArgs);
          }
        });
      };
      Future<void> Function(AcNotifySyncSuccessToSourceFunArgs callbackArgs) notifySuccessCallback = (AcNotifySyncSuccessToSourceFunArgs callbackArgs) async {
        logger.log("[AcSyncOnWs] Destination notifying sync success to source...");
        Map<String, dynamic> data = {
          'syncAction': 'notifySyncSuccessToSource',
          'syncData': callbackArgs.toJson()
        };
        socket!.emit(event: eventName, data: data, callback: ({response}) {
          AcResult result = AcResult.instanceFromJson(jsonData: response);
          if (result.isSuccess()) {
            AcNotifySuccessCallbackArgs resultCallbackArgs = AcNotifySuccessCallbackArgs.instanceFromJson(jsonData: result.value);
            callbackArgs.notifyCallback!(resultCallbackArgs);
          }
        });
      };
      syncDestinationDatabase!.notifyChangesToSourceFun = notifyChangesCallback;
      syncDestinationDatabase!.notifySyncSuccessToSourceFun = notifySuccessCallback;

      // Session message sender
      syncDestinationDatabase!.onSendMessage = (AcSyncMessage message) async {
        logger.log("[AcSyncOnWs] Destination sending session message: ${message.messageType}");
        Map<String, dynamic> data = {
          'syncAction': 'sessionMessage',
          'syncData': message.toJson(),
        };
        socket!.emit(
          event: eventName,
          data: data,
          callback: ({response}) async {
            if (response != null) {
              AcSyncMessage responseMsg = AcSyncMessage.instanceFromJson(jsonData: Map<String, dynamic>.from(response));
              logger.log("[AcSyncOnWs] Destination received session message response: ${responseMsg.messageType}");
              var responses = await syncDestinationDatabase!.receiveMessage(responseMsg);
              for (var resp in responses) {
                await syncDestinationDatabase!.sendMessage(resp);
              }
            }
          }
        );
      };

      // Session message receiver on destination
      socket!.on(event: eventName, handler: ({data, callback}) async {
        Map<String, dynamic> eventData = Map.from(data);
        if (eventData.containsKey("syncAction")) {
          String syncAction = eventData.getString("syncAction");
          Map<String, dynamic> syncData = Map.from(eventData.getMap("syncData"));
          if (syncAction.equalsIgnoreCase("sessionMessage")) {
            AcSyncMessage serverMsg = AcSyncMessage.instanceFromJson(jsonData: syncData);
            logger.log("[AcSyncOnWs] Destination received session message: ${serverMsg.messageType}");
            var responses = await syncDestinationDatabase!.receiveMessage(serverMsg);
            if (responses.isNotEmpty) {
              if (callback != null) {
                callback(response: responses.first.toJson());
                for (int i = 1; i < responses.length; i++) {
                  await syncDestinationDatabase!.sendMessage(responses[i]);
                }
              } else {
                for (var resp in responses) {
                  await syncDestinationDatabase!.sendMessage(resp);
                }
              }
            } else {
              if (callback != null) {
                callback(response: null);
              }
            }
          }
        }
      });

      socket!.onFile(event: "${eventName}DestinationFile", handler: ({required transferId, required name, required totalSize, required stream, metadata}) async {
        logger.log("[AcSyncOnWs] Receiving sync stream start. Total size: $totalSize");
        if (onSyncStart != null) onSyncStart!();
        File destinationFile = File(_destinationFilePath!);
        String tempFilePath = "${destinationFile.parent.absolute.path}/ac-sync-temp-file-${Autocode.uuid()}";
        File tempDestinationFile = File(tempFilePath);
        logger.log("[AcSyncOnWs] ${tempDestinationFile.absolute.path}");
        if (!tempDestinationFile.existsSync()) {
          tempDestinationFile.createSync(recursive: true);
        }

        int received = 0;
        await for (final chunk in stream) {
          tempDestinationFile.writeAsBytesSync(chunk, mode: FileMode.append, flush: true);
          received += chunk.length;
          if (onSyncProgress != null) {
            onSyncProgress!(progress: AcSyncProgress(
              title: 'Receiving Database',
              description: 'Downloading synchronization data...',
              total: totalSize,
              progress: received / totalSize,
              pendingCount: 1,
            ));
          }
        }
        tempDestinationFile.renameSync("${destinationFile.parent.absolute.path}/${destinationFile.fileName}");
        logger.log("[AcSyncOnWs] Sync stream received. Total bytes: ${_receivedSyncStream.length}");
        if (onSyncComplete != null) {
          await onSyncComplete!();
        }
        _receivedSyncStream = [];
      });
    } else {
      // Session message sender on source
      if (syncSourceDatabase != null) {
        syncSourceDatabase!.onSendMessage = (AcSyncMessage message) async {
          logger.log("[AcSyncOnWs] Source sending session message: ${message.messageType}");
          Map<String, dynamic> data = {
            'syncAction': 'sessionMessage',
            'syncData': message.toJson(),
          };
          socket!.emit(
            event: eventName,
            data: data,
            callback: ({response}) async {
              if (response != null) {
                AcSyncMessage responseMsg = AcSyncMessage.instanceFromJson(jsonData: Map<String, dynamic>.from(response));
                logger.log("[AcSyncOnWs] Source received session message response: ${responseMsg.messageType}");
                var responses = await syncSourceDatabase!.receiveMessage(responseMsg);
                for (var resp in responses) {
                  await syncSourceDatabase!.sendMessage(resp);
                }
              }
            }
          );
        };
      }

      socket!.on(event: eventName, handler: ({data, callback}) async {
        Map<String, dynamic> eventData = Map.from(data);
        if (eventData.containsKey("syncAction")) {
          String syncAction = eventData.getString("syncAction");
          Map<String, dynamic> syncData = Map.from(eventData.getMap("syncData"));
          if (syncAction.equalsIgnoreCase("sessionMessage")) {
            AcResult result = AcResult();
            if (syncSourceDatabase != null) {
              AcSyncMessage clientMsg = AcSyncMessage.instanceFromJson(jsonData: syncData);
              logger.log("[AcSyncOnWs] Source received session message: ${clientMsg.messageType}");
              var responses = await syncSourceDatabase!.receiveMessage(clientMsg);
              if (responses.isNotEmpty) {
                if (callback != null) {
                  callback(response: responses.first.toJson());
                  for (int i = 1; i < responses.length; i++) {
                    await syncSourceDatabase!.sendMessage(responses[i]);
                  }
                } else {
                  for (var resp in responses) {
                    await syncSourceDatabase!.sendMessage(resp);
                  }
                }
              } else {
                if (callback != null) {
                  callback(response: null);
                }
              }
            } else {
              result.setFailure(message: "Source database for sync not set");
              if (callback != null) {
                callback(response: result);
              }
            }
          } else if (syncAction.equalsIgnoreCase("notifyChangesFromDestination")) {
            AcResult result = AcResult();
            if (syncSourceDatabase != null) {
              AcNotifyChangesToSourceFunArgs callbackArgs = AcNotifyChangesToSourceFunArgs.instanceFromJson(jsonData: syncData);
              result = await syncSourceDatabase!.handleNotifyChangesFromDestination(destinationNotifyArgs: callbackArgs);
            } else {
              result.setFailure(message: "Destination database for sync not set");
            }
            callback!(response: result);
          } else if (syncAction.equalsIgnoreCase("notifySyncSuccessToSource")) {
            AcResult result = AcResult();
            if (syncSourceDatabase != null) {
              AcNotifySyncSuccessToSourceFunArgs callbackArgs = AcNotifySyncSuccessToSourceFunArgs.instanceFromJson(jsonData: syncData);
              result = await syncSourceDatabase!.handleNotifySyncSuccessFromSource(destinationNotifyArgs: callbackArgs);
            } else {
              result.setFailure(message: "Destination database for sync not set");
            }
            callback!(response: result);
          } else if (syncAction.equalsIgnoreCase("getDatabaseFileForDestination")) {
            AcResult result = AcResult();
            if (syncSourceDatabase != null) {
              String tempPath = "_ac_sync_on_ws_/temp_dest_file/temp_sync_${Autocode.uuid()}.db";
              File tempFile = File(tempPath);

              try {
                // 1. Create temporary destination copy
                tempFile.createSync(recursive: true);
                logger.log("[AcSyncOnWs] Creating temporary destination copy for sync...");
                String? clientDeviceId = syncData.getString("clientDeviceId");
                if (clientDeviceId.isEmpty) {
                  clientDeviceId = null;
                }
                await syncSourceDatabase!.createDatabaseFileForDestination(
                  destinationPath: tempPath,
                  clientDeviceId: clientDeviceId,
                );
                logger.log("[AcSyncOnWs] Original file size : ${File(syncSourceDatabase!.dao!.sqlConnection.database).lengthSync()}");
                logger.log("[AcSyncOnWs] Temporary file size : ${tempFile.lengthSync()}");
                // 2. Send the data via stream from source to destination
                logger.log("[AcSyncOnWs] Streaming database content to client...");
                if (onSyncStart != null) onSyncStart!();
                final int totalSize = await tempFile.length();
                await socket!.sendFile(
                  file: tempFile,
                  event: "${eventName}DestinationFile",
                  onProgress: (progress) {
                    if (onSyncProgress != null) {
                      onSyncProgress!(progress: AcSyncProgress(
                        title: 'Sending Database',
                        description: 'Uploading synchronization data...',
                        total: totalSize,
                        progress: progress,
                        pendingCount: 1,
                      ));
                    }
                    logger.log("[AcSyncOnWs] Sync upload progress: ${(progress * 100).toStringAsFixed(1)}%");
                  },
                );
                if (onSyncComplete != null) onSyncComplete!();
                result.setSuccess(message: "Sync stream completed successfully");
                logger.log("[AcSyncOnWs] Sync stream complete.");
              } catch (e, stack) {
                logger.log("[AcSyncOnWs] Error during sync action: $e");
                result.setException(exception: e, stackTrace: stack);
              } finally {
                // 3. Remove the copy once done
                if (await tempFile.exists()) {
                  logger.log("[AcSyncOnWs] Removing temporary sync file...");
                  await tempFile.delete();
                }
              }
            } else {
              result.setFailure(message: "Source database for sync not set");
            }
            if (callback != null) {
              callback(response: result);
            }
          }
        }
      });
    }
  }
}
