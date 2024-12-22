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

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1: json['line1'] as String? ?? '',
      line2: json['line2'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postcode: json['postcode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'line1': line1,
    'line2': line2,
    'city': city,
    'postcode': postcode,
  };
} 