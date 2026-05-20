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
