class RideModel {
  final String rideId;
  final String passengerId;
  final String? driverId;
  final String pickupLocation;
  final String dropoffLocation;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final double? fare;
  final String currency;
  final String status;
  final String? rideType;
  final DateTime createdAt;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? passengerRating;
  final double? driverRating;
  final String? passengerComment;
  final String? driverComment;
  final double? distance;
  final int? duration;

  RideModel({
    required this.rideId,
    required this.passengerId,
    this.driverId,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.fare,
    this.currency = 'GHS',
    required this.status,
    this.rideType,
    required this.createdAt,
    this.startTime,
    this.endTime,
    this.passengerRating,
    this.driverRating,
    this.passengerComment,
    this.driverComment,
    this.distance,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'passengerId': passengerId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'fare': fare,
      'currency': currency,
      'status': status,
      'rideType': rideType,
      'createdAt': createdAt,
      'startTime': startTime,
      'endTime': endTime,
      'passengerRating': passengerRating,
      'driverRating': driverRating,
      'passengerComment': passengerComment,
      'driverComment': driverComment,
      'distance': distance,
      'duration': duration,
    };
  }

  factory RideModel.fromMap(Map<String, dynamic> map) {
    return RideModel(
      rideId: map['rideId'] ?? '',
      passengerId: map['passengerId'] ?? '',
      driverId: map['driverId'],
      pickupLocation: map['pickupLocation'] ?? '',
      dropoffLocation: map['dropoffLocation'] ?? '',
      pickupLat: map['pickupLat']?.toDouble(),
      pickupLng: map['pickupLng']?.toDouble(),
      dropoffLat: map['dropoffLat']?.toDouble(),
      dropoffLng: map['dropoffLng']?.toDouble(),
      fare: map['fare']?.toDouble(),
      currency: map['currency'] ?? 'GHS',
      status: map['status'] ?? 'requested',
      rideType: map['rideType'],
      createdAt: map['createdAt'] ?? DateTime.now(),
      startTime: map['startTime'],
      endTime: map['endTime'],
      passengerRating: map['passengerRating']?.toDouble(),
      driverRating: map['driverRating']?.toDouble(),
      passengerComment: map['passengerComment'],
      driverComment: map['driverComment'],
      distance: map['distance']?.toDouble(),
      duration: map['duration'],
    );
  }

  RideModel copyWith({
    String? rideId,
    String? passengerId,
    String? driverId,
    String? pickupLocation,
    String? dropoffLocation,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    double? fare,
    String? currency,
    String? status,
    String? rideType,
    DateTime? createdAt,
    DateTime? startTime,
    DateTime? endTime,
    double? passengerRating,
    double? driverRating,
    String? passengerComment,
    String? driverComment,
    double? distance,
    int? duration,
  }) {
    return RideModel(
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      fare: fare ?? this.fare,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      rideType: rideType ?? this.rideType,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      passengerRating: passengerRating ?? this.passengerRating,
      driverRating: driverRating ?? this.driverRating,
      passengerComment: passengerComment ?? this.passengerComment,
      driverComment: driverComment ?? this.driverComment,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
    );
  }
}
