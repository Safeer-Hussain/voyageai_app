import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppFeedback {
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFloatingSnackbar(
      title: title,
      message: message,
      icon: Icons.check_circle_outline,
      iconColor: const Color(0xFF10B981),
      duration: duration,
    );
  }

  static void showWarning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFloatingSnackbar(
      title: title,
      message: message,
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFF59E0B),
      duration: duration,
    );
  }

  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showFloatingSnackbar(
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: const Color(0xFFEF4444),
      duration: duration,
    );
  }

  static void showInfo({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFloatingSnackbar(
      title: title,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: const Color(0xFF38BDF8),
      duration: duration,
    );
  }

  static void _showFloatingSnackbar({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Duration duration,
  }) {
    if (Get.testMode || Get.context == null) {
      return;
    }
    final context = Get.context;
    final colorScheme = context != null ? Theme.of(context).colorScheme : null;

    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme?.onSurface ?? Colors.white,
          ),
        ),
        messageText: Text(
          message,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colorScheme?.onSurfaceVariant ?? Colors.white70,
          ),
        ),
        icon: Icon(icon, color: iconColor, size: 24),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 14,
        duration: duration,
        isDismissible: true,
        backgroundColor:
            colorScheme?.surfaceContainerHighest ?? const Color(0xFF1E293B),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
