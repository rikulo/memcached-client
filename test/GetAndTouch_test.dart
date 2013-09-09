//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

void testGetAndTouch(MemcachedClient client) {
  expect(client.set('key100', UTF8.encode('val100')), completion(isTrue));
  Future f1 = client.getAndTouch('key100', 1) //expire in 1 seconds
    .then((val) {
      expect(val.data, equals(UTF8.encode('val100')));
      return new Future.delayed(new Duration(seconds:2));
    }).then((_) {
      return client.get('key100');
    });

  expect(f1, throwsA(equals(OPStatus.KEY_NOT_FOUND)));
}

//Not expired, so shall get the value back
void testGetAndTouch2(MemcachedClient client) {
  expect(client.set('key100', UTF8.encode('val100')), completion(isTrue));
  Future f1 = client.getAndTouch('key100', 3) //expire in 3 seconds
    .then((val) {
      expect(val.data, equals(UTF8.encode('val100')));
      return new Future.delayed(new Duration(seconds:2));
    }).then((_) {
      return client.get('key100');
    })
    .then((val) {
      expect(val.data, equals(UTF8.encode('val100')));
    });

  expect(f1, completes);
}

void main() {
  setupLogger();
//TODO(20130520, henrichen): Text protocol does not support get-and-touch
//  group('TextGetAndTouchTest:', () {
//    MemcachedClient client;
//    setUp(() => m.prepareTextClient().then((c) => client = c));
//    tearDown(() => client.close());
//    test('TestGetAndTouch', () => testGetAndTouch(client));
//  });
  group('BinaryGetAndTouchTest:', () {
    MemcachedClient client;
    setUp(() => m.prepareBinaryClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetAndTouch', () => testGetAndTouch(client));
    test('TestGetAndTouch2', () => testGetAndTouch2(client));
  });
}
