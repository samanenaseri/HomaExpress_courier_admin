import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttachmentService {
  final String baseUrl;

  AttachmentService({
    this.baseUrl = 'https://api.homaexpressco.com/api/v1/portal',
  });
  Future<bool> uploadOrderAttachment({
    required File file,
    required int orderId,
    String? token,
  }) async {
    if (!await file.exists()) {
      print('[ATTACH] file does not exist: ${file.path}');
      return false;
    }
    final len = await file.length();
    if (len <= 0) {
      print('[ATTACH] file size is 0: ${file.path}');
      return false;
    }

    final url = Uri.parse('$baseUrl/attachment');
    final request = http.MultipartRequest('POST', url);

    request.files.add(await http.MultipartFile.fromPath('file[]', file.path));

    request.fields['attachmentable_id'] = orderId.toString();
    request.fields['attachmentable_type'] = 'order';

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    //print('[ATTACH] status=${response.statusCode}');
    if (response.statusCode < 200 || response.statusCode >= 300) {
     // print('[ATTACH] body=${response.body}');
    }

    return response.statusCode >= 200 && response.statusCode < 300;
  }


}
