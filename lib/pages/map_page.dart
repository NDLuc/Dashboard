import 'package:dashboard/models/event.dart';
import 'package:dashboard/nav.dart';
import 'package:dashboard/services/event_service.dart';
import 'package:dashboard/theme.dart';
import 'package:dashboard/widgets/info_banner.dart';
import 'package:dashboard/widgets/pulsing_marker.dart';
import 'package:dashboard/widgets/severity_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  static const _defaultCenter = LatLng(10.7769, 106.7009);

  final _service = EventService();
  final _mapController = MapController();
  late final AnimationController _pulse;

  List<Event> _events = const [];
  int _invalidCoordinateCount = 0;
  bool _loading = true;
  bool _mapReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _loadEvents();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.listEvents();
      final valid = <Event>[];
      var invalid = 0;
      for (final e in items) {
        if (e.hasValidMapCoordinates) {
          valid.add(e);
        } else {
          invalid++;
        }
      }
      if (!mounted) return;
      setState(() {
        _events = valid;
        _invalidCoordinateCount = invalid;
      });
      if (_mapReady) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _fitMarkers(valid));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _events = const [];
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _todayCount() {
    final start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return _events.where((e) => e.occurredAt.isAfter(start)).length;
  }

  void _fitMarkers(List<Event> events) {
    if (!_mapReady) return;

    try {
      if (events.isEmpty) {
        _mapController.move(_defaultCenter, 11);
        return;
      }
      if (events.length == 1) {
        final point = events.first.mapPosition;
        _mapController.move(point, 14);
        return;
      }
      final points = events.map((e) => e.mapPosition).toList();
      if (points.length >= 2) {
        final first = points.first;
        final allSame = points.every((p) => p.latitude == first.latitude && p.longitude == first.longitude);
        if (allSame) {
          _mapController.move(first, 14);
          return;
        }
      }
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(56),
        ),
      );
    } catch (e) {
      debugPrint('MapPage._fitMarkers failed: $e');
    }
  }

  void _zoomBy(double delta) {
    if (!_mapReady) return;
    try {
      final camera = _mapController.camera;
      _mapController.move(camera.center, (camera.zoom + delta).clamp(3, 18));
    } catch (e) {
      debugPrint('MapPage._zoomBy failed: $e');
    }
  }

  Color _markerColor(Event event) => event.severity.dotColor;

  String _bannerText() {
    if (_loading) return 'Đang tải vị trí từ Supabase...';
    if (_events.isEmpty && _invalidCoordinateCount == 0) {
      return 'Chưa có tọa độ sự kiện để hiển thị trên bản đồ.';
    }
    if (_events.isEmpty && _invalidCoordinateCount > 0) {
      return 'Tọa độ không hợp lệ. lat: 8–23, lng: 102–110 (VN). Không nhập ngược cột.';
    }
    if (_invalidCoordinateCount > 0) {
      return '${_events.length} vị trí hợp lệ. $_invalidCoordinateCount sự kiện có tọa độ sai — kiểm tra Supabase.';
    }
    return '${_events.length} vị trí từ Supabase. Bấm ↻ để cập nhật sau khi sửa lat/lng.';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Vị trí bất thường', style: context.textStyles.titleMedium?.semiBold),
          centerTitle: true,
          leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          actions: [
            IconButton(onPressed: _loadEvents, icon: const Icon(Icons.refresh)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: AppSpacing.horizontalMd,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 380;
                  final cards = [
                    _TotalPointsCard(count: _todayCount()),
                    const _RouteFilterCard(),
                    const _DateFilterCard(),
                  ];
                  if (narrow) {
                    return Column(
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          cards[i],
                        ],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(child: cards[i]),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: AppSpacing.horizontalMd,
              child: InfoBanner(
                text: _bannerText(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Stack(
                children: [
                  _loading
                      ? Center(child: CircularProgressIndicator(color: cs.primary))
                      : _error != null
                      ? _MapError(message: _error!, onRetry: _loadEvents)
                      : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _defaultCenter,
                            initialZoom: 11,
                            minZoom: 3,
                            maxZoom: 18,
                            onMapReady: () {
                              _mapReady = true;
                              _fitMarkers(_events);
                            },
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.my_app',
                            ),
                            MarkerLayer(
                              markers: [
                                for (final event in _events)
                                  Marker(
                                    point: event.mapPosition,
                                    width: 44,
                                    height: 44,
                                    child: GestureDetector(
                                      onTap: () => _showEventSheet(context, event),
                                      child: PulsingMarker(
                                        pulse: _pulse,
                                        color: _markerColor(event),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                  if (!_loading && _error == null)
                    Positioned(
                      right: 14,
                      bottom: 16,
                      child: _MapControls(
                        onLocate: () => _fitMarkers(_events),
                        onZoomIn: () => _zoomBy(1),
                        onZoomOut: () => _zoomBy(-1),
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

  void _showEventSheet(BuildContext context, Event event) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.addressLine, style: context.textStyles.titleSmall?.semiBold),
            const SizedBox(height: 4),
            Text(event.districtLine, style: context.textStyles.bodySmall?.withColor(cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(
              'Lat: ${event.lat.toStringAsFixed(5)}, Lng: ${event.lng.toStringAsFixed(5)}',
              style: context.textStyles.labelSmall?.withColor(cs.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            SeverityChip(severity: event.severity),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('${AppRoutes.events}/${event.id}');
                },
                child: const Text('Xem chi tiết'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _MapError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 48, color: cs.error),
            const SizedBox(height: 12),
            Text('Không tải được bản đồ', style: context.textStyles.titleSmall?.semiBold),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: context.textStyles.bodySmall?.withColor(cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

Widget _filterCard(BuildContext context, {required Widget child}) {
  final cs = Theme.of(context).colorScheme;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    decoration: BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      border: Border.all(color: cs.outline.withValues(alpha: 0.10)),
      boxShadow: AppShadows.card,
    ),
    child: child,
  );
}

class _TotalPointsCard extends StatelessWidget {
  final int count;
  const _TotalPointsCard({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _filterCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng điểm bất thường', style: context.textStyles.labelSmall?.withColor(cs.onSurfaceVariant), maxLines: 2),
          const SizedBox(height: 6),
          Text('$count', style: context.textStyles.headlineSmall?.semiBold?.withColor(cs.error)),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(width: 7, height: 7, decoration: BoxDecoration(color: cs.error, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('Hôm nay', style: context.textStyles.labelSmall?.withColor(cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteFilterCard extends StatelessWidget {
  const _RouteFilterCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _filterCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tuyến đường', style: context.textStyles.labelSmall?.withColor(cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('Tất cả', style: context.textStyles.titleSmall?.semiBold, overflow: TextOverflow.ellipsis),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateFilterCard extends StatelessWidget {
  const _DateFilterCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final label = '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    return _filterCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ngày', style: context.textStyles.labelSmall?.withColor(cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(label, style: context.textStyles.titleSmall?.semiBold, overflow: TextOverflow.ellipsis),
              ),
              Icon(Icons.calendar_today_rounded, size: 15, color: cs.onSurfaceVariant),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  final VoidCallback onLocate;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  const _MapControls({required this.onLocate, required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget button(IconData icon, VoidCallback onTap) => Material(
      color: cs.surface.withValues(alpha: 0.92),
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 44, height: 44, child: Icon(icon, color: cs.onSurface, size: 22)),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(Icons.my_location, onLocate),
        const SizedBox(height: 8),
        button(Icons.add, onZoomIn),
        const SizedBox(height: 8),
        button(Icons.remove, onZoomOut),
      ],
    );
  }
}
