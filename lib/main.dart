import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'di/app_bindings.dart';
import 'di/service_locator.dart';
import 'presentation/splash/splash_view.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
      };

      try {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        await initServiceLocator();
      } catch (_) {
        // Defensive initialization fallback
      }

      runApp(const VoyageAiApp());
    },
    (error, stackTrace) {
      // Unhandled asynchronous error trap
    },
  );
}

class VoyageAiApp extends StatelessWidget {
  const VoyageAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = sl<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'VoyageAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeCtrl.themeMode,
        initialBinding: AppBindings(),
        home: const SplashView(),
      ),
    );
  }
}
