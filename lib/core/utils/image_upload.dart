// ============================================================
// Captured-image upload helper
// ============================================================
// Every photo the app uploads (driver licence, odometer proof, ...) goes
// through here:
//   * re-encoded to JPEG with the native OS decoder — iPhones capture HEIC,
//     which is huge as PNG and not viewable on Android/web previews,
//   * named ".jpg" so the multipart part advertises image/jpeg
//     (package:http would otherwise send application/octet-stream, which the
//     upload endpoint rejects),
//   * uploaded to /api/upload; the public "/uploads/..." URL is returned.
//
// Never store a local device path on the server: it is meaningless there and
// the admin portal cannot display it (that is what broke the odometer photos).
// ============================================================

import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../network/api_client.dart';

/// True when [value] is a file the server can actually serve, i.e. a real
/// upload ("/uploads/xyz.jpg") rather than a device-only path
/// ("/data/user/0/.../image_picker.jpg").
bool isUploadedFileUrl(String? value) =>
    value != null &&
    (value.startsWith('/uploads/') ||
        value.startsWith('http://') ||
        value.startsWith('https://'));

/// Re-encodes [sourcePath] as JPEG, uploads it and returns its public URL.
/// Throws (ApiException / platform errors) when the upload fails so callers can
/// show an error instead of silently keeping a local path.
Future<String> uploadCapturedImage(String sourcePath) async {
  final normalized = await _normalizeToJpeg(sourcePath);
  return ApiClient.instance.uploadFile(normalized);
}

/// Re-encodes [sourcePath] as a JPEG and returns its path, so uploads are small
/// and universally supported (iPhone HEIC -> JPEG). Falls back to the original
/// file if compression fails for any reason so a photo is never lost.
Future<String> _normalizeToJpeg(String sourcePath) async {
  // Strip the original extension so the target really ends in ".jpg"
  // (e.g. /tmp/IMG_1234.HEIC -> /tmp/IMG_1234_upload.jpg)
  final base = sourcePath.replaceFirst(RegExp(r'\.[A-Za-z0-9]+$'), '');
  final targetPath = '${base}_upload.jpg';
  try {
    final result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      format: CompressFormat.jpeg,
      quality: 80,
    );
    final path = result?.path;
    return (path != null && path.isNotEmpty) ? path : sourcePath;
  } catch (_) {
    return sourcePath;
  }
}
