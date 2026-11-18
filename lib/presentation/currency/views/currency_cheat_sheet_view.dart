import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/currency_cheat_sheet_controller.dart';
import 'widgets/cheat_sheet_grid.dart';
import 'widgets/rate_calibration_sheet.dart';
import 'widgets/tip_cockpit.dart';

class CurrencyCheatSheetView extends StatelessWidget {
  const CurrencyCheatSheetView({super.key});

  void _showCalibration(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const RateCalibrationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CurrencyCheatSheetController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Currency & Tip Cheat-Sheet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Reload Benchmark Rate',
            onPressed: ctrl.loadRate,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_currency_adjust_rate',
        onPressed: () => _showCalibration(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.tune, size: 20),
        label: const Text(
          'Adjust Rate',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.currentRate.value == null) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        final gridWidget = CheatSheetGrid(ctrl: ctrl);
        final tipWidget = TipCockpit(ctrl: ctrl);

        if (isLandscape) {
          return Row(
            children: [
              SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(children: [gridWidget]),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [tipWidget, const SizedBox(height: 72)],
                  ),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              gridWidget,
              const SizedBox(height: 12),
              tipWidget,
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }
}
