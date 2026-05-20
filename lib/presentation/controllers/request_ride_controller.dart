import 'package:get/get.dart';
import '../../data/models/ride_type_model.dart';

class RequestRideController extends GetxController {
  final selectedRideType = Rx<RideTypeModel?>(null);
  final specialInstructions = ''.obs;
  final promoCode = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedRideType.value = rideTypes[0]; // Default to Economy
  }

  void selectRideType(RideTypeModel rideType) {
    selectedRideType.value = rideType;
  }

  void setSpecialInstructions(String instructions) {
    specialInstructions.value = instructions;
  }

  void setPromoCode(String code) {
    promoCode.value = code;
  }

  Future<void> requestRide() async {
    try {
      isLoading.value = true;
      // TODO: Send ride request to backend
      Get.snackbar('Success', 'Ride requested!');
      await Future.delayed(Duration(seconds: 1));
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to request ride');
    } finally {
      isLoading.value = false;
    }
  }
}
