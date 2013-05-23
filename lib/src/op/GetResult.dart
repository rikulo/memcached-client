//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 04, 2013  09:58:59 AM
// Author: hernichen

part of memcached_client;

/** Represent a result after execute get command */
class GetResult {
  final String key;
  final int flags;
  final int cas;
  final List<int> data;

  GetResult(this.key, this.flags, this.cas, this.data);

  String toString() => '$key:$data, flags:$flags, cas:$cas';
}
