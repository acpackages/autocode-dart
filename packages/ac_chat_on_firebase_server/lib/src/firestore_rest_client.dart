import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import 'firestore_value_converter.dart';

/// Lightweight Firestore REST client using a Google service account.
///
/// Wraps the Firestore v1 REST API for server-side use (no Flutter SDK needed).
/// Authentication is handled automatically via [ServiceAccountCredentials].
class FirestoreRestClient {
  static const String _firestoreScope =
      'https://www.googleapis.com/auth/datastore';
  static const String _baseUrl =
      'https://firestore.googleapis.com/v1';

  final String projectId;
  final String database;

  final ServiceAccountCredentials _credentials;
  AutoRefreshingAuthClient? _httpClient;

  FirestoreRestClient({
    required this.projectId,
    required Map<String, dynamic> serviceAccountJson,
    this.database = '(default)',
  }) : _credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

  /// Root path for all documents in this database.
  String get _dbPath =>
      'projects/$projectId/databases/$database/documents';

  /// Full API base for documents.
  String get _docBase => '$_baseUrl/$_dbPath';

  Future<http.Client> _client() async {
    _httpClient ??= await clientViaServiceAccount(
      _credentials,
      [_firestoreScope],
    );
    return _httpClient!;
  }

  /// Writes a single document at [path] (relative to database root, e.g.
  /// `users/uid/updates/updateId`). Overwrites the entire document.
  Future<void> setDocument(
    String path,
    Map<String, dynamic> fields,
  ) async {
    final client = await _client();
    final uri = Uri.parse('$_docBase/$path');
    final body = jsonEncode({
      'fields': FirestoreValueConverter.encodeFields(fields),
    });

    final response = await client.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FirestoreRestException(
        'setDocument failed for $path: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Executes a batch of write operations atomically.
  ///
  /// [writes] is a list of `batchWrite` write objects, each being:
  ///   `{ 'update': { 'name': fullDocPath, 'fields': encodedFields } }`
  /// or `{ 'delete': fullDocPath }`.
  Future<void> batchWrite(List<Map<String, dynamic>> writes) async {
    if (writes.isEmpty) return;
    final client = await _client();
    final uri = Uri.parse('$_baseUrl/$_dbPath:batchWrite');
    final body = jsonEncode({'writes': writes});

    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FirestoreRestException(
        'batchWrite failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Deletes the document at [path].
  Future<void> deleteDocument(String path) async {
    final client = await _client();
    final uri = Uri.parse('$_docBase/$path');
    final response = await client.delete(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FirestoreRestException(
        'deleteDocument failed for $path: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Fetches a document at [path] and returns its fields as a plain Dart map,
  /// or null if the document does not exist.
  Future<Map<String, dynamic>?> getDocument(String path) async {
    final client = await _client();
    final uri = Uri.parse('$_docBase/$path');
    final response = await client.get(uri);

    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FirestoreRestException(
        'getDocument failed for $path: ${response.statusCode} ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final rawFields = json['fields'] as Map<String, dynamic>? ?? {};
    return FirestoreValueConverter.decodeFields(rawFields);
  }

  /// Builds a fully-qualified Firestore document name for use in batch writes.
  String docName(String relativePath) => '$_dbPath/$relativePath';

  /// Builds a batch-write `update` entry from a [relativePath] and [fields].
  Map<String, dynamic> updateWrite(
    String relativePath,
    Map<String, dynamic> fields,
  ) {
    return {
      'update': {
        'name': docName(relativePath),
        'fields': FirestoreValueConverter.encodeFields(fields),
      },
    };
  }

  /// Builds a batch-write `delete` entry from a [relativePath].
  Map<String, dynamic> deleteWrite(String relativePath) {
    return {'delete': docName(relativePath)};
  }

  /// Releases the underlying HTTP client.
  Future<void> close() async {
    _httpClient?.close();
    _httpClient = null;
  }
}

/// Exception thrown when a Firestore REST call fails.
class FirestoreRestException implements Exception {
  final String message;
  const FirestoreRestException(this.message);

  @override
  String toString() => 'FirestoreRestException: $message';
}