//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

/**
 * Base implementation of a ConnectionFactory.
 */
abstract class ConnectionFactoryBase implements ConnectionFactory {
  /**
   * Default failure mode.
   */
  static final FailureMode DEFAULT_FAILURE_MODE = FailureMode.Redistribute;

  /**
   * Default hash algorithm.
   */
  static final HashAlgorithm DEFAULT_HASH = NATIVE_HASH;

  /**
   * Maximum length of the operation queue returned by this connection factory.
   */
//  static final int DEFAULT_OP_QUEUE_LEN = 16384;

  /**
   * The maximum time to block waiting for op queue operations to complete, in
   * milliseconds. The default has been set with the expectation that most
   * requests are interactive and waiting for more than a few seconds is thus
   * more undesirable than failing the request.
   */
  static final int DEFAULT_OP_QUEUE_MAX_BLOCK_TIME = 10000; //10 seconds

  /**
   * The read buffer size for each server connection from this factory.
   */
//  static final int DEFAULT_READ_BUFFER_SIZE = 16384;

  /**
   * Default operation timeout in milliseconds.
   */
  static final int DEFAULT_OPERATION_TIMEOUT = 2500;

  /**
   * Maximum amount of time (in seconds) to wait between reconnect attempts.
   */
  static final int DEFAULT_MAX_RECONNECT_DELAY = 30;

  /**
   * Maximum number + 2 of timeout exception for shutdown connection.
   */
//  static final int DEFAULT_MAX_TIMEOUTEXCEPTION_THRESHOLD = 998;

  HashAlgorithm _hashAlg;

  ConnectionFactoryBase([HashAlgorithm hashAlg]) {
    _hashAlg = hashAlg == null ? DEFAULT_HASH : hashAlg;
  }

  @override
  Future<MemcachedConnection> createConnection(List<SocketAddress> saddrs) {
    return createNodes(saddrs)
    .then((List<MemcachedNode> nodes) {
      return createLocator(nodes).then((locator) =>
          new MemcachedConnection(locator, this, opFactory, failureMode));
    });
  }

  @override
  Future<List<MemcachedNode>> createNodes(Iterable<SocketAddress> saddrs) {
    List<MemcachedNode> nodes = new List();
    return Future.forEach(saddrs,
      (SocketAddress saddr) => createMemcachedNode(saddr)
      .then((node) {
        nodes.add(node);
      })
    )
    .then((_) => nodes);
  }

  @override
  Future<NodeLocator> createLocator(List<MemcachedNode> nodes) =>
      new Future.value(new ArrayModNodeLocator(nodes, hashAlgorithm));

  @override
  OPFactory get opFactory => new TextOPFactory();

  @override
  int get opTimeout => DEFAULT_OPERATION_TIMEOUT;

  @override
  FailureMode get failureMode => DEFAULT_FAILURE_MODE;

  @override
//TODO:
//  Transcoder get transcoder => new SerializingTranscoder();

  @override
  HashAlgorithm get hashAlgorithm => _hashAlg;

  @override
  int get maxReconnectDelay => DEFAULT_MAX_RECONNECT_DELAY;

  @override
  AuthDescriptor get authDescriptor => null;
}
