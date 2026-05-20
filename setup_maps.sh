#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Creating Maps & Ride Request System...${NC}\n"

# Create Location Model
cat > lib/data/models/location_model.dart << 'EOF'
class LocationModel {
  final String address;
  final double latitude;
  final double longitude;
  final String? placeName;
  final String? placeType;

  LocationModel({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.placeType,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeName': placeName,
      'placeType': placeType,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      address: map['address'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      placeName: map['placeName'],
      placeType: map['placeType'],
    );
  }

  @override
  String toString() => address;
}
EOF
echo -e "${GREEN}✓ Created location_model.dart${NC}"

# Create Ride Type Model
cat > lib/data/models/ride_type_model.dart << 'EOF'
class RideTypeModel {
  final String id;
  final String name;
  final String icon;
  final double pricePerKm;
  final double baseFare;
  final int capacity;
  final String description;
  final String color;

  RideTypeModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.pricePerKm,
    required this.baseFare,
    required this.capacity,
    required this.description,
    required this.color,
  });
}

// Predefined ride types
final rideTypes = [
  RideTypeModel(
    id: 'economy',
    name: 'Economy',
    icon: '🚗',
    pricePerKm: 0.50,
    baseFare: 2.00,
    capacity: 4,
    description: 'Budget-friendly option',
    color: '0xFF00D4FF',
  ),
  RideTypeModel(
    id: 'comfort',
    name: 'Comfort',
    icon: '🚙',
    pricePerKm: 0.75,
    baseFare: 3.00,
    capacity: 4,
    description: 'More comfortable ride',
    color: '0xFF007A5E',
  ),
  RideTypeModel(
    id: 'premium',
    name: 'Premium',
    icon: '🚘',
    pricePerKm: 1.00,
    baseFare: 4.00,
    capacity: 4,
    description: 'Premium experience',
    color: '0xFFCEA946',
  ),
  RideTypeModel(
    id: 'xl',
    name: 'XL',
    icon: '🚐',
    pricePerKm: 1.25,
    baseFare: 5.00,
    capacity: 6,
    description: 'For groups & luggage',
    color: '0xFFFF6B6B',
  ),
];
EOF
echo -e "${GREEN}✓ Created ride_type_model.dart${NC}"

# Create Maps Controller
cat > lib/presentation/controllers/maps_controller.dart << 'EOF'
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
EOF
echo -e "${GREEN}✓ Created maps_controller.dart${NC}"

# Create Request Ride Controller
cat > lib/presentation/controllers/request_ride_controller.dart << 'EOF'
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
EOF
echo -e "${GREEN}✓ Created request_ride_controller.dart${NC}"

# Create Location Search Screen
mkdir -p lib/presentation/screens/maps
cat > lib/presentation/screens/maps/location_search_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import '../../../data/models/location_model.dart';

class LocationSearchScreen extends StatefulWidget {
  final String title;
  
  const LocationSearchScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  late TextEditingController _searchController;
  List<LocationModel> searchResults = [];
  bool isSearching = false;

  // Popular locations in Ghana
  final popularLocations = [
    LocationModel(
      address: 'Accra Central',
      latitude: 5.5520,
      longitude: -0.2029,
      placeName: 'Accra Central',
      placeType: 'City Center',
    ),
    LocationModel(
      address: 'Osu',
      latitude: 5.5753,
      longitude: -0.1693,
      placeName: 'Osu',
      placeType: 'District',
    ),
    LocationModel(
      address: 'Tema',
      latitude: 5.6140,
      longitude: -0.0119,
      placeName: 'Tema',
      placeType: 'City',
    ),
    LocationModel(
      address: 'Kumasi',
      latitude: 6.6753,
      longitude: -1.6207,
      placeName: 'Kumasi',
      placeType: 'City',
    ),
    LocationModel(
      address: 'Cape Coast',
      latitude: 5.1033,
      longitude: -1.2455,
      placeName: 'Cape Coast',
      placeType: 'City',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final locations = await locationFromAddress(query);
      
      setState(() {
        searchResults = locations
            .map((location) => LocationModel(
              address: query,
              latitude: location.latitude,
              longitude: location.longitude,
            ))
            .toList();
      });
    } catch (e) {
      // Show popular locations as fallback
      setState(() {
        searchResults = popularLocations
            .where((loc) =>
                loc.placeName!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchLocations,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: Icon(Icons.location_on_outlined),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isSearching
                ? Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                    ? _buildPopularLocations()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularLocations() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Popular Locations',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        ...popularLocations.map((location) {
          return ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text(location.placeName ?? location.address),
            subtitle: Text(location.placeType ?? ''),
            onTap: () => Get.back(result: location),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final location = searchResults[index];
        return ListTile(
          leading: Icon(Icons.location_on_outlined),
          title: Text(location.address),
          onTap: () => Get.back(result: location),
        );
      },
    );
  }
}
EOF
echo -e "${GREEN}✓ Created location_search_screen.dart${NC}"

# Create Request Ride Screen
cat > lib/presentation/screens/maps/request_ride_screen.dart << 'EOF'
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
EOF
echo -e "${GREEN}✓ Created request_ride_screen.dart${NC}"

# Update Ride Tab to have button to Request Ride
cat > lib/presentation/screens/home/tabs/ride_tab.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../presentation/controllers/auth_controller.dart';
import '../../../../presentation/controllers/maps_controller.dart';
import '../../../../presentation/controllers/request_ride_controller.dart';
import '../../../screens/maps/request_ride_screen.dart';

class RideTab extends StatelessWidget {
  const RideTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Ride'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Obx(() {
              final user = authController.user.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello ${user?.firstName ?? "User"}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Where are you going?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickActionCard(
                  icon: Icons.location_searching,
                  label: 'Book Now',
                  color: Color(0xFF00D4FF),
                  onTap: () {
                    Get.put(MapsController());
                    Get.put(RequestRideController());
                    Get.to(() => RequestRideScreen());
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.schedule,
                  label: 'Schedule',
                  color: Color(0xFF007A5E),
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Schedule ride feature',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.favorite_outline,
                  label: 'Favorites',
                  color: Color(0xFFFF6B6B),
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Favorite locations',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.history,
                  label: 'Recents',
                  color: Color(0xFFFFA500),
                  onTap: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Recent rides',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Promo Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF007A5E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Special Offer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get 20% off on your next ride',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Claim Now',
                      style: TextStyle(
                        color: Color(0xFF00D4FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
EOF
echo -e "${GREEN}✓ Updated ride_tab.dart${NC}"

echo -e "\n${GREEN}✓✓✓ Maps & Ride Request System created successfully! ✓✓✓${NC}"
echo -e "\n${BLUE}Next steps:${NC}"
echo -e "1. Run: ${GREEN}flutter pub get${NC}"
echo -e "2. Add your GOOGLE_MAPS_API_KEY to .env"
echo -e "3. Run: ${GREEN}flutter run${NC}"
EOF