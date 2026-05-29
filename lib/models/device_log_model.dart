class DeviceLog {
  final int id;
  final String deviceName;
  final String deviceType;
  final String platform;
  final String browser;
  final String ipAddress;
  final String city;
  final String country;
  final String createdAt;
  final bool isCurrent;

  const DeviceLog({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.platform,
    required this.browser,
    required this.ipAddress,
    required this.city,
    required this.country,
    required this.createdAt,
    required this.isCurrent,
  });

  factory DeviceLog.fromJson(Map<String, dynamic> json) {
    return DeviceLog(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      deviceName: _clean(json['device_name'] ?? json['device'] ?? 'Unknown Device'),
      deviceType: _clean(json['device_type'] ?? 'Unknown'),
      platform: _clean(json['platform'] ?? 'Unknown OS'),
      browser: _clean(json['browser'] ?? json['app'] ?? ''),
      ipAddress: _clean(json['ip_address'] ?? ''),
      city: _clean(json['cityName'] ?? json['city'] ?? ''),
      country: _clean(json['countryName'] ?? json['country'] ?? ''),
      createdAt: _clean(json['created_at'] ?? json['login_at'] ?? ''),
      isCurrent: json['is_current'] == true ||
          json['is_current'] == 1 ||
          '${json['is_current']}' == '1',
    );
  }

  static String _clean(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') return '';
    return text;
  }
}