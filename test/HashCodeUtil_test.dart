import 'dart:collection';
import 'package:test/test.dart';
import 'package:memcached_client/memcached_client.dart';

/**
 * Test the hash algorithms.
 */
void main() {
  test('testUriHashCode', () => testUriHashCode());
  test('testMapHashCode', () => testMapHashCode());
  test('testListHashCode', () => testListHashCode());
  test('testNullHashCode', () => testNullHashCode());
  test('testStringHashCode', () => testStringHashCode());
}

void testMapHashCode() {
  Map map1 = new HashMap();
  map1[0] = 'a';
  map1[1] = 'b';
  map1[2] = 'c';
  Map map2 = new HashMap.from(map1);
  expect(mapHashCode(map1), equals(mapHashCode(map2)));
  expect(mapHashCode(map1), equals(969175863));
  expect(mapHashCode(map2), equals(969175863));
  expect(mapEquals(map1, map2), isTrue);
  expect(identical(map1, map2), isFalse);
}

void testListHashCode() {
  List list1 = new List();
  list1.add('a');
  list1.add('b');
  list1.add('c');
  List list2 = new List.from(list1);
  expect(listHashCode(list1), equals(listHashCode(list2)));
  expect(listEquals(list1, list2), isTrue);
  expect(identical(list1, list2), isFalse);
}

void testNullHashCode() {
  var a;
  expect(a.hashCode, equals(null.hashCode));
  expect(null.hashCode, equals(2011));
}

void testStringHashCode() {
  final str = "abc";
  expect(str.hashCode, equals('abc'.hashCode));
  expect('abc'.hashCode, equals(756227931));
}

void testUriHashCode() {
  final uri1 = Uri.parse("http://10.1.3.118:11210");
  final uri2 = Uri.parse("http://10.1.3.118:11210");

  expect(uri1, equals(uri2));
}
