//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Feb 19, 2013  06:03:22 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'dart:typed_data';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

//Unconditonal set key0
void testSaslMechs0(MemcachedClient client) {
  Future f1 = client.listSaslMechs();
  expect(f1, completion(equals(['PLAIN'])));
}

void main() {
  group('SaslMechsTest:', () {
    MemcachedClient client;
    setUp(() => m.prepareBinaryClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestSaslMechs0', () => testSaslMechs0(client));
  });
}