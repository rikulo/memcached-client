import 'dart:collection';
import 'package:memcached_client/memcached_client.dart';
import 'package:test/test.dart';

/**
 * Test the hash algorithms.
 */
void main() {
  test('testNativeHash', () => testNativeHash());
  test('testCrc32Hash', () => testCrc32Hash());
  test('testFNV164', () => testFNV164());
  test('testFNV1A64', () => testFNV1A64());
  test('testFNV132', () => testFNV132());
  test('testFNV1A32', () => testFNV1A32());
  test('testKetamaHash', () => testKetamaHash());
}

void assertHash(HashAlgorithm ha, String key, int exp) {
  expect(exp, greaterThan(0));
  expect(ha(key), equals(exp));
}

// I don't hardcode any values here because they're subject to change
void assertNativeHash(String key) {
  assertHash(NATIVE_HASH, key, key.hashCode.abs());
}

void testNativeHash() {
  for (String k in ["Test1", "Test2", "Test3", "Test4"]) {
    assertNativeHash(k);
  }
}

void testCrc32Hash() {
  Map<String, int> exp = new HashMap<String, int>();
  exp["Test1"] = 19315;
  exp["Test2"] = 21114;
  exp["Test3"] = 9597;
  exp["Test4"] = 15129;
  exp["UDATA:edevil@sapo.pt"] = 558;

  for (String key in exp.keys) {
    assertHash(CRC_HASH, key, exp[key]);
  }
}

void testFNV164() {
  Map<String, int> exp = new HashMap<String, int>();
  exp[""] = 0x84222325;
  exp[" "] = 0x8601b7ff;
  exp["hello world!"] = 0xb97b86bc;
  exp["Lorem ipsum dolor sit amet, consectetuer adipiscing elit."] =
      0xe87c054a;
  exp["wd:com.google"] = 0x071b08f8;
  exp["wd:com.google "] = 0x12f03d48;

  for (String key in exp.keys) {
    assertHash(FNV1_64_HASH, key, exp[key].abs());
  }
}

// Thanks much to pierre@demartines.com for this unit test.
void testFNV1A64() {
  HashMap<String, int> exp = new HashMap<String, int>();
  exp[""] = 0x84222325;
  exp[" "] = 0x8601817f;
  exp["hello world!"] = 0xcd5a2672;
  exp["Lorem ipsum dolor sit amet, consectetuer adipiscing elit."] =
      0xbec309a8;
  exp["wd:com.google"] = 0x097b3f26;
  exp["wd:com.google "] = 0x1c6c1732;

  for (String key in exp.keys) {
    assertHash(FNV1A_64_HASH, key, exp[key].abs());
  }
}

void testFNV132() {
  HashMap<String, int> exp = new HashMap<String, int>();
  exp[""] = 0x811c9dc5;
  exp[" "] = 0x050c5d3f;
  exp["hello world!"] = 0x8a01b99c;
  exp["Lorem ipsum dolor sit amet, consectetuer adipiscing elit."] =
      0x9277524a;
  exp["wd:com.google"] = 0x455e0df8;
  exp["wd:com.google "] = 0x2b0ffd48;

  for (String key in exp.keys) {
    assertHash(FNV1_32_HASH, key, exp[key].abs());
  }
}

void testFNV1A32() {
  HashMap<String, int> exp = new HashMap<String, int>();
  exp[""] = 0x811c9dc5;
  exp[" "] = 0x250c8f7f;
  exp["hello world!"] = 0xb034fff2;
  exp["Lorem ipsum dolor sit amet, consectetuer adipiscing elit."] =
      0xa9795ec8;
  exp["wd:com.google"] = 0xaa90fcc6;
  exp["wd:com.google "] = 0x683e1e12;

  for (String key in exp.keys) {
    assertHash(FNV1A_32_HASH, key, exp[key].abs());
  }
}

// These values came from libketama's test prog.
void testKetamaHash() {
  HashMap<String, int> exp = new HashMap<String, int>();
  exp["26"] = 3979113294;
  exp["1404"] = 2065000984;
  exp["4177"] = 1125759251;
  exp["9315"] = 3302915307;
  exp["14745"] = 2580083742;
  exp["105106"] = 3986458246;
  exp["355107"] = 3611074310;

  for (String key in exp.keys) {
    assertHash(KETAMA_HASH, key, exp[key].abs());
  }
}
