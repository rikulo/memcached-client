//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

//Big-Endian for socket transfer
Uint8List int8ToBytes(int val) {
  if (val >= 128 || val < -128)
    throw new ArgumentError("Integer exceeds 8 bits(-128 ~ 127)");
  final Uint8List bytes = new Uint8List(1);
  bytes[0] = val & 0xff;
  return bytes;
}

int bytesToInt8(List<int> bytes, int start) => bytes[start + 0] & 0xff;

//Big-Endian for socket transfer
Uint8List int16ToBytes(int val) {
  if (val >= 32768 || val < -32768)
    throw new ArgumentError("Integer exceeds 16 bits(-32768 ~ 32767)");
  final Uint8List bytes = new Uint8List(2);
  bytes[1] = val & 0xff;
  bytes[0] = (val >> 8) & 0xff;
  return bytes;
}

int bytesToInt16(List<int> bytes, int start) =>
    ((bytes[start + 0] & 0xff) << 8) | (bytes[start + 1] & 0xff);

//Big-endian for socket transfer
Uint8List int32ToBytes(int val) {
  if (val >= 2147483648 || val < -2147483648)
    throw new ArgumentError("Integer exceeds 32 bits(-2147483648 ~ 2147483647)");
  final Uint8List bytes = new Uint8List(4);
  bytes[3] = val & 0xff;
  bytes[2] = (val >> 8) & 0xff;
  bytes[1] = (val >> 16) & 0xff;
  bytes[0] = (val >> 24) & 0xff;
  return bytes;
}

int bytesToInt32(List<int> bytes, int start) =>
    ((bytes[start + 0] & 0xff) << 24) | ((bytes[start + 1] & 0xff) << 16) |
    ((bytes[start + 2] & 0xff) << 8)  | (bytes[start + 3] & 0xff);

Uint8List int64ToBytes(int val) {
  if (val >= 9223372036854775808 || val < -9223372036854775808)
    throw new ArgumentError("Integer exceeds 64 bits(-9223372036854775808 ~ 9223372036854775807)");
  final Uint8List bytes = new Uint8List(8);
  bytes[7] = val & 0xff;
  bytes[6] = (val >> 8) & 0xff;
  bytes[5] = (val >> 16) & 0xff;
  bytes[4] = (val >> 24) & 0xff;
  bytes[3] = (val >> 32) & 0xff;
  bytes[2] = (val >> 40) & 0xff;
  bytes[1] = (val >> 48) & 0xff;
  bytes[0] = (val >> 56) & 0xff;
  return bytes;
}

int bytesToInt64(List<int> bytes, int start) =>
    ((bytes[start + 0] & 0xff) << 56) | ((bytes[start + 1] & 0xff) << 48) |
    ((bytes[start + 2] & 0xff) << 40) | ((bytes[start + 3] & 0xff) << 32) |
    ((bytes[start + 4] & 0xff) << 24) | ((bytes[start + 5] & 0xff) << 16) |
    ((bytes[start + 6] & 0xff) << 8)  | (bytes[start + 7] & 0xff);

void copyList(List<int> src, int srci, List<int> dst, int dsti, int len) {
  for (int j = 0; j < len; ++j)
    dst[dsti + j] = src[srci + j];
}

