//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

class BinaryMemcachedNodeImpl extends MemcachedNode {
  @override
  final BinaryOPChannel opChannel;

  BinaryMemcachedNodeImpl(SocketAddress saddr, AuthDescriptor authDescriptor)
      : opChannel = new BinaryOPChannel(saddr, authDescriptor),
        super(saddr);

  String toString() => "$opChannel -> $socketAddress";
}

