import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../di/service_locator.dart';
import '../../ai_concierge/views/ai_concierge_view.dart';
import '../../document_vault/views/document_vault_view.dart';
import '../../expense_ledger/views/expense_ledger_view.dart';
import '../../itinerary/views/itinerary_view.dart';
import '../../route_map/views/route_map_view.dart';
import '../../settings/views/settings_view.dart';
import '../../telemetry_hud/views/telemetry_hud_view.dart';
import '../controllers/navigation_controller.dart';
import 'offline_banner.dart';

class AdaptiveScaffold extends StatefulWidget {
  const AdaptiveScaffold({super.key});

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold>
    with SingleTickerProviderStateMixin {
  late TabController _assistantTabController;

  @override
  void initState() {
    super.initState();
    _assistantTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _assistantTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<NavigationController>();
    final themeCtrl = sl<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Obx(() {
        final currentIndex = navCtrl.selectedIndex.value;

        final destinations = [
          const NavigationDestination(
            icon: Icon(Icons.view_timeline_outlined),
            selectedIcon: Icon(Icons.view_timeline),
            label: 'Itinerary',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Route Map',
          ),
          const NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Pass Vault',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Ledger',
          ),
          const NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'AI & HUD',
          ),
        ];

        final railDestinations = [
          const NavigationRailDestination(
            icon: Icon(Icons.view_timeline_outlined),
            selectedIcon: Icon(Icons.view_timeline),
            label: Text('Itinerary'),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: Text('Map'),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: Text('Vault'),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: Text('Ledger'),
          ),
          const NavigationRailDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: Text('AI & HUD'),
          ),
        ];

        Widget currentView;
        switch (currentIndex) {
          case 0:
            currentView = const ItineraryView();
            break;
          case 1:
            currentView = const RouteMapView();
            break;
          case 2:
            currentView = const DocumentVaultView();
            break;
          case 3:
            currentView = const ExpenseLedgerView();
            break;
          case 4:
            currentView = Column(
              children: [
                TabBar(
                  controller: _assistantTabController,
                  indicatorColor: colorScheme.primary,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.psychology, size: 18),
                      text: 'AI Concierge',
                    ),
                    Tab(
                      icon: Icon(Icons.compass_calibration, size: 18),
                      text: 'Expedition Compass HUD',
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _assistantTabController,
                    children: const [
                      AiTravelConciergeView(),
                      TelemetryHudView(),
                    ],
                  ),
                ),
              ],
            );
            break;
          default:
            currentView = const ItineraryView();
        }

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: isLandscape ? 36 : 48,
            title: Row(
              children: [
                Icon(
                  Icons.explore,
                  size: isLandscape ? 18 : 22,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'VOYAGEAI',
                  style: TextStyle(
                    fontSize: isLandscape ? 13 : 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  themeCtrl.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  size: isLandscape ? 18 : 22,
                  color: colorScheme.primary,
                ),
                tooltip: 'Toggle Theme',
                onPressed: themeCtrl.toggleTheme,
              ),
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  size: isLandscape ? 18 : 22,
                  color: colorScheme.onSurface,
                ),
                tooltip: 'Settings',
                onPressed: () => Get.to(() => const SettingsView()),
              ),
            ],
          ),
          bottomNavigationBar: isLandscape
              ? null
              : NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: navCtrl.setIndex,
                  destinations: destinations,
                ),
          body: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: isLandscape
                    ? Row(
                        children: [
                          SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: IntrinsicHeight(
                              child: NavigationRail(
                                minWidth: 56,
                                labelType: NavigationRailLabelType.none,
                                selectedIndex: currentIndex,
                                onDestinationSelected: navCtrl.setIndex,
                                destinations: railDestinations,
                              ),
                            ),
                          ),
                          const VerticalDivider(width: 1),
                          Expanded(child: currentView),
                        ],
                      )
                    : currentView,
              ),
            ],
          ),
        );
      }),
    );
  }
}
