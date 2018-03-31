//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
import 'package:test/test.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

void testTouch(MemcachedClient client) {
  expect(client.set('key100', UTF8.encode('val100')), completion(isTrue));
  Future f1 = client.get('key100')
    .then((val) {
      expect(val.data, equals(UTF8.encode('val100')));
      return client.touch('key100', 1); //expire in 1 seconds
    }).then((b) {
      expect(b, isTrue);
      return new Future.delayed(new Duration(seconds:2));
    }).then((_) {
      return client.get('key100');
    });

  expect(f1, throwsA(equals(OPStatus.KEY_NOT_FOUND)));
}

void main() {
  setupLogger();
  group('TextTouchTest:', () {
    MemcachedClient client;
    setUp(() => m.prepareTextClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestTouch', () => testTouch(client));
  });
  group('BinaryTouchTest:', () {
    MemcachedClient client;
    setUp(() => m.prepareBinaryClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestTouch', () => testTouch(client));
  });
}
