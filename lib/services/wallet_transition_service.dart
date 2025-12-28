import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WalletTransitionService {
  final String baseUrl;

  WalletTransitionService({
    this.baseUrl = 'https://api.homaexpressco.com/api/v1/portal',
  });

  Future<bool> createWalletTransition({
    required int customerId,
    required String numberTransition,
    required DateTime paymentDate,
    required String price,
    required int orderId,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/walletTransition');

    final dateStr = DateFormat('yyyy-MM-dd').format(paymentDate);

    final body = {
      "currency_id": 5,
      "customer_id": customerId,
      "number_transition": numberTransition,
      "payment_date": dateStr,
      "payment_method_id": 2,
      "price": int.parse(price),
      "type": "add",
      "order_id": orderId,
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    print('================ WALLET TRANSITION ================');
    print('[WalletTransition] URL: $url');
    print('[WalletTransition] token? ${token != null && token.isNotEmpty}');
    print('[WalletTransition] BODY: ${jsonEncode(body)}');
    print('===================================================');

    final resp = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    print('================ WALLET RESPONSE ==================');
    print('[WalletTransition] STATUS: ${resp.statusCode}');
    print('[WalletTransition] RESPONSE BODY: ${resp.body}');
    print('===================================================');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      return false;
    }

    try {
      final data = jsonDecode(resp.body);
      if (data is Map && data['success'] == true) {
        return true;
      }
      return false;
    } catch (_) {
      return true;
    }
  }
  Future<Map<String, dynamic>?> checkPaymentStatus({
    required int customerId,
    required int orderId,
    String? token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/wallet-transitions/check'
          '?customer_id=$customerId'
          '&order_id=$orderId',
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };

    print('=========== CHECK WALLET STATUS ===========');
    print('[WalletCheck] URL: $url');
    print('[WalletCheck] HEADERS: $headers');
    print('==========================================');

    final resp = await http.get(url, headers: headers);

    print('[WalletCheck] STATUS: ${resp.statusCode}');
    print('[WalletCheck] BODY: ${resp.body}');

    if (resp.statusCode != 200) return null;

    try {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }


}
