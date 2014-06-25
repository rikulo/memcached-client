//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

class TextMemcachedNodeImpl extends MemcachedNode {
  //TODO: would multiple opChannels in a node a better implementation?
  @override
  final TextOPChannel opChannel;

  static Future<TextMemcachedNodeImpl> start(SocketAddress saddr)
  => TextOPChannel.start(saddr)
  .then((TextOPChannel channel)
  	=> new TextMemcachedNodeImpl._(saddr, channel));

  TextMemcachedNodeImpl._(SocketAddress saddr, this.opChannel)
      : super(saddr);

  String toString() => "$opChannel -> $socketAddress";
}
