class WasteLog {
  final String wasteType;
  final String location;
  final DateTime timestamp;

  WasteLog({
    required this.wasteType,
    required this.location,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'wasteType': wasteType,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WasteLog.fromJson(Map<String, dynamic> json) {
    return WasteLog(
      wasteType: json['wasteType'],
      location: json['location'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}