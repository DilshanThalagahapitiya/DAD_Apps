// ============================================================
// Upload content-type tests — driver license photos
// ============================================================
// Regression guard for the "Camera error: Invalid file type" bug:
// package:http's MultipartFile.fromPath() does NOT sniff the file type and
// sends application/octet-stream by default, which the upload endpoint rejected
// (nothing was saved). Every image upload must announce a real image type.
// ============================================================

import 'dart:convert';
import 'dart:io';

import 'package:dad_app/core/network/api_client.dart';
import 'package:dad_app/core/utils/image_upload.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('image content type is derived from the file extension', () {
    expect(ApiClient.mediaTypeFor('/tmp/a.jpg').mimeType, 'image/jpeg');
    expect(ApiClient.mediaTypeFor('/tmp/a.JPEG').mimeType, 'image/jpeg');
    expect(ApiClient.mediaTypeFor('/tmp/a.png').mimeType, 'image/png');
    expect(ApiClient.mediaTypeFor('/tmp/a.webp').mimeType, 'image/webp');
    expect(ApiClient.mediaTypeFor('/tmp/IMG_1234.HEIC').mimeType, 'image/heic');
    expect(ApiClient.mediaTypeFor('/tmp/a.heif').mimeType, 'image/heif');
  });

  test('images never fall back to application/octet-stream (the reported bug)', () {
    for (final path in ['/tmp/x.jpg', '/tmp/x.png', '/tmp/x.webp', '/tmp/x.heic']) {
      expect(ApiClient.mediaTypeFor(path).mimeType, startsWith('image/'), reason: path);
    }
  });

  test('unknown extensions are not advertised as images', () {
    expect(ApiClient.mediaTypeFor('/tmp/notes.txt').mimeType, 'application/octet-stream');
    expect(ApiClient.mediaTypeFor('/tmp/noextension').mimeType, 'application/octet-stream');
  });

  test('only real uploads count as images (odo photos bug)', () {
    // What the app stores after a successful upload -> the portal can show it
    expect(isUploadedFileUrl('/uploads/1234-abcd.jpg'), isTrue);
    expect(isUploadedFileUrl('https://example.test/uploads/x.png'), isTrue);
    // What older builds wrongly stored: a path that only exists on the phone
    expect(isUploadedFileUrl('/data/user/0/com.dad/cache/image_picker123.jpg'), isFalse);
    expect(isUploadedFileUrl('/var/mobile/Containers/Data/Application/x/tmp/IMG_1.jpg'), isFalse);
    expect(isUploadedFileUrl(null), isFalse);
    expect(isUploadedFileUrl(''), isFalse);
  });

  test('the multipart part really carries the image content type', () async {
    final dir = Directory.systemTemp.createTempSync('dad_upload_test');
    final licensePhoto = File('${dir.path}/license.jpg')
      ..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

    final request = http.MultipartRequest('POST', Uri.parse('http://example.test/api/upload'));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        licensePhoto.path,
        contentType: ApiClient.mediaTypeFor(licensePhoto.path),
      ),
    );

    // Decode as latin1 — the body contains raw binary image bytes, which are
    // not valid UTF-8 (so bytesToString() would throw). package:http writes the
    // part headers lowercase, hence the toLowerCase() comparison.
    // (finalize() returns a ByteStream synchronously — hence no inner await.)
    final body = latin1.decode(await request.finalize().toBytes()).toLowerCase();
    expect(body, contains('content-type: image/jpeg'));
    expect(body, isNot(contains('application/octet-stream')));

    dir.deleteSync(recursive: true);
  });
}
