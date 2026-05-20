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
