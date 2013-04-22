//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

class TextMemcachedNodeImpl extends MemcachedNode {
  //TODO: would multiple opChannels in a node a better implementation?
  final TextOPChannel _opChannel;
  TextMemcachedNodeImpl(SocketAddress saddr)
      : _opChannel = new TextOPChannel(saddr),
        super(saddr);

  OPChannel get opChannel => _opChannel;
}
