import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      if (token.isEmpty) {
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.post(
        Uri.parse('http://api.homaexpressco.com/api/v1/portal/logout'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('token');
        Get.offAllNamed('/login');
      } else if (response.statusCode == 401) {
        await prefs.remove('token');
        Get.offAllNamed('/login');
      } else {
        Get.snackbar('Error', 'Failed to logout');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while logging out');
    }
  }
} 