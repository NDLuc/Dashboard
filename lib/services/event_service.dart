import 'package:dashboard/config/supabase_config.dart';
import 'package:dashboard/models/app_user.dart';
import 'package:dashboard/models/event.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<AppUser> getOrCreateUser() async {
    _ensureConfigured();

    try {
      final row = await _client.from('users').select().limit(1).maybeSingle();
      if (row != null) {
        return AppUser.fromJson(Map<String, dynamic>.from(row));
      }
    } catch (e) {
      debugPrint('EventService.getOrCreateUser failed: $e');
      rethrow;
    }

    throw Exception('Không tìm thấy người dùng trong Supabase. Hãy thêm bản ghi vào bảng users.');
  }

  Future<List<Event>> listEvents() async {
    _ensureConfigured();

    try {
      final rows = await _client.from('events').select().order('occurred_at', ascending: false);
      final items = <Event>[];
      for (final row in rows) {
        if (row is Map<String, dynamic>) {
          items.add(Event.fromJson(row));
        } else if (row is Map) {
          items.add(Event.fromJson(Map<String, dynamic>.from(row)));
        }
      }
      return items;
    } catch (e) {
      debugPrint('EventService.listEvents failed: $e');
      rethrow;
    }
  }

  Future<Event?> getEventById(String id) async {
    _ensureConfigured();

    try {
      final row = await _client.from('events').select().eq('id', id).maybeSingle();
      if (row == null) return null;
      return Event.fromJson(Map<String, dynamic>.from(row));
    } catch (e) {
      debugPrint('EventService.getEventById failed: $e');
      rethrow;
    }
  }

  void _ensureConfigured() {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase chưa được cấu hình. Cập nhật lib/config/supabase_config.dart '
        'hoặc chạy với --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
      );
    }
  }
}
