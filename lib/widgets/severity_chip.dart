import 'package:dashboard/models/event.dart';
import 'package:dashboard/theme.dart';
import 'package:flutter/material.dart';

extension EventSeverityLabel on EventSeverity {
  String get levelLabel => switch (this) {
    EventSeverity.high => 'Cao',
    EventSeverity.medium => 'Trung bình',
    EventSeverity.low => 'Thấp',
  };

  Color get dotColor => switch (this) {
    EventSeverity.high => const Color(0xFFE53935),
    EventSeverity.medium => const Color(0xFFFB8C00),
    EventSeverity.low => const Color(0xFF43A047),
  };
}

class SeverityChip extends StatelessWidget {
  final EventSeverity severity;
  const SeverityChip({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg, label) = switch (severity) {
      EventSeverity.high => (cs.errorContainer, cs.onErrorContainer, 'Mức rung cao'),
      EventSeverity.medium => (AppSemanticColors.warningContainer(cs), AppSemanticColors.onWarningContainer(cs), 'Mức rung trung bình'),
      EventSeverity.low => (AppSemanticColors.successContainer(cs), AppSemanticColors.onSuccessContainer(cs), 'Mức rung thấp'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: context.textStyles.labelSmall?.withColor(fg)),
    );
  }
}
