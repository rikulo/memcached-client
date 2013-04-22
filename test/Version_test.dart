//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

//version should always succeed
void testVersion(MemcachedClient client) {
  expect(client.versions(), completion(new isInstanceOf<Map<SocketAddress, String>>()));
}

void main() {
  group('TextVersionTest:', () {
    MemcachedClient client;
    setUp(() => m.prepareTextClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestVersion', () => testVersion(client));
  });

  group('BinaryVersionTest:', () {
    MemcachedClient client;
    setUp(() => m.prepareBinaryClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestVersion', () => testVersion(client));
  });
}
