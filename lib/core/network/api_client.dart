// ============================================================
// API Client - Central HTTP client
// ============================================================
// Handles all HTTP requests to the SafeRide Backend REST API.
// Automatically attaches JWT token to authenticated requests.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/app_constants.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] as T?,
    );
  }
}

class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

  /// Underlying HTTP client. Replaceable so tests can stub the network
  /// (see test/theme_provider_test.dart) — never change it in the app.
  http.Client _client = http.Client();
  void setHttpClient(http.Client client) => _client = client;
  http.Client get httpClient => _client;

  String? _token;
  // Tenant-wise theming: identifies this app build so the backend returns its
  // own brand colors. Defaults to the build-time TENANT_ID (AppConstants).
  String? _tenantId =
      AppConstants.tenantId.isEmpty ? null : AppConstants.tenantId;

  void setToken(String? token) => _token = token;
  String? get token => _token;

  /// Override the tenant at runtime (e.g. after a tenant-specific login).
  /// Pass null/empty to fall back to the build-time [AppConstants.tenantId].
  void setTenantId(String? tenantId) {
    _tenantId = (tenantId == null || tenantId.isEmpty)
        ? (AppConstants.tenantId.isEmpty ? null : AppConstants.tenantId)
        : tenantId;
  }

  String? get tenantId => _tenantId;

  Map<String, String> _headers({bool auth = true}) {
    final headers = {'Content-Type': 'application/json'};
    // Stops ngrok's free tier from answering with its HTML warning page
    // (which would break JSON decoding and silently drop the brand colors).
    headers['ngrok-skip-browser-warning'] = 'true';
    if (_tenantId != null && _tenantId!.isNotEmpty) {
      headers['X-Tenant-Id'] = _tenantId!;
    }
    if (auth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ---- GET ----
  Future<dynamic> get(String path, {bool auth = true}) async {
    final res = await _client.get(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: _headers(auth: auth),
    );
    return _handleResponse(res);
  }

  // ---- POST ----
  Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final res = await _client.post(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  // ---- PATCH ----
  Future<dynamic> patch(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final res = await _client.patch(
      Uri.parse('${AppConstants.baseUrl}$path'),
      headers: _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  // ---- UPLOAD (multipart file upload, e.g. driver license photos) ----
  // Returns the public URL of the uploaded file (e.g. "/uploads/abc123.jpg").
  Future<String> uploadFile(String filePath, {bool auth = true}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/api/upload');
    final request = http.MultipartRequest('POST', uri);
    // Multipart requests set their own Content-Type (multipart/form-data;
    // boundary=...), so only copy the auth/tenant headers, not the JSON one.
    final headers = _headers(auth: auth)..remove('Content-Type');
    request.headers.addAll(headers);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        // CRITICAL: MultipartFile.fromPath() does NOT detect the file type — it
        // always sends "application/octet-stream", which the upload endpoint
        // rejects with "Invalid file type" (this broke driver license photos).
        // Announce the real image type, derived from the file extension.
        contentType: mediaTypeFor(filePath),
      ),
    );

    final streamed = await _client.send(request);
    final res = await http.Response.fromStream(streamed);
    final decoded = _handleResponse(res);
    return decoded['data']['url'] as String;
  }

  /// Content type for an uploaded file, based on its extension.
  /// Defaults to application/octet-stream for anything that is not a known
  /// image type (the server then decides whether to accept it).
  static MediaType mediaTypeFor(String filePath) {
    final dot = filePath.lastIndexOf('.');
    final ext = dot == -1 ? '' : filePath.substring(dot + 1).toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'heic':
        return MediaType('image', 'heic');
      case 'heif':
        return MediaType('image', 'heif');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  // ---- Response handler ----
  dynamic _handleResponse(http.Response res) {
    final decoded = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    } else {
      throw ApiException(decoded['message'] ?? 'Request failed');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}