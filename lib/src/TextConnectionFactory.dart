//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

/**
 * ConnectionFactory for text protocol.
 */
class TextConnectionFactory extends ConnectionFactoryBase {
  TextConnectionFactory([HashAlgorithm hashAlg])
      : super(hashAlg);

  @override
  MemcachedNode createMemcachedNode(SocketAddress saddr) =>
      new TextMemcachedNodeImpl(saddr);

  @override
  OPFactory get opFactory => new TextOPFactory();
}
