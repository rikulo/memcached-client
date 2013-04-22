//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

/**
 * Factory for creating instances of MemcachedConnection; used to provide
 * fine-grained configuration of connections.
 */
abstract class ConnectionFactory {
  /**
   * Create a MemcachedConnection for the given SocketAddresses.
   */
  Future<MemcachedConnection> createConnection(Iterable<SocketAddress> saddrs);

  /**
   * Create a new MemcachedNode.
   */
  MemcachedNode createMemcachedNode(SocketAddress saddr);

  /**
   * Create a list of MemcachedNode per the provided Socket addresses.
   */
  List<MemcachedNode> createNodes(Iterable<SocketAddress> saddrs);

  /**
   * Create a NodeLocator instance for the given list of nodes.
   */
  Future<NodeLocator> createLocator(Iterable<MemcachedNode> nodes);

  /**
   * The OPFactory for connections built by this connectin factory.
   */
  OPFactory get opFactory;

  /**
   * The OP timeout time in milliseconds for connections built by this
   * conenction factory.
   */
  int get opTimeout;

  /**
   * The failure mode when a node in the connections built by this
   * connection factory is down.
   */
  FailureMode get failureMode;

  /**
   * The Transcoder used in the connections built by this conenction
   * factory.
   */
//  Transcoder get transcoder;

  /**
   * The HashAlgorithm used in the connections built by
   * this connection factory(for hashing the key).
   */
  HashAlgorithm get hashAlgorithm;

  /**
   * The maximum number of milliseconds to wait between reconnection attempts
   * used in the connections built by this connection factory.
   */
  int get maxReconnectDelay;

  /**
   * The authentication descriptor associated with the connections built by
   * this connection factory.
   */
  AuthDescriptor get authDescriptor;
}
