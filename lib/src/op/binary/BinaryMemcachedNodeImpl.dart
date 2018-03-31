//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

class BinaryMemcachedNodeImpl extends MemcachedNode {
  @override
  final BinaryOPChannel opChannel;

  static Future<BinaryMemcachedNodeImpl> start(
          SocketAddress saddr, AuthDescriptor authDescriptor,
          {int authRetry}) =>
      BinaryOPChannel.start(saddr, authDescriptor, authRetry: authRetry).then(
          (BinaryOPChannel channel) =>
              new BinaryMemcachedNodeImpl._(saddr, channel));

  BinaryMemcachedNodeImpl._(SocketAddress saddr, this.opChannel) : super(saddr);

  String toString() => "$opChannel -> $socketAddress";
}
