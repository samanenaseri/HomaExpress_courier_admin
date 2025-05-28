import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/pickup_model.dart';

class PickupController extends GetxController {
  final RxList<PickupOrder> pickups = <PickupOrder>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxBool hasMore = true.obs;
  final int perPage = 10;

  @override
  void onInit() {
    super.onInit();
    fetchPickups();
  }

  Future<void> fetchPickups({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      pickups.clear();
      hasMore.value = true;
    }

    if (!hasMore.value || isLoading.value) return;

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://api.homaexpressco.com/api/v1/portal/pickup/listOrderPickup?page=${currentPage.value}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('\n=== API Response ===');
        print('Full response: $responseData');
        
        if (responseData['data'] != null) {
          final data = responseData['data'];
          print('\n=== Pagination Data ===');
          print('Current page: ${data['current_page']}');
          print('Last page: ${data['last_page']}');
          print('Total: ${data['total']}');
          
          final List<dynamic> items = data['data'] ?? [];
          print('\n=== Items Data ===');
          print('Number of items: ${items.length}');
          
          if (refresh) {
            pickups.clear();
          }

          try {
            final List<PickupOrder> newPickups = items.map((item) {
              print('\n=== Processing Item for PickupOrder ===');
              print('Raw item data: $item');
              
              // Log sender address data specifically
              if (item['sender_address'] != null) {
                print('\nSender Address Raw Data:');
                print('Type: ${item['sender_address'].runtimeType}');
                print('Content: ${item['sender_address']}');
                print('Address field: ${item['sender_address']['address']}');
                print('City field: ${item['sender_address']['city']}');
              } else {
                print('No sender_address data found in item');
              }
              
              try {
                final pickup = PickupOrder.fromJson(item);
                print('\nSuccessfully created PickupOrder:');
                print('Order Number: ${pickup.orderNumber}');
                print('Sender Address Object: ${pickup.senderAddress}');
                if (pickup.senderAddress != null) {
                  print('Sender Address Details:');
                  print('- Address: ${pickup.senderAddress!.address}');
                  print('- Name: ${pickup.senderAddress!.name}');
                  print('- Mobile: ${pickup.senderAddress!.mobile}');
                  print('- City: ${pickup.senderAddress!.city?.enName}');
                  if (pickup.senderAddress!.city?.country != null) {
                    print('- Country: ${pickup.senderAddress!.city!.country!.enName}');
                  }
                }
                return pickup;
              } catch (e) {
                print('Error creating PickupOrder: $e');
                rethrow;
              }
            }).toList();

            print('\n=== Adding Pickups to List ===');
            print('Number of pickups to add: ${newPickups.length}');
            
            if (newPickups.isNotEmpty) {
              pickups.addAll(newPickups);
              print('Successfully added ${newPickups.length} pickups');
              print('Total pickups in list: ${pickups.length}');
            } else {
              print('No pickups to add');
            }
          } catch (e) {
            print('Error processing pickups: $e');
            Get.snackbar(
              'Error',
              'Failed to process pickup data: $e',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
          
          currentPage.value = data['current_page'] ?? 1;
          lastPage.value = data['last_page'] ?? 1;
          totalItems.value = data['total'] ?? 0;
          hasMore.value = currentPage.value < lastPage.value;
        }
        else {
          Get.snackbar(
            'Error',
            'Invalid response format',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (response.statusCode == 401) {
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch pickups: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      Get.snackbar(
        'Error',
        'An error occurred while fetching pickups: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    if (hasMore.value && !isLoading.value) {
      currentPage.value++;
      fetchPickups();
    }
  }

  Future<void> completePickup(int pickupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.post(
        Uri.parse('http://api.homaexpressco.com/api/v1/portal/pickup/$pickupId/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final index = pickups.indexWhere((p) => p.id == pickupId);
        if (index != -1) {
          final updatedPickup = pickups[index];
          pickups[index] = updatedPickup;
        }
        Get.snackbar(
          'Success',
          'Pickup completed successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to complete pickup: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Complete pickup error: $e');
      Get.snackbar(
        'Error',
        'An error occurred while completing pickup: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
