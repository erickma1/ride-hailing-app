class UserModel {
  final String uid;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profileImageUrl;
  final double? rating;
  final int? totalRides;
  final bool? isDriver;
  final bool? isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.email,
    this.profileImageUrl,
    this.rating,
    this.totalRides,
    this.isDriver,
    this.isVerified,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'totalRides': totalRides,
      'isDriver': isDriver ?? false,
      'isVerified': isVerified ?? false,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      rating: map['rating']?.toDouble(),
      totalRides: map['totalRides'],
      isDriver: map['isDriver'] ?? false,
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] ?? DateTime.now(),
      updatedAt: map['updatedAt'],
    );
  }

  String get fullName => '\$firstName \$lastName';

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
    String? profileImageUrl,
    double? rating,
    int? totalRides,
    bool? isDriver,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      isDriver: isDriver ?? this.isDriver,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
