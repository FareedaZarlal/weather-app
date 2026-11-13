class Location {
  final String id;
  final String name;
  final String? region;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;

  const Location({
    required this.id,
    required this.name,
    this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  static const defaultLocation = Location(
    id: '43.6532,-79.3832',
    name: 'Toronto',
    region: 'Ontario',
    country: 'Canada',
    latitude: 43.6532,
    longitude: -79.3832,
    timezone: 'America/Toronto',
  );

  String get subtitle =>
      [region, country].where((e) => e != null && e.isNotEmpty).join(', ');

  Location copyWith({String? timezone}) => Location(
    id: id,
    name: name,
    region: region,
    country: country,
    latitude: latitude,
    longitude: longitude,
    timezone: timezone ?? this.timezone,
  );

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    id: json['id'] as String,
    name: json['name'] as String,
    region: json['region'] as String?,
    country: (json['country'] as String?) ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    timezone: (json['timezone'] as String?) ?? 'UTC',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'region': region,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'timezone': timezone,
  };
}
