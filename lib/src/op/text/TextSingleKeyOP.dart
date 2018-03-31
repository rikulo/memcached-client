//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Oct 30, 2013  5:51:09 PM
// Author: hernichen

part of memcached_client;

abstract class TextSingleKeyOP extends TextOP {
  final String key;

  TextSingleKeyOP(this.key);

  @override
  String toString() => "${this.runtimeType}@$seq:$key";
}
