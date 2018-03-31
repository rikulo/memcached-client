//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 20, 2013  10:19:03 AM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
import 'package:test/test.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

//get a key
void testGet1(MemcachedClient client) {
  expect(client.set('key0', UTF8.encode('"val0"')), completion(isTrue));

  Future f1 = client.get('key0');
  f1.then((v) {
    expect(UTF8.decode(v.data), equals('"val0"'));
    expect(v.cas, isNull);
  });
  expect(f1, completes);
}

//get an inexisting key
void testGet2(MemcachedClient client) {
  expect(client.get('key101'), throwsA(equals(OPStatus.KEY_NOT_FOUND)));
}

//get multiple key
void testGetAll(MemcachedClient client) {
  int count = 2;
  for (int j = 0; j < count; ++j) {
    expect(client.set('key$j', UTF8.encode('val$j')), completion(isTrue));
  }

  List<String> keys = new List();
  for (int j = 0; j < count; ++j) {
    keys.add('key$j');
  }

  Stream s1 = client.getAll(keys);
  Future<List<GetResult>> f1 = s1.toList();

  f1.then((List<GetResult> grs) {
    int j = 0;
    grs.forEach((GetResult gr) {
      expect(gr.key, equals('key$j'));
      expect(UTF8.decode(gr.data), equals('val$j'));
      expect(gr.cas, isNull);
      ++j;
    });
  });

  expect(f1, completes);
}

//gets a key; sould return with cas token.
void testGets1(MemcachedClient client) {
  expect(client.set('key0', UTF8.encode('val0')), completion(isTrue));

  Future f1 = client.gets('key0');
  f1.then((v) {
    expect(UTF8.decode(v.data), equals('val0'));
    expect(v.cas, isNotNull);
  });
  expect(f1, completes);
}

//gets an inexisting key
void testGets2(MemcachedClient client) {
  expect(client.gets('key101'), throwsA(equals(OPStatus.KEY_NOT_FOUND)));
}

//gets multiple key; should return with cas tokens.
void testGetsAll(MemcachedClient client) {
  int count = 20;
  for (int j = 0; j < count; ++j) {
    expect(client.set('key$j', UTF8.encode('val$j')), completion(isTrue));
  }

  List<String> keys = new List();
  for (int j = 0; j < count; ++j) {
    keys.add('key$j');
  }

  Stream s1 = client.getsAll(keys);
  Future<List<GetResult>> f1 = s1.toList();

  f1.then((List<GetResult> grs) {
    int j = 0;
    grs.forEach((GetResult gr) {
      expect(gr.key, equals('key$j'));
      expect(UTF8.decode(gr.data), equals('val$j'));
      expect(gr.cas, isNotNull);
      ++j;
    });
  });

  expect(f1, completes);
}

void main() {
  setupLogger();

  group('TextRetrieveTest:', () {
    MemcachedClient client;
    setUp(() async {
      client = await m.prepareTextClient();
    });
    tearDown(() => client.close());
    test('TestGet1', () => testGet1(client));
    test('TestGet2', () => testGet2(client));
    test('TestGetAll', () => testGetAll(client));
    test('TestGets1', () => testGets1(client));
    test('TestGets2', () => testGets2(client));
    test('TestGetsAll', () => testGetsAll(client));
  });

  group('BinaryRetrieveTest:', () {
    MemcachedClient client;
    setUp(() async {
      client = await m.prepareBinaryClient();
    });
    tearDown(() => client.close());
    test('TestGet1', () => testGet1(client));
    test('TestGet2', () => testGet2(client));
    test('TestGetAll', () => testGetAll(client));
    test('TestGets1', () => testGets1(client));
    test('TestGets2', () => testGets2(client));
    test('TestGetsAll', () => testGetsAll(client));
  });
}
