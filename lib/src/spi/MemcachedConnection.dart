//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

/**
 * Connection to a cluster of memcached server nodes.
 */
class MemcachedConnection {
  final NodeLocator locator;
  final ConnectionFactory _connFactory;
  final OPFactory _opFactory;
  final FailureMode _failureMode;

  Logger _logger;
  bool _closing = false;

  MemcachedConnection(NodeLocator locator, ConnectionFactory connFactory,
      OPFactory opFactory, FailureMode failureMode)
      : locator = locator,
        _connFactory = connFactory,
        _opFactory = opFactory,
        _failureMode = failureMode {

    _logger = initLogger('memcached_client.spi', this);
  }

  List<MemcachedNode> _createConnections(Iterable<SocketAddress> a) {
    List<MemcachedNode> connections = new List(a.length);
    for (SocketAddress sa in a) {
      MemcachedNode qa = _connFactory.createMemcachedNode(sa);
      connections.add(qa);
    }
    return connections;
  }

  void addOP(String key, OP op) {
    validateKey(key, _opFactory is BinaryOPFactory);
    _checkState();
    MemcachedNode placeIn = null;
    MemcachedNode primary = locator.getPrimary(key);
    if (primary.isActive || _failureMode == FailureMode.Retry) {
      placeIn = primary;
    } else if (_failureMode == FailureMode.Cancel) {
      op.cancel();
    } else {
      // Look for another node in sequence that is ready.
      Iterator<MemcachedNode> i = locator.getSequence(key);
      while (placeIn == null && i.moveNext()) {
        MemcachedNode node = i.current;
        if (node.isActive)
          placeIn = node;
      }
      // If we didn't find an active node, queue it in the primary node
      // and wait for it to come back online.
      if (placeIn == null) {
        placeIn = primary;
        _logger.warning(
            "Could not redistribute "
            "to another node, retrying primary node for $key.");
      }
    }

    if (placeIn != null) {
      placeIn.addOP(op);
    }
  }

  void prependOPToNode(MemcachedNode node, OP op) {
    _checkState();
    node.prependOP(op);
  }

  void addOPToNode(MemcachedNode node, OP op) {
    _checkState();
    node.addOP(op);
  }

  Future<Map<MemcachedNode, dynamic>> broadcastOP(FutureOP newOP(),
      Iterator<MemcachedNode> nodeIterator) {
    return new Future.sync(() {
      if (_closing )
        throw new StateError("Shutting down the connection");
      List<Future> futures = new List();
      Map<MemcachedNode, dynamic> results = new HashMap();
      while (nodeIterator.moveNext()) {
        MemcachedNode node = nodeIterator.current;
        FutureOP op = newOP();
        op.future
          .then((rv) => results[node] = rv)
          .catchError((err) => _logger.warning("broadcastOP. node: $node, OP: $op, Error: $err"));
        futures.add(op.future);
        addOPToNode(node, op);
      }
      return Future.wait(futures)
         .then((_) => results);
    });
  }

  void close() {
    _closing = true;
    for (MemcachedNode node in locator.allNodes) {
      node.close();
    }
  }

  void _checkState() {
    if (_closing)
      throw new StateError("Connection is closing");
  }

  FailureMode get failureMode => _failureMode;
}
