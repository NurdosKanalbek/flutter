import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';

void main() {
  const sampleUserJson = r'''{
    "id": 1,
    "name": "Leanne Graham",
    "username": "Bret",
    "email": "Sincere@april.biz",
    "address": {
      "street": "Kulas Light",
      "suite": "Apt. 556",
      "city": "Gwenborough",
      "zipcode": "92998-3874",
      "geo": {
        "lat": "-37.3159",
        "lng": "81.1496"
      }
    },
    "phone": "1-770-736-8031 x56442",
    "website": "hildegard.org",
    "company": {
      "name": "Romaguera-Crona",
      "catchPhrase": "Multi-layered client-server neural-net",
      "bs": "harness real-time e-markets"
    }
  }''';

  group('Level 2: User Model & Serialization', () {
    test(
      'fromJson parses full user with defended casts and nested objects',
      () {
        final map = jsonDecode(sampleUserJson) as Map<String, dynamic>;
        final user = User.fromJson(map);

        expect(user.id, 1);
        expect(user.name, 'Leanne Graham');
        expect(user.username, 'Bret');
        expect(user.email, 'Sincere@april.biz');
        expect(user.phone, '1-770-736-8031 x56442');
        expect(user.phoneDigits, '1770736803156442');
        expect(user.website, 'hildegard.org');

        expect(user.address.street, 'Kulas Light');
        expect(user.address.suite, 'Apt. 556');
        expect(user.address.city, 'Gwenborough');
        expect(user.address.zipcode, '92998-3874');
        expect(user.address.geo.lat, -37.3159);
        expect(user.address.geo.lng, 81.1496);

        expect(user.company.name, 'Romaguera-Crona');
        expect(
          user.company.catchPhrase,
          'Multi-layered client-server neural-net',
        );
      },
    );

    test('phoneDigits strips everything but digits and +', () {
      const user = User(
        id: 2,
        name: 'Ervin',
        username: 'ervin',
        email: 'ervin@example.com',
        phone: '010-692-6593 x09125',
        address: Address(
          street: 'Victor Plains',
          suite: 'Suite 879',
          city: 'Wisokyburgh',
          zipcode: '90566-7771',
          geo: Geo(lat: -43.9509, lng: -34.4618),
        ),
        company: (
          name: 'Deckow-Crist',
          catchPhrase: 'Proactive didactic contingency',
        ),
      );
      expect(user.phoneDigits, '010692659309125');
    });

    test('round-trip toJson -> fromJson preserves equality and values', () {
      final map = jsonDecode(sampleUserJson) as Map<String, dynamic>;
      final original = User.fromJson(map);
      final encoded = original.toJson();
      final decoded = User.fromJson(encoded);

      expect(decoded, equals(original));
      expect(decoded.id, original.id);
      expect(decoded.name, original.name);
      expect(decoded.address.geo.lat, original.address.geo.lat);
      expect(decoded.address.geo.lng, original.address.geo.lng);
      expect(decoded.company.name, original.company.name);
    });

    test(
      'throws TypeError when lat is cast directly as double instead of parsed',
      () {
        final map = jsonDecode(sampleUserJson) as Map<String, dynamic>;
        final geoMap =
            (map['address'] as Map<String, dynamic>)['geo']
                as Map<String, dynamic>;

        expect(() => geoMap['lat'] as double, throwsA(isA<TypeError>()));
      },
    );

    test('throws TypeError when id in json is string instead of int', () {
      final map = jsonDecode(sampleUserJson) as Map<String, dynamic>;
      map['id'] = '1';

      expect(() => User.fromJson(map), throwsA(isA<TypeError>()));
    });
  });

  group('Level 3: ApiException Hierarchy', () {
    test('all exceptions inherit from sealed ApiException', () {
      const e1 = NoConnectionException();
      const e2 = ServerException(500);
      const e3 = NotFoundException();
      const e4 = UnauthorizedException();
      const e5 = BadResponseException('invalid syntax');

      expect(e1, isA<ApiException>());
      expect(e2, isA<ApiException>());
      expect(e3, isA<ApiException>());
      expect(e4, isA<ApiException>());
      expect(e5, isA<ApiException>());
      expect(e2.status, 500);
      expect(e5.detail, 'invalid syntax');
    });
  });
}
