import 'dart:convert';
import 'dart:typed_data';
import 'package:ac_patches_core/ac_patches_core.dart';
import 'package:ac_patches_format/ac_patches_format.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_web/ac_web.dart';
import 'package:autocode/autocode.dart';
import '../storage/ac_patch_storage_provider.dart';
import '../admin/ac_patches_admin_dashboard.dart';

class AcPatchDomainController {
  final AcWeb web;
  final IAcPatchStorageProvider storage;
  final String dataDictionaryName;
  final AcBaseSqlDao dao;

  late AcSqlDbTable tblApps;
  late AcSqlDbTable tblReleases;
  late AcSqlDbTable tblPatches;
  late AcSqlDbTable tblTracks;
  late AcSqlDbTable tblDevices;
  late AcSqlDbTable tblEvents;
  late AcSqlDbTable tblKeys;

  AcPatchDomainController({
    required this.web,
    required this.storage,
    required this.dao,
    this.dataDictionaryName = 'ac_patches',
  }) {
    tblApps = AcSqlDbTable(tableName: 'ac_patch_app', dataDictionaryName: dataDictionaryName, dao: dao);
    tblReleases = AcSqlDbTable(tableName: 'ac_patch_release', dataDictionaryName: dataDictionaryName, dao: dao);
    tblPatches = AcSqlDbTable(tableName: 'ac_patch', dataDictionaryName: dataDictionaryName, dao: dao);
    tblTracks = AcSqlDbTable(tableName: 'ac_patch_track', dataDictionaryName: dataDictionaryName, dao: dao);
    tblDevices = AcSqlDbTable(tableName: 'ac_patch_device', dataDictionaryName: dataDictionaryName, dao: dao);
    tblEvents = AcSqlDbTable(tableName: 'ac_patch_event', dataDictionaryName: dataDictionaryName, dao: dao);
    tblKeys = AcSqlDbTable(tableName: 'ac_patch_key', dataDictionaryName: dataDictionaryName, dao: dao);

    _registerRoutes();
  }

  void _registerRoutes() {
    web.post(
      url: '/api/v1/patch/check',
      handler: (AcWebRequestHandlerArgs args) => _handleCheck(args.webRequest),
    );
    web.post(
      url: '/api/v1/patch/report',
      handler: (AcWebRequestHandlerArgs args) => _handleReport(args.webRequest),
    );
    web.post(
      url: '/api/v1/patch/publish',
      handler: (AcWebRequestHandlerArgs args) => _handlePublish(args.webRequest),
    );
    web.post(
      url: '/api/v1/patch/rollback',
      handler: (AcWebRequestHandlerArgs args) => _handleRollback(args.webRequest),
    );
    web.post(
      url: '/api/v1/patch/upload',
      handler: (AcWebRequestHandlerArgs args) => _handleUpload(args.webRequest),
    );
    web.get(
      url: '/api/v1/patch/download/{patchId}',
      handler: (AcWebRequestHandlerArgs args) => _handleDownload(args.webRequest),
    );
    web.post(
      url: '/api/v1/release/register',
      handler: (AcWebRequestHandlerArgs args) => _handleRegisterRelease(args.webRequest),
    );
    web.get(
      url: '/api/v1/patch/status',
      handler: (AcWebRequestHandlerArgs args) => _handleStatus(args.webRequest),
    );
    web.get(
      url: '/admin',
      handler: (AcWebRequestHandlerArgs args) async => AcWebResponse.html(
        html: AcPatchesAdminDashboard.renderHtml(),
      ),
    );
    web.get(
      url: '/dashboard',
      handler: (AcWebRequestHandlerArgs args) async => AcWebResponse.html(
        html: AcPatchesAdminDashboard.renderHtml(),
      ),
    );
  }

  Future<AcWebResponse> _handleStatus(AcWebRequest request) async {
    try {
      final appId = (request.get['appId'] as String?) ?? '';

      final releaseRows = appId.isNotEmpty
          ? (await tblReleases.getRows(condition: "app_id = :appId", parameters: {':appId': appId})).rows
          : (await tblReleases.getRows()).rows;

      final patchRows = appId.isNotEmpty
          ? (await tblPatches.getRows(condition: "app_id = :appId", parameters: {':appId': appId})).rows
          : (await tblPatches.getRows()).rows;

      final trackRows = appId.isNotEmpty
          ? (await tblTracks.getRows(condition: "app_id = :appId", parameters: {':appId': appId})).rows
          : (await tblTracks.getRows()).rows;

      final deviceRows = appId.isNotEmpty
          ? (await tblDevices.getRows(condition: "app_id = :appId", parameters: {':appId': appId})).rows
          : (await tblDevices.getRows()).rows;

      final eventRows = appId.isNotEmpty
          ? (await tblEvents.getRows(condition: "app_id = :appId", parameters: {':appId': appId})).rows
          : (await tblEvents.getRows()).rows;

      final appRows = (await tblApps.getRows()).rows;

      return AcWebResponse.json(data: {
        'success': true,
        'appId': appId,
        'apps': appRows,
        'releases': releaseRows,
        'patches': patchRows,
        'tracks': trackRows,
        'deviceCount': deviceRows.length,
        'devices': deviceRows.take(50).toList(),
        'recentEvents': eventRows.take(50).toList(),
      });
    } catch (e) {
      return AcWebResponse.json(
        data: {'error': 'Error fetching status: $e'},
        responseCode: AcEnumHttpResponseCode.internalServerError,
      );
    }
  }

  Future<AcWebResponse> _handleRegisterRelease(AcWebRequest request) async {
    try {
      final body = request.post;
      final releaseId = (body['releaseId'] ?? body['release_id']) as String;
      final appId = (body['appId'] ?? body['app_id']) as String;
      final version = (body['version'] as String?) ?? '1.0.0';
      final buildNumber = (body['buildNumber'] ?? body['build_number'] ?? 1) as int;
      final platform = (body['platform'] as String?) ?? 'windows';
      final baseReleaseHash = ((body['baseReleaseHash'] ?? body['base_release_hash']) as String?) ?? '';

      await tblReleases.saveRow(
        row: {
          'release_id': releaseId,
          'app_id': appId,
          'version': version,
          'build_number': buildNumber,
          'platform': platform,
          'base_release_hash': baseReleaseHash,
          'status': 'active',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );

      return AcWebResponse.json(data: {
        'success': true,
        'releaseId': releaseId,
        'appId': appId,
      });
    } catch (e) {
      return AcWebResponse.json(
        data: {'error': 'Error registering release: $e'},
        responseCode: AcEnumHttpResponseCode.internalServerError,
      );
    }
  }

  Future<AcWebResponse> _handleCheck(AcWebRequest request) async {
    try {
      final body = request.post;
      final checkReq = AcPatchCheckRequest.fromJson(body);

      // Record / update device
      await tblDevices.saveRow(
        row: {
          'installation_id': checkReq.installationId,
          'app_id': checkReq.appId,
          'platform': checkReq.platform.value,
          'architecture': checkReq.architecture.value,
          'current_release_id': checkReq.releaseId,
          'current_patch_id': checkReq.currentPatchId ?? '',
          'last_seen': DateTime.now().toUtc().toIso8601String(),
        },
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );

      // Find the track for this app
      final trackDaoResult = await tblTracks.getRows(
        condition: "app_id = :appId AND name = :name",
        parameters: {':appId': checkReq.appId, ':name': checkReq.track.value},
      );
      final trackRows = trackDaoResult.rows;

      if (trackRows.isEmpty) {
        return AcWebResponse.json(data: AcPatchCheckResponse.noUpdate().toJson());
      }

      final trackRow = trackRows.first;
      final currentPatchId = trackRow['current_patch_id'] as String?;
      final rolloutPercentage = (trackRow['rollout_percentage'] as int?) ?? 100;

      if (currentPatchId == null || currentPatchId.isEmpty) {
        return AcWebResponse.json(data: AcPatchCheckResponse.noUpdate().toJson());
      }

      // If client is already on current patch, no update needed
      if (currentPatchId == checkReq.currentPatchId) {
        return AcWebResponse.json(data: AcPatchCheckResponse.noUpdate().toJson());
      }

      // Check rollout percentage assignment
      final isSelected = AcPatchRollout.isDeviceSelected(
        installationId: checkReq.installationId,
        patchId: currentPatchId,
        rolloutPercentage: rolloutPercentage,
      );

      if (!isSelected) {
        return AcWebResponse.json(data: AcPatchCheckResponse.noUpdate().toJson());
      }

      // Fetch patch details
      final patchDaoResult = await tblPatches.getRows(
        condition: "patch_id = :patchId AND status = 'active'",
        parameters: {':patchId': currentPatchId},
      );
      final patchRows = patchDaoResult.rows;

      if (patchRows.isEmpty) {
        return AcWebResponse.json(data: AcPatchCheckResponse.noUpdate().toJson());
      }

      final patchRow = patchRows.first;
      final patchNumber = patchRow['patch_number'] as int;

      // Reject downgrade
      if (patchNumber <= checkReq.currentPatchNumber) {
        return AcWebResponse.json(data: AcPatchCheckResponse.noUpdate().toJson());
      }

      final manifestJson = patchRow['manifest_json'] as String?;
      String signature = '';
      if (manifestJson != null && manifestJson.isNotEmpty) {
        try {
          final manifest = AcPatchManifest.fromJson(jsonDecode(manifestJson) as Map<String, dynamic>);
          signature = manifest.signature;
        } catch (_) {}
      }

      final downloadUrl = '/api/v1/patch/download/$currentPatchId';
      final response = AcPatchCheckResponse(
        available: true,
        patchId: currentPatchId,
        patchNumber: patchNumber,
        releaseId: patchRow['release_id'] as String?,
        downloadUrl: downloadUrl,
        size: patchRow['size_bytes'] as int?,
        hash: patchRow['payload_hash'] as String?,
        signature: signature,
        mandatory: false,
      );

      return AcWebResponse.json(data: response.toJson());
    } catch (e) {
      return AcWebResponse.json(
        data: {'error': 'Error handling patch check: $e'},
        responseCode: AcEnumHttpResponseCode.internalServerError,
      );
    }
  }

  Future<AcWebResponse> _handleReport(AcWebRequest request) async {
    try {
      final body = request.post;
      final report = AcPatchReportRequest.fromJson(body);

      final eventId = 'evt_${DateTime.now().millisecondsSinceEpoch}_${report.installationId.hashCode.abs()}';
      await tblEvents.saveRow(
        row: {
          'event_id': eventId,
          'installation_id': report.installationId,
          'app_id': report.appId,
          'patch_id': report.patchId,
          'release_id': report.releaseId,
          'event_type': report.eventType,
          'error_message': report.errorMessage ?? '',
          'created_at': report.timestamp.toIso8601String(),
        },
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );

      return AcWebResponse.json(data: {'success': true, 'eventId': eventId});
    } catch (e) {
      return AcWebResponse.json(
        data: {'error': 'Error logging report: $e'},
        responseCode: AcEnumHttpResponseCode.internalServerError,
      );
    }
  }

  Future<AcWebResponse> _handlePublish(AcWebRequest request) async {
    try {
      final body = request.post;
      final patchId = body['patchId'] as String;
      final trackName = (body['track'] as String?) ?? 'stable';
      final rolloutPercentage = (body['rolloutPercentage'] as int?) ?? 100;

      // Verify patch exists
      final patchDaoResult = await tblPatches.getRows(
        condition: "patch_id = :patchId",
        parameters: {':patchId': patchId},
      );
      final patchRows = patchDaoResult.rows;
      if (patchRows.isEmpty) {
        return AcWebResponse.json(
          data: {'error': 'Patch not found: $patchId'},
          responseCode: AcEnumHttpResponseCode.notFound,
        );
      }

      final patchRow = patchRows.first;
      final appId = patchRow['app_id'] as String;

      // Mark patch active
      patchRow['status'] = 'active';
      await tblPatches.saveRow(
        row: patchRow,
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );

      // Update or create track
      final trackId = '$appId:$trackName';
      await tblTracks.saveRow(
        row: {
          'track_id': trackId,
          'app_id': appId,
          'name': trackName,
          'current_patch_id': patchId,
          'rollout_percentage': rolloutPercentage,
        },
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );

      return AcWebResponse.json(data: {
        'success': true,
        'patchId': patchId,
        'track': trackName,
        'rolloutPercentage': rolloutPercentage,
      });
    } catch (e) {
      return AcWebResponse.json(
        data: {'error': 'Error publishing patch: $e'},
        responseCode: AcEnumHttpResponseCode.internalServerError,
      );
    }
  }

  Future<AcWebResponse> _handleRollback(AcWebRequest request) async {
    try {
      final body = request.post;
      final appId = body['appId'] as String;
      final trackName = (body['track'] as String?) ?? 'stable';
      final targetPatchId = body['targetPatchId'] as String?;

      final trackId = '$appId:$trackName';
      final trackDaoResult = await tblTracks.getRows(
        condition: "track_id = :trackId",
        parameters: {':trackId': trackId},
      );
      if (trackDaoResult.rows.isNotEmpty) {
        final trackRow = trackDaoResult.rows.first;
        trackRow['current_patch_id'] = targetPatchId ?? '';
        await tblTracks.saveRow(
          row: trackRow,
          executeBeforeEvent: false,
          executeAfterEvent: false,
        );
      }

      return AcWebResponse.json(data: {
        'success': true,
        'appId': appId,
        'track': trackName,
        'currentPatchId': targetPatchId,
      });
    } catch (e) {
      return AcWebResponse.json(
        data: {'error': 'Error rolling back patch: $e'},
        responseCode: AcEnumHttpResponseCode.internalServerError,
      );
    }
  }

  Future<AcWebResponse> _handleUpload(AcWebRequest request) async {
    try {
      List<int>? bytes;
      if (request.files.isNotEmpty) {
        final file = request.files.values.first;
        if (file.contentStream != null) {
          final chunks = await file.contentStream!.toList();
          bytes = chunks.expand((chunk) => chunk).toList();
        } else if (file.contentText != null) {
          final textChunks = await file.contentText!.toList();
          bytes = utf8.encode(textChunks.join());
        }
      } else if (request.post['bytesBase64'] != null) {
        bytes = base64Decode(request.post['bytesBase64'] as String);
      }

      if (bytes == null || bytes.isEmpty) {
        return AcWebResponse.json(
          data: {'error': 'No patch payload received'},
          responseCode: AcEnumHttpResponseCode.badRequest,
        );
      }

      // Unpack and validate archive
      final package = AcPatchArchive.unpack(bytes);
      final manifest = package.manifest;

      // Store binary in object storage
      final storageKey = 'app/${manifest.appId}/release/${manifest.releaseId}/patch/${manifest.patchId}.acp1';
      await storage.put(storageKey: storageKey, bytes: bytes);

      // Record in database
      await tblPatches.saveRow(
        row: {
          'patch_id': manifest.patchId,
          'release_id': manifest.releaseId,
          'app_id': manifest.appId,
          'patch_number': manifest.patchNumber,
          'platform': manifest.platform.value,
          'architecture': manifest.architecture.value,
          'patch_type': manifest.patchType.value,
          'payload_hash': manifest.payloadHash,
          'storage_key': storageKey,
          'size_bytes': bytes.length,
          'status': 'uploaded',
          'manifest_json': jsonEncode(manifest.toJson()),
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
        executeBeforeEvent: false,
        executeAfterEvent: false,
      );

      return AcWebResponse.json(data: {
        'success': true,
        'patchId': manifest.patchId,
        'storageKey': storageKey,
        'sizeBytes': bytes.length,
      });
    } catch (e) {
      return AcWebResponse.json(
        data: {'error': 'Error uploading patch: $e'},
        responseCode: AcEnumHttpResponseCode.internalServerError,
      );
    }
  }

  Future<AcWebResponse> _handleDownload(AcWebRequest request) async {
    try {
      final patchId = request.pathParameters['patchId'];
      if (patchId == null || patchId.isEmpty) {
        return AcWebResponse.notFound();
      }

      final patchDaoResult = await tblPatches.getRows(
        condition: "patch_id = :patchId",
        parameters: {':patchId': patchId},
      );
      if (patchDaoResult.rows.isEmpty) {
        return AcWebResponse.notFound();
      }

      final storageKey = patchDaoResult.rows.first['storage_key'] as String;
      final bytes = await storage.get(storageKey: storageKey);

      final response = AcWebResponse.raw(
        content: bytes,
        headers: {
          'Content-Type': 'application/octet-stream',
          'Content-Disposition': 'attachment; filename="$patchId.acp1"',
        },
      );
      response.responseCode = AcEnumHttpResponseCode.ok;
      return response;
    } catch (e, st) {
      print('Download error: $e\n$st');
      return AcWebResponse.notFound();
    }
  }
}
