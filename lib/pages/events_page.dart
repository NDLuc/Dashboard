import 'package:dashboard/models/event.dart';
import 'package:dashboard/nav.dart';
import 'package:dashboard/services/event_service.dart';
import 'package:dashboard/theme.dart';
import 'package:dashboard/widgets/event_list_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum EventsRange { today, last7, last30 }

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final _service = EventService();
  EventsRange _range = EventsRange.today;
  bool _loading = true;
  String? _error;
  List<Event> _all = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.listEvents();
      if (!mounted) return;
      setState(() => _all = items);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _all = const [];
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Event> _filtered() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final start = switch (_range) {
      EventsRange.today => startOfToday,
      EventsRange.last7 => startOfToday.subtract(const Duration(days: 7)),
      EventsRange.last30 => startOfToday.subtract(const Duration(days: 30)),
    };
    return _all.where((e) => e.occurredAt.isAfter(start)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = _filtered();

    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sự kiện bất thường', style: context.textStyles.titleMedium?.semiBold),
          centerTitle: true,
          leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
        ),
        body: Padding(
          padding: AppSpacing.horizontalMd,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              _RangeBar(
                selected: _range,
                counts: (
                  today: _all.where((e) => e.occurredAt.isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))).length,
                  last7: _all.where((e) => e.occurredAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length,
                  last30: _all.where((e) => e.occurredAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))).length,
                ),
                onSelected: (r) => setState(() => _range = r),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text('${items.length} sự kiện', style: context.textStyles.titleSmall?.semiBold),
                  const Spacer(),
                  _SortButton(onTap: () {}),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  child: _loading
                      ? Center(child: CircularProgressIndicator(color: cs.primary))
                      : _error != null
                      ? _ErrorState(message: _error!, onRetry: _load)
                      : items.isEmpty
                      ? _EmptyState(onRetry: _load)
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            key: ValueKey(_range),
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 18),
                            itemBuilder: (context, index) {
                              final e = items[index];
                              return EventListCard(
                                event: e,
                                onTap: () => context.push('${AppRoutes.events}/${e.id}'),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemCount: items.length,
                          ),
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

typedef _Counts = ({int today, int last7, int last30});

class _RangeBar extends StatelessWidget {
  final EventsRange selected;
  final _Counts counts;
  final ValueChanged<EventsRange> onSelected;
  const _RangeBar({required this.selected, required this.counts, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(child: _RangeTile(selected: selected == EventsRange.today, title: 'Hôm nay', value: counts.today.toString(), onTap: () => onSelected(EventsRange.today))),
          Expanded(child: _RangeTile(selected: selected == EventsRange.last7, title: '7 ngày qua', value: counts.last7.toString(), onTap: () => onSelected(EventsRange.last7))),
          Expanded(child: _RangeTile(selected: selected == EventsRange.last30, title: '30 ngày qua', value: counts.last30.toString(), onTap: () => onSelected(EventsRange.last30))),
        ],
      ),
    );
  }
}

class _RangeTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String value;
  final VoidCallback onTap;
  const _RangeTile({required this.selected, required this.title, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: selected ? Border.all(color: cs.primary, width: 1.5) : null,
      ),
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(title, style: context.textStyles.labelSmall?.withColor(selected ? cs.primary : cs.onSurfaceVariant)),
              const SizedBox(height: 6),
              Text(value, style: context.textStyles.titleSmall?.semiBold?.withColor(selected ? cs.primary : cs.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SortButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text('Mới nhất', style: context.textStyles.labelLarge?.withColor(cs.onSurface)),
              const SizedBox(width: 6),
              Icon(Icons.keyboard_arrow_down, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 48),
        Icon(Icons.cloud_off_outlined, size: 48, color: cs.error),
        const SizedBox(height: 12),
        Text('Không tải được dữ liệu', style: context.textStyles.titleSmall?.semiBold, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(message, style: context.textStyles.bodySmall?.withColor(cs.onSurfaceVariant), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 48),
        Icon(Icons.inbox_outlined, size: 48, color: cs.onSurfaceVariant),
        const SizedBox(height: 12),
        Text('Chưa có sự kiện', style: context.textStyles.titleSmall?.semiBold, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'Thêm dữ liệu vào bảng events trên Supabase hoặc kéo xuống để làm mới.',
          style: context.textStyles.bodySmall?.withColor(cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(onPressed: onRetry, child: const Text('Làm mới')),
        ),
      ],
    );
  }
}
