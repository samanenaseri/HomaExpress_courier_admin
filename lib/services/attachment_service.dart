import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttachmentService {
  final String baseUrl;

  AttachmentService({
    this.baseUrl = 'https://api.homaexpressco.com/api/v1/portal',
  });

  /// آپلود عکسِ گرفته شده از دوربین برای یک سفارش (order)
  Future<bool> uploadOrderAttachment({
    required File file,
    required int orderId,      // همان attachmentable_id
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/attachment');

    final request = http.MultipartRequest('POST', url);

    // فایل به صورت file[] (مطابق API)
    request.files.add(
      await http.MultipartFile.fromPath('file[]', file.path),
    );

    // فیلدهای ثابت
    request.fields['attachmentable_id'] = orderId.toString();
    request.fields['attachmentable_type'] = 'order';  // 🔒 ثابت

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    // برای دیباگ اگر خواستی:
    // print('UPLOAD STATUS: ${response.statusCode}');
    // print('UPLOAD BODY: ${response.body}');

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
