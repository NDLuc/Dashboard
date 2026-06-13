import 'package:dashboard/theme.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: AppBar(title: Text('Báo cáo', style: context.textStyles.titleMedium?.semiBold), centerTitle: true),
        body: Padding(
          padding: AppSpacing.paddingLg,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
            ),
            child: Text('Màn hình Báo cáo (placeholder)', style: context.textStyles.bodyMedium?.withColor(cs.onSurfaceVariant)),
          ),
        ),
      ),
    );
  }
}
