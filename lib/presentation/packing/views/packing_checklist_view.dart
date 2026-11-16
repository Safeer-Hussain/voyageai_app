import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/packing_item.dart';
import '../../itinerary/controllers/itinerary_controller.dart';
import '../controllers/packing_checklist_controller.dart';
import 'widgets/add_packing_item_sheet.dart';
import 'widgets/baggage_weight_cockpit.dart';

class PackingChecklistView extends StatelessWidget {
  const PackingChecklistView({super.key});

  void _showAddItem(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddPackingItemSheet(),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technical gear':
        return Icons.hardware;
      case 'thermal apparel':
        return Icons.checkroom;
      case 'medical & health':
        return Icons.medical_services;
      case 'field electronics':
        return Icons.battery_charging_full;
      case 'travel documents':
        return Icons.description;
      default:
        return Icons.backpack;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PackingChecklistController>();
    final itineraryCtrl = Get.find<ItineraryController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Packing & Baggage Optimizer',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_packing_add_item',
        onPressed: () => _showAddItem(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Add Gear',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        final currentTrip = itineraryCtrl.activeTrip.value;
        if (currentTrip != null && ctrl.activeTripId.value != currentTrip.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ctrl.loadItems(currentTrip.id);
          });
        }

        if (ctrl.isLoading.value && ctrl.items.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        final cockpitWidget = BaggageWeightCockpit(ctrl: ctrl);
        final filterBarWidget = _buildCategoryFilterBar(ctrl, colorScheme);
        final listWidget = _buildItemsList(ctrl, colorScheme);

        if (isLandscape) {
          return Row(
            children: [
              SizedBox(
                width: 340,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(children: [cockpitWidget]),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      filterBarWidget,
                      const SizedBox(height: 10),
                      listWidget,
                      const SizedBox(height: 72),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cockpitWidget,
              const SizedBox(height: 14),
              filterBarWidget,
              const SizedBox(height: 12),
              listWidget,
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCategoryFilterBar(
    PackingChecklistController ctrl,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: PackingChecklistController.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = PackingChecklistController.categories[index];
          final isSelected = ctrl.selectedCategory.value == cat;
          return FilterChip(
            label: Text(cat),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: colorScheme.primaryContainer,
            backgroundColor: colorScheme.surfaceContainer,
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
            ),
            onSelected: (_) => ctrl.selectCategory(cat),
          );
        },
      ),
    );
  }

  Widget _buildItemsList(
    PackingChecklistController ctrl,
    ColorScheme colorScheme,
  ) {
    final items = ctrl.filteredItems;
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 36,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No items in this packing category.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return _buildItemCard(item, ctrl, colorScheme);
      }).toList(),
    );
  }

  Widget _buildItemCard(
    PackingItem item,
    PackingChecklistController ctrl,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: item.isPacked,
              activeColor: colorScheme.primary,
              checkColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (_) => ctrl.toggleItemPacked(item.id),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.surfaceContainerHighest,
              child: Icon(
                _getCategoryIcon(item.category),
                size: 16,
                color: item.isPacked
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: item.isPacked
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isPacked
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (item.isEssential) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withAlpha(35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ESSENTIAL',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• ${ctrl.formatWeight(item.weightKg)}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: colorScheme.outline,
              ),
              onPressed: () => ctrl.deleteItem(item.id),
            ),
          ],
        ),
      ),
    );
  }
}
