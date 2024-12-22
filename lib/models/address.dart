class Address {
  final String line1;
  final String line2;
  final String city;
  final String postcode;

  Address({
    required this.line1,
    required this.line2,
    required this.city,
    required this.postcode,
  });

  factory Address.fromJson(dynamic json) {
    return Address(
      line1: json['line1'] ?? '',
      line2: json['line2'] ?? '',
      city: json['city'] ?? '',
      postcode: json['postcode'] ?? '',
    );
  }
} 