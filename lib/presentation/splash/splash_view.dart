import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/storage/app_database.dart';
import '../../di/service_locator.dart';
import '../shell/views/adaptive_scaffold.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String _statusText =
      'Initializing offline SQLite itinerary & boarding pass vault...';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _animController.repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runInitializationPipeline();
    });
  }

  Future<void> _runInitializationPipeline() async {
    try {
      // Step 1: Seed SQLite offline vault
      final appDb = sl<AppDatabase>();
      await appDb.seedInitialDataIfEmpty();

      if (!mounted) return;
      setState(() {
        _statusText =
            'Mounting native barometric altimeter & compass bridge...';
      });

      await Future.delayed(const Duration(milliseconds: 650));

      if (!mounted) return;
      setState(() {
        _statusText = 'VoyageAI Expedition Ready.';
      });

      await Future.delayed(const Duration(milliseconds: 450));

      if (!mounted) return;
      Get.off(
        () => const AdaptiveScaffold(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 400),
      );
    } catch (_) {
      if (!mounted) return;
      Get.off(
        () => const AdaptiveScaffold(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 400),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value.clamp(0.2, 1.0),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surfaceContainerHigh,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withAlpha(50),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.explore,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 36),
              Text(
                'VOYAGEAI',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ENTERPRISE EXPEDITION & TRAVEL SUITE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _statusText,
                  key: ValueKey<String>(_statusText),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
