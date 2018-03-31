//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'package:test/test.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

//version should always succeed
void testNoOP(MemcachedClientImpl client) {
  Future<Map<SocketAddress, bool>> f = client.handleBroadcastOperation(
      () => client.opFactory.newNoOP(), client.locator.allNodes.iterator);

  f.then((map) {
    print("$map");
    expect(map.keys.first, equals(new SocketAddress('127.0.0.1', 11211)));
    return map;
  });
  expect(f, completion(new isInstanceOf<Map<SocketAddress, bool>>()));
}

void main() {
  group('TextNoOPTest:', () {
    MemcachedClient client;
    setUp(() async {
      client = await m.prepareTextClient();
    });
    tearDown(() => client.close());
    test('TestNoOP', () => testNoOP(client));
  });

  group('BinaryNoOPTest:', () {
    MemcachedClient client;
    setUp(() async {
      client = await m.prepareBinaryClient();
    });
    tearDown(() => client.close());
    test('TestNoOP', () => testNoOP(client));
  });
}
