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
    print('Creating Address from JSON: $json'); // Debug log
    return Address(
      line1: json['line1']?.toString() ?? '',
      line2: json['line2']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      postcode: json['postcode']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Address(line1: $line1, line2: $line2, city: $city, postcode: $postcode)';
  }
} 