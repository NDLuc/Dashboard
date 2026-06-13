import 'package:dashboard/models/event.dart';
import 'package:dashboard/services/event_service.dart';
import 'package:dashboard/theme.dart';
import 'package:dashboard/widgets/info_banner.dart';
import 'package:dashboard/widgets/pulsing_marker.dart';
import 'package:dashboard/widgets/severity_chip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final _service = EventService();
  Event? _event;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final e = await _service.getEventById(widget.eventId);
      if (!mounted) return;
      setState(() => _event = e);
    } catch (e) {
      debugPrint('EventDetailPage load failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chi tiết sự kiện', style: context.textStyles.titleMedium?.semiBold),
          centerTitle: true,
          leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
          actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined))],
        ),
        body: Padding(
          padding: AppSpacing.horizontalMd,
          child: _loading
              ? Center(child: CircularProgressIndicator(color: cs.primary))
              : (_event == null)
                  ? _EmptyState(onBack: () => context.pop())
                  : _DetailBody(event: _event!, two: _two),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBack;
  const _EmptyState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 32, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('Không tìm thấy sự kiện', style: context.textStyles.titleSmall?.semiBold),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onBack, child: Text('Quay lại', style: TextStyle(color: cs.onSurface))),
        ],
      ),
    );
  }
}

class _DetailBody extends StatefulWidget {
  final Event event;
  final String Function(int) two;
  const _DetailBody({required this.event, required this.two});

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final two = widget.two;
    final cs = Theme.of(context).colorScheme;
    final timeRange = '${two(event.occurredAt.hour)}:${two(event.occurredAt.minute)} - ${two(event.occurredAt.day)}/${two(event.occurredAt.month)}/${event.occurredAt.year}';

    return ListView(
      padding: const EdgeInsets.only(bottom: 22),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.10)),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: event.severity.dotColor,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: event.severity.dotColor.withValues(alpha: 0.16), blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SeverityChip(severity: event.severity),
                  const Spacer(),
                  Text(event.id, style: context.textStyles.labelSmall?.withColor(cs.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 14),
              _InfoRow(icon: Icons.access_time, label: 'Thời gian', value: timeRange),
              const SizedBox(height: 10),
              _InfoRow(icon: Icons.place_outlined, label: 'Địa chỉ', value: '${event.addressLine}\n${event.districtLine}'),
              const SizedBox(height: 10),
              _InfoRow(icon: Icons.speed, label: 'Tốc độ xe', value: '${event.speedKmh.toStringAsFixed(0)} km/h'),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.vibration,
                label: 'Mức rung',
                valueWidget: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: event.severity.dotColor, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      '${event.severity.levelLabel} (${event.gForce.toStringAsFixed(2)} g)',
                      style: context.textStyles.bodyMedium?.withColor(cs.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.surfaceContainerHighest.withValues(alpha: 0.45),
                        cs.primaryContainer.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
                Center(child: PulsingMarker(pulse: _pulse, color: cs.error, size: 20)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const InfoBanner(
          text: 'Dữ liệu từ sự kiện được gửi bởi thiết bị, không theo dõi liên tục.',
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.map_outlined, color: cs.onPrimary),
          label: Text('Xem trên bản đồ', style: TextStyle(color: cs.onPrimary)),
          style: ElevatedButton.styleFrom(backgroundColor: cs.primary, minimumSize: const Size(double.infinity, 48)),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.chat_bubble_outline, color: cs.primary),
          label: Text('Gửi phản hồi', style: TextStyle(color: cs.primary)),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  const _InfoRow({required this.icon, required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 10),
        SizedBox(width: 76, child: Text(label, style: context.textStyles.labelSmall?.withColor(cs.onSurfaceVariant))),
        const SizedBox(width: 10),
        Expanded(
          child: valueWidget ?? Text(value!, style: context.textStyles.bodyMedium?.withColor(cs.onSurface)),
        ),
      ],
    );
  }
}
