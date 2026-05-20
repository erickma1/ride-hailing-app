import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../presentation/controllers/bottom_nav_controller.dart';
import './tabs/ride_tab.dart';
import './tabs/earnings_tab.dart';
import './tabs/profile_tab.dart';

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
