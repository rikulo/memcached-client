//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Feb 19, 2013  06:03:22 PM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
import 'package:test/test.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

//Unconditonal set key0
void testSet1(MemcachedClient client) {
  expect(client.set('key0', UTF8.encode('val0')), completion(isTrue));

  Future f1 = client.get('key0');
  f1.then((v) => expect(UTF8.decode(v.data), equals('val0')));
  expect(f1, completes);
}

//Unconditional set no matter key0 exists or not
void testSet2(MemcachedClient client) {
  expect(client.set('key0', UTF8.encode('val1')), completion(isTrue));
  Future f1 = client.get('key0');
  f1.then((v) => expect(UTF8.decode(v.data), equals('val1')));
  expect(f1, completes);
}

//unconditional set Chinese text
void testSet3(MemcachedClient client) {
  expect(client.set('key0', UTF8.encode('中文')), completion(isTrue));
  Future f1 = client.get('key0');
  f1.then((v) => expect(UTF8.decode(v.data), equals('中文')));
  expect(f1, completes);
}

//cas with Chinese text
void testCas(MemcachedClient client) {
  Future f1 = client.gets('key0');
  f1.then((v) {
    expect(UTF8.decode(v.data), equals('中文'));
    expect(v.cas, isNotNull);
    expect(client.set('key0', UTF8.encode('val0'), cas:v.cas), completion(isTrue));
  });
  expect(f1, completes);
}

//key0 exist, cannot be added
void testAdd1(MemcachedClient client) {
  expect(client.set('key0', UTF8.encode('val0')), completion(isTrue));
  expect(client.add('key0', UTF8.encode('val0')), throwsA(equals(OPStatus.KEY_EXISTS)));
}

//key1 not exist, can be added
void testAdd2(MemcachedClient client) {
  expect(client.set('key1', UTF8.encode('val1')), completion(isTrue));
  //delete key1 to ensure Add will succeed
  expect(client.delete('key1'), completes);

  expect(client.add('key1', UTF8.encode('val1')), completion(isTrue));

  Future f1 = client.get('key1');
  f1.then((v) => expect(UTF8.decode(v.data), equals('val1')));
  expect(f1, completes);

  //delete key1 to ensure prepend2/append2 will fail
  expect(client.delete('key1'), completes);
}

//key0 exist, can be replaced (val1 -> val0)
void testReplace1(MemcachedClient client) {
  expect(client.replace('key0', UTF8.encode('val0')), completion(isTrue));
  Future f1 = client.get('key0');
  f1.then((v) => expect(UTF8.decode(v.data), equals('val0')));
  expect(f1, completes);
}

//key1 not exist, cannot replace
void testReplace2(MemcachedClient client) {
  expect(client.replace('key1', UTF8.encode('val0')), throwsA(equals(OPStatus.KEY_NOT_FOUND)));
}

//key0 exist, can be prepend (val0 -> pre0val0)
void testPrepend1(MemcachedClient client) {
  expect(client.prepend('key0', UTF8.encode('pre0')), completion(isTrue));
  Future f1 = client.get('key0');
  f1.then((v) => expect(UTF8.decode(v.data), equals('pre0val0')));
  expect(f1, completes);
}

//key1 not exist, cannot prepend
void testPrepend2(MemcachedClient client) {
  expect(client.prepend('key1', UTF8.encode('pre0')), throwsA(equals(OPStatus.ITEM_NOT_STORED)));
}

//key0 exist, can be append (pre0val0 -> pre0val0app0)
void testAppend1(MemcachedClient client) {
  expect(client.append('key0', UTF8.encode('app0')), completion(isTrue));
  Future f1 = client.get('key0');
  f1.then((v) => expect(UTF8.decode(v.data), equals('pre0val0app0')));
  expect(f1, completes);
}

//key1 not exist, cannot append
void testAppend2(MemcachedClient client) {
  expect(client.append('key1', UTF8.encode('pre0')), throwsA(equals(OPStatus.ITEM_NOT_STORED)));
}

void main() {
  setupLogger();
  group('TextStoreTest:', () {
    MemcachedClient client;
    setUp(() => m.prepareTextClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestSet1', () => testSet1(client));
    test('TestSet2', () => testSet2(client));
    test('TestSet3', () => testSet3(client));
    test('TestCas', () => testCas(client));
    test('TestAdd1', () => testAdd1(client));
    test('TestAdd2', () => testAdd2(client));
    test('TestReplace1', () => testReplace1(client));
    test('TestReplace2', () => testReplace2(client));
    test('TestPrepend1', () => testPrepend1(client));
    test('TestPrepend2', () => testPrepend2(client));
    test('TestAppend1', () => testAppend1(client));
    test('TestAppend2', () => testAppend2(client));
  });

  group('BinaryStoreTest:', () {
    MemcachedClient client;
    setUp(() => m.prepareBinaryClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestSet1', () => testSet1(client));
    test('TestSet2', () => testSet2(client));
    test('TestSet3', () => testSet3(client));
    test('TestCas', () => testCas(client));
    test('TestAdd1', () => testAdd1(client));
    test('TestAdd2', () => testAdd2(client));
    test('TestReplace1', () => testReplace1(client));
    test('TestReplace2', () => testReplace2(client));
    test('TestPrepend1', () => testPrepend1(client));
    test('TestPrepend2', () => testPrepend2(client));
    test('TestAppend1', () => testAppend1(client));
    test('TestAppend2', () => testAppend2(client));
  });
}