//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

/**
 * ConnectionFactory for binary protocol with Sasl authentification.
 */
class SaslBinaryConnectionFactory extends BinaryConnectionFactory {

  AuthDescriptor _authDescriptor = null;

  SaslBinaryConnectionFactory([HashAlgorithm hashAlg], {String bucketName, String password})
      : super(hashAlg) {
      if (bucketName != null && password != null)
        _authDescriptor = new AuthDescriptor(["PLAIN"], bucketName, password);
  }

  @override
  Future<MemcachedNode> createMemcachedNode(SocketAddress saddr) =>
      BinaryMemcachedNodeImpl.start(saddr, _authDescriptor);

}
