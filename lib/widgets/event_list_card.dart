import 'package:dashboard/models/event.dart';
import 'package:dashboard/theme.dart';
import 'package:dashboard/widgets/severity_chip.dart';
import 'package:flutter/material.dart';

class EventListCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  const EventListCard({super.key, required this.event, required this.onTap});

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final time = '${_two(event.occurredAt.hour)}:${_two(event.occurredAt.minute)}';
    final date = '${_two(event.occurredAt.day)}/${_two(event.occurredAt.month)}/${event.occurredAt.year}';
    final syncColor = event.synced ? Colors.green : cs.onSurfaceVariant;
    final syncText = event.synced ? 'Đã đồng bộ' : 'Đang đồng bộ';

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.10)),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 66,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _Dot(),
                        const SizedBox(width: 8),
                        Text(time, style: context.textStyles.titleSmall?.semiBold),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(date, style: context.textStyles.labelSmall?.withColor(cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.addressLine, style: context.textStyles.titleSmall?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(event.districtLine, style: context.textStyles.labelSmall?.withColor(cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SeverityChip(severity: event.severity),
                        const Spacer(),
                        Icon(Icons.cloud_done, size: 16, color: syncColor),
                        const SizedBox(width: 6),
                        Text(syncText, style: context.textStyles.labelSmall?.withColor(syncColor)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.18), blurRadius: 10)]));
  }
}
