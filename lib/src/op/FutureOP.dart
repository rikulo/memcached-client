//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 01, 2013  06:59:12 PM
// Author: hernichen

part of memcached_client;

/**
 * An operation that will return a [Future].
 */
abstract class FutureOP<T> extends OP {
  Future<T> get future;
}
