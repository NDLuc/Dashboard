import 'package:dashboard/config/supabase_config.dart';
import 'package:dashboard/models/app_user.dart';
import 'package:dashboard/services/event_service.dart';
import 'package:dashboard/theme.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _service = EventService();
  AppUser? _user;
  bool _loading = true;
  String? _error;

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

    if (!SupabaseConfig.isConfigured) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Chưa cấu hình Supabase URL / anon key.';
      });
      return;
    }

    try {
      final user = await _service.getOrCreateUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final connected = SupabaseConfig.isConfigured && _error == null && _user != null;

    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cài đặt', style: context.textStyles.titleMedium?.semiBold),
          centerTitle: true,
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: connected ? cs.primaryContainer : cs.errorContainer,
                      child: Icon(
                        connected ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                        color: connected ? cs.onPrimaryContainer : cs.onErrorContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _loading ? 'Đang kết nối...' : (_user?.name ?? 'Tài xế'),
                            style: context.textStyles.titleSmall?.semiBold,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            connected
                                ? 'Đã kết nối Supabase'
                                : (_error ?? 'Chưa kết nối Supabase'),
                            style: context.textStyles.labelSmall?.withColor(cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
                ),
                child: Text(
                  SupabaseConfig.isConfigured
                      ? 'Dữ liệu sự kiện được lấy trực tiếp từ bảng events trên Supabase.'
                      : 'Mở lib/config/supabase_config.dart và điền SUPABASE_URL cùng SUPABASE_ANON_KEY, '
                          'sau đó chạy supabase/schema.sql trong SQL Editor của Supabase.',
                  style: context.textStyles.bodyMedium?.withColor(cs.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
