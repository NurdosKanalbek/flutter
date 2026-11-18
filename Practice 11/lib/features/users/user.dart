class Geo {
  const Geo({required this.lat, required this.lng});

  final double lat;
  final double lng;

  factory Geo.fromJson(Map<String, dynamic> json) {
    return Geo(
      lat: double.parse(json['lat'] as String),
      lng: double.parse(json['lng'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat.toString(),
    'lng': lng.toString(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Geo &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'Geo(lat: $lat, lng: $lng)';
}

class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String,
      suite: json['suite'] as String,
      city: json['city'] as String,
      zipcode: json['zipcode'] as String,
      geo: Geo.fromJson(json['geo'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'street': street,
    'suite': suite,
    'city': city,
    'zipcode': zipcode,
    'geo': geo.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          street == other.street &&
          suite == other.suite &&
          city == other.city &&
          zipcode == other.zipcode &&
          geo == other.geo;

  @override
  int get hashCode => Object.hash(street, suite, city, zipcode, geo);

  @override
  String toString() => 'Address(street: $street, city: $city, geo: $geo)';
}

typedef Company = ({String name, String catchPhrase});

class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    this.website,
    required this.address,
    required this.company,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String? website;
  final Address address;
  final Company company;

  String get phoneDigits => phone.replaceAll(RegExp(r'[^0-9+]'), '');

  factory User.fromJson(Map<String, dynamic> json) {
    final companyJson = json['company'] as Map<String, dynamic>;
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String?,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      company: (
        name: companyJson['name'] as String,
        catchPhrase: companyJson['catchPhrase'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'phone': phone,
    'website': website,
    'address': address.toJson(),
    'company': {'name': company.name, 'catchPhrase': company.catchPhrase},
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, name: $name, username: $username)';
}
