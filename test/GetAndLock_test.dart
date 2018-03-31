//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
import 'package:test/test.dart';
import 'package:memcached_client/memcached_client.dart';

Future<MemcachedClientImpl> prepareBinaryClient() =>
    MemcachedClientImpl.connect([new SocketAddress('localhost', 11211)],
        factory: new BinaryConnectionFactory());

Future<MemcachedClientImpl> prepareTextClient() =>
    MemcachedClientImpl.connect([new SocketAddress('localhost', 11211)],
        factory: new TextConnectionFactory());

void testGetAndLock(String key, MemcachedClientImpl client) {
  expect(client.set(key, UTF8.encode('val100')), completion(isTrue));
  Future f1 = client.getAndLock(key, 1) //lock for 1 seconds
      .then((val) {
    expect(val.data, equals(UTF8.encode('val100')));
    return new Future.delayed(new Duration(seconds: 2)); //wait 2 seconds
  }).then((_) {
    return client.set(key, UTF8.encode('newVal100'));
  }).then((_) {
    return client.get(key);
  }).then((val) {
    expect(val.data, equals(UTF8.encode('newVal100')));
  });

  expect(f1, completes);
}

// locktime not expired, set shall complain KEY_EXIST
//  and get shall return the original value back
void testGetAndLock2(String key, MemcachedClientImpl client) {
  expect(client.set(key, UTF8.encode('val100')), completion(isTrue));
  Future f1 = client.getAndLock(key, 3) //lock 3 seconds
      .then((val) {
    expect(val.data, equals(UTF8.encode('val100')));
    return new Future.delayed(new Duration(seconds: 2)); //wait for 2 seconds
  }).then((_) {
    return client.set(key, UTF8.encode('newVal100'));
  });

  expect(f1, throwsA(equals(OPStatus.KEY_EXISTS)));

  Future f2 = client.get(key).then((val) {
    expect(val.data, equals(UTF8.encode('val100')));
  });

  expect(f2, completes);
}

void main() {
  setupLogger();
  group('TextGetAndLockTest:', () {
    MemcachedClientImpl client;

    setUp(() async {
      client = await prepareBinaryClient();
    });

    tearDown(() => client.close());
    test('TestGetAndLock', () => testGetAndLock('keyt100', client));
    test('TestGetAndLock2', () => testGetAndLock2('keyt100', client));
  });

  group('BinaryGetAndLockTest:', () {
    MemcachedClientImpl client;

    setUp(() async {
      client = await prepareBinaryClient();
    });

    tearDown(() => client.close());
    test('TestGetAndLock', () => testGetAndLock('keyb100', client));
    test('TestGetAndLock2', () => testGetAndLock2('keyb100', client));
  });
}
