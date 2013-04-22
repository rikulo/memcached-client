//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

class TextConnectionFactory extends ConnectionFactoryBase {
  TextConnectionFactory([HashAlgorithm hashAlg])
      : super(hashAlg);

  //@Override
  MemcachedNode createMemcachedNode(SocketAddress saddr) =>
      new TextMemcachedNodeImpl(saddr);

  //@Override
  OPFactory get opFactory => new TextOPFactory();
}
