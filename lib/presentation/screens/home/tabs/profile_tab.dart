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
