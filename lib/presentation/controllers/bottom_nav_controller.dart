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
