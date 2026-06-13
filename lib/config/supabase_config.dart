class SupabaseConfig {
  /// Thay bằng URL project Supabase của bạn (Settings → API → Project URL)
  /// hoặc truyền qua: --dart-define=SUPABASE_URL=https://xxx.supabase.co
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ajfhfiyphzngrbjlsfas.supabase.co',
  );

  /// Thay bằng anon/public key (Settings → API → anon public)
  /// hoặc truyền qua: --dart-define=SUPABASE_ANON_KEY=eyJ...
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFqZmhmaXlwaHpuZ3JiamxzZmFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNzQ2NTMsImV4cCI6MjA5Njg1MDY1M30.LmH46bOHrkjySxVaAGil6teTNkgvlJxX3_jp25XwnOk',
  );

  static bool get isConfigured {
    if (url.isEmpty || anonKey.isEmpty) return false;
    if (url.contains('YOUR_SUPABASE')) return false;
    if (anonKey.contains('YOUR_SUPABASE')) return false;
    return true;
  }
}
