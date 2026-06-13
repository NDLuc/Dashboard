import 'package:latlong2/latlong.dart';

enum EventSeverity { low, medium, high }

class Event {
  final String id;
  final String userId;
  final DateTime occurredAt;
  final String addressLine;
  final String districtLine;
  final double speedKmh;
  final double gForce;
  final bool synced;
  final EventSeverity severity;
  final double lat;
  final double lng;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.userId,
    required this.occurredAt,
    required this.addressLine,
    required this.districtLine,
    required this.speedKmh,
    required this.gForce,
    required this.synced,
    required this.severity,
    required this.lat,
    required this.lng,
    required this.createdAt,
    required this.updatedAt,
  });

  Event copyWith({
    String? id,
    String? userId,
    DateTime? occurredAt,
    String? addressLine,
    String? districtLine,
    double? speedKmh,
    double? gForce,
    bool? synced,
    EventSeverity? severity,
    double? lat,
    double? lng,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Event(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    occurredAt: occurredAt ?? this.occurredAt,
    addressLine: addressLine ?? this.addressLine,
    districtLine: districtLine ?? this.districtLine,
    speedKmh: speedKmh ?? this.speedKmh,
    gForce: gForce ?? this.gForce,
    synced: synced ?? this.synced,
    severity: severity ?? this.severity,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'occurred_at': occurredAt.toIso8601String(),
    'address_line': addressLine,
    'district_line': districtLine,
    'speed_kmh': speedKmh,
    'g_force': gForce,
    'synced': synced,
    'severity': severity.name,
    'lat': lat,
    'lng': lng,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Event.fromJson(Map<String, dynamic> json) {
    final sevRaw = (json['severity'] ?? '').toString();
    final sev = EventSeverity.values.where((e) => e.name == sevRaw).cast<EventSeverity?>().firstOrNull ?? EventSeverity.medium;
    return Event(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      occurredAt: DateTime.tryParse((json['occurred_at'] ?? '').toString()) ?? DateTime.now(),
      addressLine: (json['address_line'] ?? '').toString(),
      districtLine: (json['district_line'] ?? '').toString(),
      speedKmh: (json['speed_kmh'] is num) ? (json['speed_kmh'] as num).toDouble() : double.tryParse((json['speed_kmh'] ?? '').toString()) ?? 0,
      gForce: (json['g_force'] is num) ? (json['g_force'] as num).toDouble() : double.tryParse((json['g_force'] ?? '').toString()) ?? 0,
      synced: json['synced'] == true,
      severity: sev,
      lat: _parseCoordinate(json['lat']),
      lng: _parseCoordinate(json['lng']),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  /// lat: -90..90, lng: -180..180, không phải (0,0).
  bool get hasValidMapCoordinates {
    if (lat == 0 && lng == 0) return false;
    if (lat.abs() > 90 || lng.abs() > 180) return false;
    return true;
  }

  /// Sửa lỗi hay gặp: nhập ngược lat/lng (vd lat=106, lng=10 ở VN).
  LatLng get mapPosition {
    var la = lat;
    var ln = lng;
    if (la.abs() > 50 && ln.abs() < 50) {
      la = lng;
      ln = lat;
    }
    return LatLng(la, ln);
  }
}

double _parseCoordinate(Object? value) {
  if (value is num) return value.toDouble();
  final raw = (value ?? '').toString().trim().replaceAll(',', '.');
  return double.tryParse(raw) ?? 0;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
