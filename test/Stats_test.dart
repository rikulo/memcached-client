//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, May 23, 2013  03:41:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

//Stats should always succeed
void testStats(MemcachedClient client) {
  Future<Map<SocketAddress, String>> f = client.stats()
      .then((map) {
        print("$map");
        expect(map.keys.first, equals(new SocketAddress('127.0.0.1', 11211)));
        return map;
      });
  expect(f, completion(new isInstanceOf<Map<SocketAddress, String>>()));
}

//Check stats with prefix
void testStats2(MemcachedClient client) {
  Future<Map<SocketAddress, String>> f =
    client.stats("proxy")
      .then((map) {
        print("$map");
        expect(map.keys.first, equals(new SocketAddress('127.0.0.1', 11211)));
        return map;
      });
  expect(f, completion(new isInstanceOf<Map<SocketAddress, String>>()));
}

void main() {
  setupLogger();
  group('TextStatsTest:', () {
    MemcachedClient client;
    setUp(() => m.prepareTextClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestStats', () => testStats(client));
//    test('TestStats2', () => testStats2(client));
//TODO(20130523, henrichen): Couchbase seems not support this? stats with argument
  });

  group('BinaryStatsTest:', () {
    MemcachedClient client;
    setUp(() => m.prepareBinaryClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestStats', () => testStats(client));
//    test('TestStats2', () => testStats2(client));
//TODO(20130523, henrichen): Couchbase seems not support this? stats with argument
  });
}
