//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

/**
 * ConnectionFactory for text protocol.
 */
class TextConnectionFactory extends ConnectionFactoryBase {
  TextConnectionFactory([HashAlgorithm hashAlg]) : super(hashAlg);

  @override
  Future<MemcachedNode> createMemcachedNode(SocketAddress saddr) =>
      TextMemcachedNodeImpl.start(saddr);

  @override
  OPFactory get opFactory => new TextOPFactory();
}
