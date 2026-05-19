#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Creating directories...${NC}"

# Create directories
mkdir -p lib/config/theme
mkdir -p lib/core/constants
mkdir -p lib/core/services
mkdir -p lib/core/utils
mkdir -p lib/data/models
mkdir -p lib/data/repositories
mkdir -p lib/domain/entities
mkdir -p lib/domain/repositories
mkdir -p lib/domain/usecases
mkdir -p lib/presentation/controllers
mkdir -p lib/presentation/screens
mkdir -p lib/presentation/widgets
mkdir -p lib/presentation/routes
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/fonts

echo -e "${GREEN}✓ Directories created${NC}\n"

echo -e "${BLUE}Creating configuration files...${NC}"

# Create config/theme/app_theme.dart
cat > lib/config/theme/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF1F1F1F);
  static const Color accent = Color(0xFF00D4FF);
  static const Color background = Color(0xFFFAFAFA);
  static const Color success = Color(0xFF51CF66);
  static const Color error = Color(0xFFFF6B6B);
  
  // Ghana Colors
  static const Color ghanaGold = Color(0xFFCEA946);
  static const Color ghanaGreen = Color(0xFF007A5E);
  static const Color ghanaRed = Color(0xFFCE1126);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: primary,
    );
  }
}
EOF
echo -e "${GREEN}✓ Created app_theme.dart${NC}"

# Create core/constants/app_strings.dart
cat > lib/core/constants/app_strings.dart << 'EOF'
class AppStrings {
  static const String appName = 'Ride Hailing Ghana';
  static const String appVersion = '1.0.0';

  // Auth
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String welcome = 'Welcome';
  static const String enterPhoneNumber = 'Enter your phone number';
  static const String phoneNumberHint = '+233 5XX XXX XXX';
  static const String verifyOtp = 'Verify OTP';
  static const String resendOtp = 'Resend OTP';

  // Ride
  static const String pickupLocation = 'Pickup Location';
  static const String dropoffLocation = 'Drop-off Location';
  static const String requestRide = 'Request Ride';
  static const String rideAccepted = 'Ride Accepted';
  static const String rideInProgress = 'Ride in Progress';
  static const String rideCompleted = 'Ride Completed';
  static const String whereAreYouGoing = 'Where are you going?';
  static const String estimatedFare = 'Estimated Fare';
  static const String distance = 'Distance';
  static const String duration = 'Duration';

  // Ghana Specific
  static const String ghs = 'GHS';
  static const String mtnMobileMoneyNumber = 'MTN Mobile Money Number';
  
  // Common
  static const String success = 'Success';
  static const String error = 'Error';
  static const String tryAgain = 'Try Again';
  static const String noInternetConnection = 'No internet connection';
  static const String errorOccurred = 'An error occurred';
}
EOF
echo -e "${GREEN}✓ Created app_strings.dart${NC}"

# Create core/constants/app_colors.dart
cat > lib/core/constants/app_colors.dart << 'EOF'
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1F1F1F);
  static const Color accent = Color(0xFF00D4FF);
  static const Color background = Color(0xFFFAFAFA);
  static const Color success = Color(0xFF51CF66);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFA500);
  static const Color neutral = Color(0xFF6B7280);
  
  // Ghana Colors
  static const Color ghanaGold = Color(0xFFCEA946);
  static const Color ghanaGreen = Color(0xFF007A5E);
  static const Color ghanaRed = Color(0xFFCE1126);
  static const Color ghanaBlack = Color(0xFF000000);
  
  // Payment
  static const Color mtnOrange = Color(0xFFFDB913);
  static const Color vodafoneRed = Color(0xFFE31E24);
  static const Color airtelYellow = Color(0xFFFFC72C);
}
EOF
echo -e "${GREEN}✓ Created app_colors.dart${NC}"

# Create core/constants/app_dimensions.dart
cat > lib/core/constants/app_dimensions.dart << 'EOF'
class AppDimensions {
  // Padding & Margins
  static const double paddingXSmall = 8;
  static const double paddingSmall = 12;
  static const double paddingMedium = 16;
  static const double paddingLarge = 20;
  static const double paddingXLarge = 24;

  // Border Radius
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;

  // Icon Sizes
  static const double iconSmall = 20;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 48;

  // Button Sizes
  static const double buttonHeight = 48;
  static const double buttonWidth = 200;
}
EOF
echo -e "${GREEN}✓ Created app_dimensions.dart${NC}"

# Create core/services/location_service.dart
cat > lib/core/services/location_service.dart << 'EOF'
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  Future<bool> requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;
    } catch (e) {
      print('Error requesting location permission: \$e');
      return false;
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      print('Error getting current location: \$e');
      return null;
    }
  }

  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '\${place.street}, \${place.locality}, \${place.administrativeArea}';
      }
    } catch (e) {
      print('Error getting address: \$e');
    }
    return null;
  }

  Stream<Position> getLocationUpdates() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    );
  }

  Future<double> calculateDistance(double startLat, double startLng,
      double endLat, double endLng) async {
    try {
      return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
    } catch (e) {
      print('Error calculating distance: \$e');
      return 0;
    }
  }
}
EOF
echo -e "${GREEN}✓ Created location_service.dart${NC}"

# Create data/models/user_model.dart
cat > lib/data/models/user_model.dart << 'EOF'
class UserModel {
  final String uid;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profileImageUrl;
  final double? rating;
  final int? totalRides;
  final bool? isDriver;
  final bool? isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.email,
    this.profileImageUrl,
    this.rating,
    this.totalRides,
    this.isDriver,
    this.isVerified,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'totalRides': totalRides,
      'isDriver': isDriver ?? false,
      'isVerified': isVerified ?? false,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      rating: map['rating']?.toDouble(),
      totalRides: map['totalRides'],
      isDriver: map['isDriver'] ?? false,
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] ?? DateTime.now(),
      updatedAt: map['updatedAt'],
    );
  }

  String get fullName => '\$firstName \$lastName';

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
    String? profileImageUrl,
    double? rating,
    int? totalRides,
    bool? isDriver,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      isDriver: isDriver ?? this.isDriver,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
EOF
echo -e "${GREEN}✓ Created user_model.dart${NC}"

# Create data/models/ride_model.dart
cat > lib/data/models/ride_model.dart << 'EOF'
class RideModel {
  final String rideId;
  final String passengerId;
  final String? driverId;
  final String pickupLocation;
  final String dropoffLocation;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final double? fare;
  final String currency;
  final String status;
  final String? rideType;
  final DateTime createdAt;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? passengerRating;
  final double? driverRating;
  final String? passengerComment;
  final String? driverComment;
  final double? distance;
  final int? duration;

  RideModel({
    required this.rideId,
    required this.passengerId,
    this.driverId,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.fare,
    this.currency = 'GHS',
    required this.status,
    this.rideType,
    required this.createdAt,
    this.startTime,
    this.endTime,
    this.passengerRating,
    this.driverRating,
    this.passengerComment,
    this.driverComment,
    this.distance,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'passengerId': passengerId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'fare': fare,
      'currency': currency,
      'status': status,
      'rideType': rideType,
      'createdAt': createdAt,
      'startTime': startTime,
      'endTime': endTime,
      'passengerRating': passengerRating,
      'driverRating': driverRating,
      'passengerComment': passengerComment,
      'driverComment': driverComment,
      'distance': distance,
      'duration': duration,
    };
  }

  factory RideModel.fromMap(Map<String, dynamic> map) {
    return RideModel(
      rideId: map['rideId'] ?? '',
      passengerId: map['passengerId'] ?? '',
      driverId: map['driverId'],
      pickupLocation: map['pickupLocation'] ?? '',
      dropoffLocation: map['dropoffLocation'] ?? '',
      pickupLat: map['pickupLat']?.toDouble(),
      pickupLng: map['pickupLng']?.toDouble(),
      dropoffLat: map['dropoffLat']?.toDouble(),
      dropoffLng: map['dropoffLng']?.toDouble(),
      fare: map['fare']?.toDouble(),
      currency: map['currency'] ?? 'GHS',
      status: map['status'] ?? 'requested',
      rideType: map['rideType'],
      createdAt: map['createdAt'] ?? DateTime.now(),
      startTime: map['startTime'],
      endTime: map['endTime'],
      passengerRating: map['passengerRating']?.toDouble(),
      driverRating: map['driverRating']?.toDouble(),
      passengerComment: map['passengerComment'],
      driverComment: map['driverComment'],
      distance: map['distance']?.toDouble(),
      duration: map['duration'],
    );
  }

  RideModel copyWith({
    String? rideId,
    String? passengerId,
    String? driverId,
    String? pickupLocation,
    String? dropoffLocation,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    double? fare,
    String? currency,
    String? status,
    String? rideType,
    DateTime? createdAt,
    DateTime? startTime,
    DateTime? endTime,
    double? passengerRating,
    double? driverRating,
    String? passengerComment,
    String? driverComment,
    double? distance,
    int? duration,
  }) {
    return RideModel(
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      fare: fare ?? this.fare,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      rideType: rideType ?? this.rideType,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      passengerRating: passengerRating ?? this.passengerRating,
      driverRating: driverRating ?? this.driverRating,
      passengerComment: passengerComment ?? this.passengerComment,
      driverComment: driverComment ?? this.driverComment,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
    );
  }
}
EOF
echo -e "${GREEN}✓ Created ride_model.dart${NC}"

# Create presentation/routes/app_routes.dart
cat > lib/presentation/routes/app_routes.dart << 'EOF'
import 'package:get/get.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String phoneVerification = '/phone-verification';
  static const String home = '/home';
  static const String requestRide = '/request-ride';
  static const String rideTracking = '/ride-tracking';
  static const String rideHistory = '/ride-history';
  static const String profile = '/profile';
  static const String payment = '/payment';

  static List<GetPage> get pages => [];
}
EOF
echo -e "${GREEN}✓ Created app_routes.dart${NC}"

# Create empty placeholder files for directories
touch lib/presentation/screens/.gitkeep
touch lib/presentation/widgets/.gitkeep
touch lib/presentation/controllers/.gitkeep
touch lib/data/repositories/.gitkeep
touch lib/domain/entities/.gitkeep
touch lib/domain/repositories/.gitkeep
touch lib/domain/usecases/.gitkeep
touch lib/core/utils/.gitkeep

echo -e "${GREEN}✓ Created placeholder files${NC}"

echo -e "\n${BLUE}Creating root configuration files...${NC}"

# Create .env.example if it doesn't exist
if [ ! -f .env.example ]; then
  cat > .env.example << 'EOF'
# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket

# Google Maps API
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
GOOGLE_MAPS_WEB_API_KEY=your_google_maps_web_api_key

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key
STRIPE_SECRET_KEY=sk_test_your_secret_key

# Ghana Payment Integration
PAYMENT_GATEWAY_URL=https://api.payment-gateway.com
PAYMENT_API_KEY=your_payment_api_key

# App Configuration
APP_NAME=RideHailing
APP_VERSION=1.0.0
DEBUG_MODE=true
EOF
  echo -e "${GREEN}✓ Created .env.example${NC}"
else
  echo -e "${GREEN}✓ .env.example already exists${NC}"
fi

# Create .env from .env.example if it doesn't exist
if [ ! -f .env ]; then
  cp .env.example .env
  echo -e "${GREEN}✓ Created .env${NC}"
else
  echo -e "${GREEN}✓ .env already exists${NC}"
fi

echo -e "\n${GREEN}✓✓✓ All files created successfully! ✓✓✓${NC}"
echo -e "\n${BLUE}Next steps:${NC}"
echo -e "1. Run: ${GREEN}flutter pub get${NC}"
echo -e "2. Update .env with your API keys"
echo -e "3. Run: ${GREEN}flutter run${NC}"
EOF