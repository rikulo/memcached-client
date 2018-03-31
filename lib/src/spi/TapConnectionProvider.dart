//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Jun 26, 2013  09:12:31 AM
// Author: hernichen

part of memcached_client;

/**
 * A TapConnectionProvider.
 */
class TapConnectionProvider implements ConnectionObserver {
  final MemcachedConnection _memcachedConn;

  final OPFactory _opFactory;

//  final TranscodeService tcService;

  final AuthDescriptor _authDescriptor;

//  final AuthThreadMonitor authMonitor = new AuthThreadMonitor();
  bool shuttingDown = false;

  Logger _logger;

  /**
   * Create and connect to a cluster of servers per the specified server
   * addresses and optional connection factory.
   *
   * + [saddrs] - socket addresses of a cluster of servers
   * + [factory] - optional connection factory; default: [BinaryConnectionFactory].
   */
  static Future<TapConnectionProvider> connect(List<SocketAddress> saddrs,
      [ConnectionFactory factory]) {
    return new Future.sync(() {
      if (saddrs == null || saddrs.isEmpty)
        throw new ArgumentError(
            "Need at least one server to connect to: $saddrs");
      if (factory == null) factory = new BinaryConnectionFactory();
      return factory
          .createConnection(saddrs)
          .then((conn) => new TapConnectionProvider(conn, factory));
    });
  }

  /**
   * Get a tap client operating on the specified memcached locations.
   *
   * + [memcachedConn] - the connection factory to configure connections for
   * this client
   * + [saddrs] the socket addresses
   * @throws IOException if connections cannot be established
   */
  TapConnectionProvider(MemcachedConnection memcachedConn,
      [ConnectionFactory factory])
      : _memcachedConn = memcachedConn,
        _opFactory = factory.opFactory,
        _authDescriptor = factory.authDescriptor {
    _logger = initLogger('memcached_client.spi', this);
    if (_authDescriptor != null) {
      addObserver(this);
    }
  }

  void addTapOp(MemcachedNode node, final TapOP op) {
    _memcachedConn.addOPToNode(node, op);
  }

  Map<SocketAddress, dynamic> broadcastOP(OP newOP()) {
    if (shuttingDown) {
      throw new StateError("Shutting down");
    }
    return _memcachedConn.broadcastOP(
        newOP, _memcachedConn.locator.allNodes.iterator);
  }

  /**
   * Add a connection observer.
   *
   * If connections are already established, your observer will be called with
   * the address and -1.
   *
   * @param obs the ConnectionObserver you wish to add
   * @return true if the observer was added.
   */
  bool addObserver(ConnectionObserver obs) {
    bool rv = _memcachedConn.addObserver(obs);
    if (rv) {
      for (MemcachedNode node in _memcachedConn.locator.allNodes) {
        if (node.isActive) {
          obs.connectionEstablished(node.socketAddress, -1);
        }
      }
    }
    return rv;
  }

  /**
   * Remove a connection observer.
   *
   * @param obs the ConnectionObserver you wish to add
   * @return true if the observer existed, but no longer does
   */
  bool removeObserver(ConnectionObserver obs) {
    return _memcachedConn.removeObserver(obs);
  }

  //--ConnectionObserver--//
  void connectionEstablished(SocketAddress sa, int reconnectCount) {
    if (_authDescriptor != null) {
      if (_authDescriptor.authThresholdReached) {
        this.shutdown();
//TODO: authentication
//      } else {
//        authMonitor.authConnection(_memcachedConn, _opFactory, _authDescriptor, findNode(sa));
      }
    }
  }

  MemcachedNode findNode(SocketAddress sa) {
    MemcachedNode node = null;
    for (MemcachedNode n in _memcachedConn.locator.allNodes) {
      if (n.socketAddress == sa) {
        node = n;
      }
    }
    assert(node != null);
    return node;
  }

  void connectionLost(SocketAddress sa) {
    // Don't care.
  }

  /**
   * Shut down this client gracefully.
   *
   * + [timeout] - the amount of time for shutdown in milliseconds.
   */
  bool shutdown([int timeout = -1]) {
    // Guard against double shutdowns
    if (shuttingDown) {
      _logger.info("Suppressing duplicate attempt to shut down Tap connection");
      return false;
    }
    shuttingDown = true;
    _logger.info("Shutting down TapConnections");
    _memcachedConn.close();
    return true;
  }

  OPFactory get opFactory => _opFactory;
}
