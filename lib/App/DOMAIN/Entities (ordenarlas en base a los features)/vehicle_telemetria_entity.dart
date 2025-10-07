class VehiculoTelemetria {
  final int id;
  final String vehiculoId;
  final String? rentaId;
  final DateTime ts;
  final double lat;
  final double lng;
  final double? speedKmh;
  final bool? ignition;
  final double? heading;
  final double? accelX;
  final double? accelY;
  final double? accelZ;
  final bool harshAcceleration;
  final bool harshBraking;
  final bool harshCornering;
  final double? batteryVoltage;
  final Map<String, dynamic>? extras;
  final DateTime createdAt;

  VehiculoTelemetria({
    required this.id,
    required this.vehiculoId,
    this.rentaId,
    required this.ts,
    required this.lat,
    required this.lng,
    this.speedKmh,
    this.ignition,
    this.heading,
    this.accelX,
    this.accelY,
    this.accelZ,
    this.harshAcceleration = false,
    this.harshBraking = false,
    this.harshCornering = false,
    this.batteryVoltage,
    this.extras,
    required this.createdAt,
  });
}
