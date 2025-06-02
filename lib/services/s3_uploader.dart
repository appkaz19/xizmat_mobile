import 'dart:convert';
import 'dart:io';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class S3Uploader {
  static const accessKey = 'YCB2BiZON-JWPB9olDzDJAAlm';
  static const secretKey = 'YCMdJCFmS09DAjOWwc0shf8MyBKEIAcmbN47YnUO';
  static const bucket = 'kyzmet';
  static const region = 'kz1';
  static const endpoint = 'https://storage.yandexcloud.kz';

  static Future<String?> uploadFile(File file, String folder) async {
    final content = await file.readAsBytes();
    final filename =
        '$folder/${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
    final hashedPayload = sha256.convert(content).toString();
    final now = DateTime.now().toUtc();
    final isoDate = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(now);
    final shortDate = DateFormat('yyyyMMdd').format(now);
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

    final canonicalRequest = '''
PUT
/$bucket/$filename

host:storage.yandexcloud.kz
x-amz-content-sha256:$hashedPayload
x-amz-date:$isoDate

host;x-amz-content-sha256;x-amz-date
$hashedPayload''';

    final scope = '$shortDate/$region/s3/aws4_request';
    final stringToSign = '''
AWS4-HMAC-SHA256
$isoDate
$scope
${sha256.convert(utf8.encode(canonicalRequest))}''';

    List<int> _sign(List<int> key, String msg) =>
        Hmac(sha256, key).convert(utf8.encode(msg)).bytes;

    final kDate = _sign(utf8.encode('AWS4$secretKey'), shortDate);
    final kRegion = _sign(kDate, region);
    final kService = _sign(kRegion, 's3');
    final kSigning = _sign(kService, 'aws4_request');
    final signature = hex.encode(
        Hmac(sha256, kSigning).convert(utf8.encode(stringToSign)).bytes);

    final authHeader =
        'AWS4-HMAC-SHA256 Credential=$accessKey/$scope, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=$signature';

    try {
      final dio = Dio();
      final url = '$endpoint/$bucket/$filename';
      final res = await dio.put(
        url,
        data: content,
        options: Options(
          validateStatus: (_) => true,
          headers: {
            'x-amz-date': isoDate,
            'x-amz-content-sha256': hashedPayload,
            'Authorization': authHeader,
            'Content-Type': mimeType,
          },
        ),
      );
      return res.statusCode == 200 ? url : null;
    } catch (e, s) {
      print('🔥 Ошибка Dio PUT запроса в S3: $e');
      print(s);
    }
  }

  static Future<List<String>> uploadFiles(List<File> files, String folder) async {
    List<String> urls = [];
    for (final file in files) {
      final url = await uploadFile(file, folder);
      if (url != null) urls.add(url);
    }
    return urls;
  }
}
