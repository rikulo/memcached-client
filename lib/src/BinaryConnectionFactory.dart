//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

class BinaryConnectionFactory extends ConnectionFactoryBase {
  BinaryConnectionFactory([HashAlgorithm hashAlg])
      : super(hashAlg);

  //@Override
  MemcachedNode createMemcachedNode(SocketAddress saddr) =>
      new BinaryMemcachedNodeImpl(saddr, authDescriptor.bucket,
                                  authDescriptor.password);

  //@Override
  OPFactory get opFactory => new BinaryOPFactory();
}
