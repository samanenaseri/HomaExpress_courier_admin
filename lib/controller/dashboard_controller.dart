import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/dashboard_model.dart';

class DashboardController extends GetxController {
  var isLoading = false.obs;
  var dashboardData = DashboardModel(
    totalOrders: 0,
    completedOrders: 0,
    pendingOrders: 0,
    activeCouriers: 0,
    dailyStats: [],
  ).obs;

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      if (token.isEmpty) {
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://api.homaexpressco.com/api/v1/portal/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        dashboardData.value = DashboardModel.fromJson(data);
      } else if (response.statusCode == 401) {
        Get.offAllNamed('/login');
      } else {
        Get.snackbar('Error', 'Failed to fetch dashboard data');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while fetching dashboard data');
    } finally {
      isLoading.value = false;
    }
  }
} 