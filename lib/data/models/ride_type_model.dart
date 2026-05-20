class RideTypeModel {
  final String id;
  final String name;
  final String icon;
  final double pricePerKm;
  final double baseFare;
  final int capacity;
  final String description;
  final String color;

  RideTypeModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.pricePerKm,
    required this.baseFare,
    required this.capacity,
    required this.description,
    required this.color,
  });
}

// Predefined ride types
final rideTypes = [
  RideTypeModel(
    id: 'economy',
    name: 'Economy',
    icon: '🚗',
    pricePerKm: 0.50,
    baseFare: 2.00,
    capacity: 4,
    description: 'Budget-friendly option',
    color: '0xFF00D4FF',
  ),
  RideTypeModel(
    id: 'comfort',
    name: 'Comfort',
    icon: '🚙',
    pricePerKm: 0.75,
    baseFare: 3.00,
    capacity: 4,
    description: 'More comfortable ride',
    color: '0xFF007A5E',
  ),
  RideTypeModel(
    id: 'premium',
    name: 'Premium',
    icon: '🚘',
    pricePerKm: 1.00,
    baseFare: 4.00,
    capacity: 4,
    description: 'Premium experience',
    color: '0xFFCEA946',
  ),
  RideTypeModel(
    id: 'xl',
    name: 'XL',
    icon: '🚐',
    pricePerKm: 1.25,
    baseFare: 5.00,
    capacity: 6,
    description: 'For groups & luggage',
    color: '0xFFFF6B6B',
  ),
];
