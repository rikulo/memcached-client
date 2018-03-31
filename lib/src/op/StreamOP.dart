//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Feb 19, 2013  09:42:12 AM
// Author: hernichen

part of memcached_client;

/**
 * An operation that will return a [Stream].
 */
abstract class StreamOP<T> extends OP {
  Stream<T> get stream;
}
