import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/pickup_model.dart';
import '../services/attachment_service.dart';

class PickupController extends GetxController {
  final RxList<PickupOrder> pickups = <PickupOrder>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxBool hasMore = true.obs;
  final int perPage = 10;

  // برای آپلود ضمیمه (عکس)
  late final AttachmentService _attachmentService;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _attachmentService = AttachmentService();
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
        Uri.parse(
          'http://api.homaexpressco.com/api/v1/portal/pickup/listOrderPickup?page=${currentPage.value}',
        ),
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
                    print(
                      '- Country: ${pickup.senderAddress!.city!.country!.enName}',
                    );
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
        } else {
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
        Uri.parse(
          'http://api.homaexpressco.com/api/v1/portal/pickup/$pickupId/complete',
        ),
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

  /// 📷 گرفتن عکس از دوربین و آپلود به‌عنوان attachment برای یک سفارش
  ///
  /// [orderId] = همان attachmentable_id که باید برای API بفرستیم
  Future<void> uploadAttachmentForOrder(int orderId) async {
    try {
      // ۱) گرفتن عکس از دوربین
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // کمی فشرده‌تر برای کاهش حجم
        maxWidth: 1600,
      );

      if (picked == null) {
        // کاربر دوربین را کنسل کرده
        print('[ATTACH] user cancelled camera');
        return;
      }

      final file = File(picked.path);

      // ۲) گرفتن توکن
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      // ۳) درخواست آپلود
      Get.snackbar('در حال آپلود', 'لطفاً صبر کنید...');

      final ok = await _attachmentService.uploadOrderAttachment(
        file: file,
        orderId: orderId,
        token: token,
      );


      if (ok) {
        Get.snackbar(
          'موفق',
          'فایل با موفقیت آپلود شد.',
          snackPosition: SnackPosition.BOTTOM,
        );
        // اگر لازم است بعد از آپلود، لیست pickups را رفرش کنی:
        // await fetchPickups(refresh: true);
      } else {
        Get.snackbar(
          'خطا',
          'آپلود فایل ناموفق بود. لطفاً دوباره تلاش کنید.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, st) {
      print('[ATTACH] upload error: $e\n$st');
      Get.snackbar(
        'خطا',
        'خطا هنگام آپلود فایل: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
