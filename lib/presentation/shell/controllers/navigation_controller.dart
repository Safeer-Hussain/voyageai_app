import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isOffline = false.obs;
  final RxBool isRoamingBannerDismissed = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
  }

  void _initConnectivity() {
    try {
      Connectivity().checkConnectivity().then((results) {
        _updateConnectionStatus(results);
      });
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        _updateConnectionStatus,
      );
    } catch (_) {
      isOffline.value = false;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      isOffline.value = true;
      isRoamingBannerDismissed.value = false;
    } else {
      isOffline.value = false;
    }
  }

  void setIndex(int index) {
    selectedIndex.value = index;
  }

  void dismissRoamingBanner() {
    isRoamingBannerDismissed.value = true;
  }

  void toggleSimulatedOffline(bool offline) {
    isOffline.value = offline;
    if (offline) {
      isRoamingBannerDismissed.value = false;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
