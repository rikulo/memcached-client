//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Feb 19, 2013  06:03:22 PM
// Author: henrichen

import 'dart:async';
import 'package:test/test.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

//Unconditonal set key0
testSaslMechs0(MemcachedClient client) async {
  expect(await client.listSaslMechs(), ['PLAIN']);
}

void main() {
  group('SaslMechsTest:', () {
    MemcachedClient client;
    setUp(() async {
      client = await m.prepareBinaryClient();
    });
    tearDown(() => client.close());
    test('TestSaslMechs0', () => testSaslMechs0(client));
  });
}
