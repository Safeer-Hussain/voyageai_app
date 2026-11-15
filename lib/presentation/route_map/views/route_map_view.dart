import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../itinerary/controllers/itinerary_controller.dart';
import '../controllers/route_map_controller.dart';
import 'widgets/waypoint_detail_card.dart';

class RouteMapView extends StatefulWidget {
  const RouteMapView({super.key});

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    final mapCtrl = Get.find<RouteMapController>();
    mapCtrl.mapController = _mapController;
    final itineraryCtrl = Get.find<ItineraryController>();

    if (itineraryCtrl.activeTrip.value != null) {
      mapCtrl.loadWaypoints(itineraryCtrl.activeTrip.value!.id);
    }
  }

  Color _getMarkerColor(String category, ColorScheme colorScheme) {
    switch (category.toLowerCase()) {
      case 'landmarks':
        return colorScheme.primary;
      case 'accommodations':
        return colorScheme.secondary;
      case 'dining':
        return colorScheme.tertiary;
      case 'transit hubs':
        return Colors.orangeAccent;
      default:
        return colorScheme.primary;
    }
  }

  IconData _getMarkerIcon(String category) {
    switch (category.toLowerCase()) {
      case 'landmarks':
        return Icons.account_balance;
      case 'accommodations':
        return Icons.hotel;
      case 'dining':
        return Icons.restaurant;
      case 'transit hubs':
        return Icons.directions_bus;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapCtrl = Get.find<RouteMapController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'fab_map_recenter',
        onPressed: mapCtrl.recenterMap,
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurface,
        child: const Icon(Icons.my_location, size: 20),
      ),
      body: Obx(() {
        final waypoints = mapCtrl.visibleWaypoints;
        final selectedWp = mapCtrl.selectedWaypoint.value;
        final centerPoint = waypoints.isNotEmpty
            ? LatLng(waypoints.first.latitude, waypoints.first.longitude)
            : const LatLng(36.3257, 74.6611);

        final mapContent = FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: centerPoint,
            initialZoom: 10.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.safeer.voyageai',
              tileProvider: NetworkTileProvider(),
            ),
            if (mapCtrl.routeCoordinates.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: mapCtrl.routeCoordinates,
                    strokeWidth: 4.0,
                    color: colorScheme.primary.withAlpha(200),
                  ),
                ],
              ),
            MarkerLayer(
              markers: waypoints.map((wp) {
                final isSelected = selectedWp?.id == wp.id;
                final markerColor = _getMarkerColor(wp.category, colorScheme);

                return Marker(
                  point: LatLng(wp.latitude, wp.longitude),
                  width: isSelected ? 48 : 38,
                  height: isSelected ? 48 : 38,
                  child: GestureDetector(
                    onTap: () => mapCtrl.selectWaypoint(wp),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? markerColor : colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: markerColor,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getMarkerIcon(wp.category),
                        size: isSelected ? 24 : 18,
                        color: isSelected ? Colors.white : markerColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );

        if (isLandscape) {
          return Row(
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    mapContent,
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: _buildCategoryFilterBar(mapCtrl, colorScheme),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WAYPOINT TELEMETRY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (selectedWp != null)
                        WaypointDetailCard(
                          waypoint: selectedWp,
                          distanceFromPreviousKm: mapCtrl
                              .calculateDistanceFromPrevious(selectedWp),
                          onHighlightLeg: () =>
                              mapCtrl.highlightLeg(selectedWp),
                        )
                      else
                        Text(
                          'Tap any waypoint pin on the map to inspect leg telemetry.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 12),
                      _buildWaypointList(mapCtrl, colorScheme),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            mapContent,
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _buildCategoryFilterBar(mapCtrl, colorScheme),
            ),
            if (selectedWp != null)
              Positioned(
                bottom: 16,
                left: 14,
                right: 14,
                child: WaypointDetailCard(
                  waypoint: selectedWp,
                  distanceFromPreviousKm: mapCtrl.calculateDistanceFromPrevious(
                    selectedWp,
                  ),
                  onHighlightLeg: () => mapCtrl.highlightLeg(selectedWp),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryFilterBar(
    RouteMapController mapCtrl,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface.withAlpha(225),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: RouteMapController.categories.map((cat) {
            final isSelected = mapCtrl.selectedCategory.value == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: FilterChip(
                label: Text(cat),
                selected: isSelected,
                showCheckmark: false,
                selectedColor: colorScheme.primaryContainer,
                backgroundColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onSelected: (_) => mapCtrl.filterByCategory(cat),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWaypointList(
    RouteMapController mapCtrl,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ALL TRIP WAYPOINTS (${mapCtrl.visibleWaypoints.length})',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        ...mapCtrl.visibleWaypoints.map((wp) {
          final isSelected = mapCtrl.selectedWaypoint.value?.id == wp.id;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(
              _getMarkerIcon(wp.category),
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            title: Text(
              wp.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              'Day ${wp.dayNumber} • ${wp.altitudeMeters.toStringAsFixed(0)}m',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () => mapCtrl.selectWaypoint(wp),
          );
        }),
      ],
    );
  }
}
