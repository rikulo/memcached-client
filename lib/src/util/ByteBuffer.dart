//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Jan 30, 2013  10:12:51 AM
// Author: hernichen

part of memcached_client;

/**
 * A buffer with parsed offset.
 */
class ByteBuffer {
  int offset;
  List<int> buf;

  ByteBuffer()
      : offset = 0,
        buf = new List();

  int get length => buf.length;

  void clear() {
    offset = 0;
    buf = new List();
  }

  int operator [](int index) => buf[index];

  void addAll(Iterable<int> iterable) => buf.addAll(iterable);

  List<int> getRange(int start, int length) => buf.getRange(start, length);

  void removeRange(int start, int length) {
    offset = buf.length - length;
    buf.removeRange(start, length);
  }

  String toString() => 'offset:$offset, ${buf.toString()}';
}
