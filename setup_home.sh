#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Creating Home Screen & Navigation System...${NC}\n"

# Create bottom nav controller
cat > lib/presentation/controllers/bottom_nav_controller.dart << 'EOF'
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void goToRide() => changeTab(0);
  void goToEarnings() => changeTab(1);
  void goToProfile() => changeTab(2);
}
EOF
echo -e "${GREEN}✓ Created bottom_nav_controller.dart${NC}"

# Create home screen
cat > lib/presentation/screens/home/home_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../presentation/controllers/bottom_nav_controller.dart';
import '../home/tabs/ride_tab.dart';
import '../home/tabs/earnings_tab.dart';
import '../home/tabs/profile_tab.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final bottomNavController = Get.put(BottomNavController());
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (bottomNavController.currentIndex.value) {
          case 0:
            return const RideTab();
          case 1:
            return const EarningsTab();
          case 2:
            return const ProfileTab();
          default:
            return const RideTab();
        }
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: bottomNavController.currentIndex.value,
          onTap: bottomNavController.changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF00D4FF),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              activeIcon: Icon(Icons.location_on),
              label: 'Ride',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_outlined),
              activeIcon: Icon(Icons.trending_up),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
EOF
echo -e "${GREEN}✓ Created home_screen.dart${NC}"

# Create ride tab
mkdir -p lib/presentation/screens/home/tabs
cat > lib/presentation/screens/home/tabs/ride_tab.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../presentation/controllers/auth_controller.dart';

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
                    Get.snackbar(
                      'Coming Soon',
                      'Ride booking feature',
                      snackPosition: SnackPosition.BOTTOM,
                    );
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
echo -e "${GREEN}✓ Created ride_tab.dart${NC}"

# Create earnings tab
cat > lib/presentation/screens/home/tabs/earnings_tab.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../presentation/controllers/auth_controller.dart';

class EarningsTab extends StatelessWidget {
  const EarningsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Earnings',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'GHS 0.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Trips', '0'),
                      _buildStatCard('Rating', '5.0'),
                      _buildStatCard('Distance', '0 km'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Trip History Header
            const Text(
              'Recent Trips',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Empty State
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.local_taxi_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No trips yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your first ride to see it here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
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

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
EOF
echo -e "${GREEN}✓ Created earnings_tab.dart${NC}"

# Create profile tab
cat > lib/presentation/screens/home/tabs/profile_tab.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../presentation/controllers/auth_controller.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final user = authController.user.value;
          return Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF00D4FF),
                      child: Text(
                        (user?.firstName?.isNotEmpty ?? false)
                            ? user!.firstName![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${user?.firstName ?? ""} ${user?.lastName ?? ""}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? user?.phoneNumber ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu Items
              _buildMenuItem(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () {
                  Get.snackbar('Coming Soon', 'Edit profile feature');
                },
              ),
              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                onTap: () {
                  Get.snackbar('Coming Soon', 'Payment methods');
                },
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Get.snackbar('Coming Soon', 'Settings');
                },
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  Get.snackbar('Coming Soon', 'Help & Support');
                },
              ),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  Get.snackbar('About', 'Ride Hailing Ghana v1.0.0');
                },
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Logout',
                      middleText: 'Are you sure you want to logout?',
                      textConfirm: 'Yes',
                      textCancel: 'No',
                      onConfirm: () {
                        Get.back();
                        authController.signOut();
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6B6B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Color(0xFF00D4FF)),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        Divider(height: 1),
      ],
    );
  }
}
EOF
echo -e "${GREEN}✓ Created profile_tab.dart${NC}"

# Update app_routes.dart
cat > lib/presentation/routes/app_routes.dart << 'EOF'
import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/home/home_screen.dart';

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

  static List<GetPage> get pages => [
        GetPage(
          name: login,
          page: () => const LoginScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: signup,
          page: () => const SignupScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: phoneVerification,
          page: () => const OTPVerificationScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: home,
          page: () => HomeScreen(),
          transition: Transition.fadeIn,
        ),
      ];
}
EOF
echo -e "${GREEN}✓ Updated app_routes.dart${NC}"

echo -e "\n${GREEN}✓✓✓ Home Screen & Navigation created successfully! ✓✓✓${NC}"
echo -e "\n${BLUE}Next steps:${NC}"
echo -e "1. Run: ${GREEN}flutter pub get${NC}"
echo -e "2. Update lib/main.dart to route to home screen after login"
echo -e "3. Run: ${GREEN}flutter run${NC}"
EOF