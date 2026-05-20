class LocationModel {
  final String address;
  final double latitude;
  final double longitude;
  final String? placeName;
  final String? placeType;

  LocationModel({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.placeType,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeName': placeName,
      'placeType': placeType,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      address: map['address'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      placeName: map['placeName'],
      placeType: map['placeType'],
    );
  }

  @override
  String toString() => address;
}
