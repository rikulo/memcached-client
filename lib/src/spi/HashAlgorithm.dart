//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:55:10 PM
// Author: hernichen

part of memcached_client;

typedef int HashAlgorithm(String key);

final int FNV_64_INIT = 0xcbf29ce484222325;
final int FNV_64_PRIME = 0x100000001b3;
final int FNV_32_INIT = 2166136261;
final int FNV_32_PRIME = 16777619;
Hash md5Digest = null;

//key.hashCode
final HashAlgorithm NATIVE_HASH =
    (String key) => key.hashCode & 0xffffffff;

//(crc32(shift) >> 16) & 0x7fff;
final HashAlgorithm CRC_HASH =
    (String key) => (_crc32(UTF8.encode(key)) >> 16) & 0x7fff;

final HashAlgorithm FNV1_64_HASH =
    (String key) {
      int len = key.length;
      int rv = FNV_64_INIT;
      for(int code in key.codeUnits) {
        rv *= FNV_64_PRIME;
        rv ^= code;
      }
      return rv & 0xffffffff;
    };

final HashAlgorithm FNV1A_64_HASH =
    (String key) {
      int len = key.length;
      int rv = FNV_64_INIT;
      for(int code in key.codeUnits) {
        rv ^= code;
        rv *= FNV_64_PRIME;
      }
      return rv & 0xffffffff;
    };

final HashAlgorithm FNV1_32_HASH =
    (String key) {
      int len = key.length;
      int rv = FNV_32_INIT;
      for(int code in key.codeUnits) {
        rv *= FNV_32_PRIME;
        rv ^= code;
      }
      return rv & 0xffffffff;
    };

final HashAlgorithm FNV1A_32_HASH =
    (String key) {
      int len = key.length;
      int rv = FNV_32_INIT;
      for(int code in key.codeUnits) {
        rv ^= code;
        rv *= FNV_32_PRIME;
      }
      return rv & 0xffffffff;
    };

final HashAlgorithm KETAMA_HASH =
    (String key) {
      List<int> bkey = computeMd5(key);
      int rv = ((bkey[3] & 0xff) << 24)
          | ((bkey[2] & 0xff) << 16)
          | ((bkey[1] & 0xff) << 8)
          | (bkey[0] & 0xff);
      return rv & 0xffffffff;
    };

List<int> computeMd5(String key) {
  return md5.convert(UTF8.encode(key)).bytes;
}

List<int> _crc32_table;
int _crc32(List<int> buf) {
  if (_crc32_table == null) {
    _crc32_table = new List(256);
    for(int i = 0; i < 256; ++i) {
      int c = i;
      for (int j = 0; j < 8; ++j) {
        c = (c & 1) != 0 ? (0xedb88320 ^ (c >> 1)) : (c >> 1);
      }
      _crc32_table[i] = c;
    }
  }
  int c = 0xffffffff;
  for (int len = buf.length, j = 0; j < len; ++j)
    c = _crc32_table[(c ^ buf[j]) & 0xff] ^ (c >> 8);
  return c ^ 0xffffffff;
}

Map<String, HashAlgorithm> _algorithmMap;
HashAlgorithm lookupHashAlgorithm(String name) {
  if (_algorithmMap == null) {
    _algorithmMap = new HashMap();
    _algorithmMap['NATIVE'] = NATIVE_HASH;
    _algorithmMap['CRC'] = CRC_HASH;
    _algorithmMap['FNV1_64'] = FNV1_64_HASH;
    _algorithmMap['FNV1A_64'] = FNV1A_64_HASH;
    _algorithmMap['FNV1_32'] = FNV1_32_HASH;
    _algorithmMap['FNV1A_32'] = FNV1A_32_HASH;
    _algorithmMap['KETAMA'] = KETAMA_HASH;
  }
  return _algorithmMap[name];
}
