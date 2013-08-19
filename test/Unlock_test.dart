//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';

Future<MemcachedClientImpl> prepareBinaryClient()
=> MemcachedClientImpl.connect([new SocketAddress('127.0.0.1', 11211)],
      factory: new BinaryConnectionFactory());

Future<MemcachedClientImpl> prepareTextClient()
=> MemcachedClientImpl.connect([new SocketAddress('127.0.0.1', 11211)],
      factory: new TextConnectionFactory());

// locktime not expired, does not do unlock it and set a new value
//  and get shall throw error with KEY_EXIST.
void testUnlock(String key, MemcachedClientImpl client) {
  expect(client.set(key, encodeUtf8('val100')), completion(isTrue));
  Future f1 = client.getAndLock(key, 3) //lock 3 seconds
    .then((val) {
      expect(val.data, equals(encodeUtf8('val100')));
      //return client.unlock(key, val.cas);
    }).then((_) {
      return client.set(key, encodeUtf8('newVal100'));
    });

  expect(f1, throwsA(equals(OPStatus.KEY_EXISTS)));

  Future f2 = client.get(key)
    .then((val) {
      expect(val.data, equals(encodeUtf8('val100')));
    });

  expect(f2, completes);
}

// locktime not expired, unlock it and set a new value
//  and get shall return the new value back
void testUnlock2(String key, MemcachedClientImpl client) {
  expect(client.set(key, encodeUtf8('val100')), completion(isTrue));
  Future f1 = client.getAndLock(key, 3) //lock 3 seconds
    .then((val) {
      expect(val.data, equals(encodeUtf8('val100')));
      return client.unlock(key, cas: val.cas);
    }).then((_) {
      expect(client.set(key, encodeUtf8('newVal100')), completion(isTrue));
      return client.get(key);
    }).then((val) {
      expect(val.data, equals(encodeUtf8('newVal100')));
    });

  expect(f1, completes);
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
    setUp(() => prepareBinaryClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestUnlock', () => testUnlock('keyb1001', client));
    test('TestUnlock2', () => testUnlock2('keyb1002', client));
  });
}
