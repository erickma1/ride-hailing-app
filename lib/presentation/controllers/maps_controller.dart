import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../data/models/location_model.dart';

class MapsController extends GetxController {
  final pickupLocation = Rx<LocationModel?>(null);
  final dropoffLocation = Rx<LocationModel?>(null);
  final currentPosition = Rx<Position?>(null);
  final isLoading = false.obs;
  final distance = 0.0.obs;
  final duration = 0.obs;
  final estimatedFare = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Location permission denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      currentPosition.value = position;

      // Get address from coordinates
      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      pickupLocation.value = LocationModel(
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error getting location: $e');
      Get.snackbar('Error', 'Failed to get location');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}';
      }
      return 'Unknown location';
    } catch (e) {
      print('Error getting address: $e');
      return 'Unknown location';
    }
  }

  void setPickupLocation(LocationModel location) {
    pickupLocation.value = location;
    calculateFare();
  }

  void setDropoffLocation(LocationModel location) {
    dropoffLocation.value = location;
    calculateFare();
  }

  void calculateFare({double pricePerKm = 0.50, double baseFare = 2.00}) {
    if (pickupLocation.value != null && dropoffLocation.value != null) {
      final dist = Geolocator.distanceBetween(
        pickupLocation.value!.latitude,
        pickupLocation.value!.longitude,
        dropoffLocation.value!.latitude,
        dropoffLocation.value!.longitude,
      );

      distance.value = dist / 1000; // Convert to km
      // Estimate: 10 km/h average speed in Ghana traffic
      duration.value = (distance.value * 6).toInt(); // minutes

      estimatedFare.value = baseFare + (distance.value * pricePerKm);
    }
  }

  void swapLocations() {
    final temp = pickupLocation.value;
    pickupLocation.value = dropoffLocation.value;
    dropoffLocation.value = temp;
    calculateFare();
  }

  void reset() {
    dropoffLocation.value = null;
    distance.value = 0.0;
    duration.value = 0;
    estimatedFare.value = 0.0;
  }
}
