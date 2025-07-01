class QRScanResult {
  final String data;
  final QRCodeType type;
  final DateTime timestamp;
  final String? title;
  final String? description;

  QRScanResult({
    required this.data,
    required this.type,
    required this.timestamp,
    this.title,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'description': description,
    };
  }

  factory QRScanResult.fromJson(Map<String, dynamic> json) {
    return QRScanResult(
      data: json['data'],
      type: QRCodeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QRCodeType.text,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      title: json['title'],
      description: json['description'],
    );
  }

  @override
  String toString() {
    return 'QRScanResult(data: $data, type: $type, timestamp: $timestamp)';
  }
}

enum QRCodeType {
  url,
  email,
  phone,
  sms,
  text,
  wifi,
  contact,
  location,
}

extension QRCodeTypeExtension on QRCodeType {
  String get displayName {
    switch (this) {
      case QRCodeType.url:
        return 'URL';
      case QRCodeType.email:
        return 'Email';
      case QRCodeType.phone:
        return 'Phone';
      case QRCodeType.sms:
        return 'SMS';
      case QRCodeType.text:
        return 'Text';
      case QRCodeType.wifi:
        return 'WiFi';
      case QRCodeType.contact:
        return 'Contact';
      case QRCodeType.location:
        return 'Location';
    }
  }

  String get icon {
    switch (this) {
      case QRCodeType.url:
        return '🌐';
      case QRCodeType.email:
        return '📧';
      case QRCodeType.phone:
        return '📞';
      case QRCodeType.sms:
        return '💬';
      case QRCodeType.text:
        return '📝';
      case QRCodeType.wifi:
        return '📶';
      case QRCodeType.contact:
        return '👤';
      case QRCodeType.location:
        return '📍';
    }
  }
}
