//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

/**
 * ConnectionFactory for binary protocol.
 */
class BinaryConnectionFactory extends ConnectionFactoryBase {
  BinaryConnectionFactory([HashAlgorithm hashAlg]) : super(hashAlg);

  @override
  Future<MemcachedNode> createMemcachedNode(SocketAddress saddr) =>
      BinaryMemcachedNodeImpl.start(saddr, authDescriptor);

  @override
  OPFactory get opFactory => new BinaryOPFactory();
}
