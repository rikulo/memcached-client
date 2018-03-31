//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, May 23, 2013  03:41:04 PM
// Author: henrichen

import 'dart:async';
import 'package:test/test.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

//Stats should always succeed
testStats(MemcachedClient client) async {
  var map = await client.stats();
  print("$map");
  expect(map.keys.first, equals(new SocketAddress('127.0.0.1', 11211)));
  expect(map, new isInstanceOf<Map<SocketAddress, String>>());
}

//Check stats with prefix
testStats2(MemcachedClient client) async {
  var map = await client.stats(prefix: "proxy");
  print("$map");
  expect(map.keys.first, equals(new SocketAddress('127.0.0.1', 11211)));
  expect(map, new isInstanceOf<Map<SocketAddress, String>>());
}

void main() {
  setupLogger();
  group('TextStatsTest:', () {
    MemcachedClient client;
    setUp(() async {
      client = await m.prepareTextClient();
    });
    tearDown(() => client.close());
    test('TestStats', () => testStats(client));
//    test('TestStats2', () => testStats2(client));
//TODO(20130523, henrichen): Couchbase seems not support this? stats with argument
  });

  group('BinaryStatsTest:', () {
    MemcachedClient client;
    setUp(() async {
      client = await m.prepareBinaryClient();
    });
    tearDown(() => client.close());
    test('TestStats', () => testStats(client));
//    test('TestStats2', () => testStats2(client));
//TODO(20130523, henrichen): Couchbase seems not support this? stats with argument
  });
}
