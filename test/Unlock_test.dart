//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
import 'package:test/test.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:stack_trace/stack_trace.dart';

Future<MemcachedClientImpl> prepareBinaryClient() =>
    MemcachedClientImpl.connect([new SocketAddress('127.0.0.1', 11211)],
        factory: new BinaryConnectionFactory());

Future<MemcachedClientImpl> prepareTextClient() =>
    MemcachedClientImpl.connect([new SocketAddress('127.0.0.1', 11211)],
        factory: new TextConnectionFactory());

// locktime not expired, does not do unlock it and set a new value
//  and get shall throw error with KEY_EXIST.
testUnlock(String key, MemcachedClientImpl client) async {
  expect(await client.set(key, UTF8.encode('val100')), true);

  expect(
    () async {
      await client.getAndLock(key, 3); //lock 3 seconds
      await client.set(key, UTF8.encode('newVal100'));
    },
    throwsA(equals(OPStatus.KEY_EXISTS)),
  );

  var val = await client.get(key);
  expect(val.data, equals(UTF8.encode('val100')));
}

// locktime not expired, unlock it and set a new value
//  and get shall return the new value back
testUnlock2(String key, MemcachedClientImpl client) async {
  expect(await client.set(key, UTF8.encode('val100')), true);
  var val = await client.getAndLock(key, 3); //lock 3 seconds;
  expect(val.data, equals(UTF8.encode('val100')));
  expect(await client.set(key, UTF8.encode('newVal100')), true);
  await client.unlock(key, cas: val.cas);
  val = await client.get(key);
  expect(val.data, equals(UTF8.encode('newVal100')));
}

void main() {
  setupLogger();
//  group('TextUnlockTest:', () {
//    MemcachedClientImpl client;
//    setUp(() => prepareTextClient().then((c) => client = c));
//    tearDown(() => client.close());
//    test('TestUnlock', () => testUnlock('keyt1001', client));
//    test('TestUnlock2', () => testUnlock2('keyt1002', client));
//  });

  group('BinaryUnlockTest:', () {
    MemcachedClientImpl client;

    setUp(() async {
      client = await prepareBinaryClient();
    });

    tearDown(() => client.close());

    test('TestUnlock', () => testUnlock('keyb1001', client));
    test('TestUnlock2', () => testUnlock2('keyb1002', client));
  });
}
