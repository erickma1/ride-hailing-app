import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../presentation/controllers/maps_controller.dart';
import '../../../presentation/controllers/request_ride_controller.dart';
import '../../../data/models/location_model.dart';
import '../../../data/models/ride_type_model.dart';
import './location_search_screen.dart';

class RequestRideScreen extends StatelessWidget {
  final mapsController = Get.find<MapsController>();
  final rideController = Get.find<RequestRideController>();

  RequestRideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Ride'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Locations Section
            _buildLocationCard(
              title: 'Pickup',
              onTap: () async {
                final result = await Get.to(() =>
                    LocationSearchScreen(title: 'Select Pickup Location'));
                if (result != null) {
                  mapsController.setPickupLocation(result);
                }
              },
              location: mapsController.pickupLocation,
              icon: Icons.location_on,
            ),
            SizedBox(height: 12),
            // Swap button
            Center(
              child: GestureDetector(
                onTap: mapsController.swapLocations,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF00D4FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.swap_vert,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            _buildLocationCard(
              title: 'Dropoff',
              onTap: () async {
                final result = await Get.to(() =>
                    LocationSearchScreen(title: 'Select Dropoff Location'));
                if (result != null) {
                  mapsController.setDropoffLocation(result);
                }
              },
              location: mapsController.dropoffLocation,
              icon: Icons.location_off_outlined,
            ),
            SizedBox(height: 24),

            // Ride Type Selection
            Text(
              'Select Ride Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Obx(() => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: rideTypes.map((rideType) {
                final isSelected = rideController.selectedRideType.value?.id == rideType.id;
                return GestureDetector(
                  onTap: () {
                    rideController.selectRideType(rideType);
                    mapsController.calculateFare(
                      pricePerKm: rideType.pricePerKm,
                      baseFare: rideType.baseFare,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Color(0xFF00D4FF) : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(rideType.icon, style: TextStyle(fontSize: 32)),
                        SizedBox(height: 8),
                        Text(
                          rideType.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Color(0xFF00D4FF) : Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'GHS ${rideType.baseFare.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
            SizedBox(height: 24),

            // Fare Estimation
            Obx(() => mapsController.pickupLocation.value != null &&
                    mapsController.dropoffLocation.value != null
                ? _buildFareEstimate()
                : Container()),
            SizedBox(height: 24),

            // Special Instructions
            Text(
              'Special Instructions (Optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            TextField(
              onChanged: rideController.setSpecialInstructions,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'E.g., Wait 5 minutes, Call before arrival...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Promo Code
            Text(
              'Promo Code (Optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            TextField(
              onChanged: rideController.setPromoCode,
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 32),

            // Request Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: mapsController.pickupLocation.value != null &&
                        mapsController.dropoffLocation.value != null
                    ? rideController.requestRide
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00D4FF),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: rideController.isLoading.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Request Ride',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required VoidCallback onTap,
    required Rx<LocationModel?> location,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Obx(() => Row(
          children: [
            Icon(icon, color: Color(0xFF00D4FF)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    location.value?.address ?? 'Select location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        )),
      ),
    );
  }

  Widget _buildFareEstimate() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${mapsController.distance.value.toStringAsFixed(1)} km',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Time',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${mapsController.duration.value} mins',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Divider(color: Colors.white30, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Fare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'GHS ${mapsController.estimatedFare.value.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }
}
