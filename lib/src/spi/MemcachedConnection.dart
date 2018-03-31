//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

/**
 * Connection to a cluster of memcached server nodes.
 */
class MemcachedConnection {
  final NodeLocator locator;
  final ConnectionFactory connFactory;
  final OPFactory _opFactory;
  final FailureMode _failureMode;
  final List<MemcachedNode> nodesToShutdown;
  final Set<ConnectionObserver> connObservers;

  Logger _logger;
  bool _closing = false;

  MemcachedConnection(NodeLocator locator, ConnectionFactory connFactory,
      OPFactory opFactory, FailureMode failureMode)
      : locator = locator,
        this.connFactory = connFactory,
        _opFactory = opFactory,
        _failureMode = failureMode,
        nodesToShutdown = new List(),
        connObservers = new HashSet() {
    _logger = initLogger('memcached_client.spi', this);
  }

  void addOP(String key, OP op) {
    //check if this is a valid key
    validateKey(key, _opFactory is BinaryOPFactory);
    //check if the connection is closing
    _checkState();
    //locate the node to dispatch the operation
    MemcachedNode placeIn = locateNode(key, op);
    //add operation to the node
    addSingleKeyOPToNode(key, placeIn, op);
  }

  //To be overridden by CouchbaseConnection
  //locate the node to dispathe the operation
  MemcachedNode locateNode(String key, OP op) {
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
        if (node.isActive) placeIn = node;
      }
      // If we didn't find an active node, queue it in the primary node
      // and wait for it to come back online.
      if (placeIn == null) {
        placeIn = primary;
        _logger.warning("Could not redistribute "
            "to another node, retrying primary node for $key.");
      }
    }

    return placeIn;
  }

  void prependOPToNode(MemcachedNode node, OP op) {
    _checkState();
    op.handlingNode = node;
    node.prependOP(op);
  }

  void addOPToNode(MemcachedNode node, OP op) {
    _checkState();
    op.handlingNode = node;
    node.addOP(op);
  }

  //To be overridden by CouchbaseConnection for single-key operation
  void addSingleKeyOPToNode(String key, MemcachedNode node, OP op) {
    if (node != null) addOPToNode(node, op);
  }

  //To be overridden by CouchbaseConnection for multi-key operation
  void addMultiKeyOPToNode(List<String> keys, MemcachedNode node, OP op) {
    if (node != null) addOPToNode(node, op);
  }

  Map<SocketAddress, OP> broadcastOP(
      FutureOP newOP(), Iterator<MemcachedNode> nodeIterator) {
    if (_closing) throw new StateError("Shutting down the connection");
    Map<SocketAddress, OP> results = new HashMap();
    while (nodeIterator.moveNext()) {
      MemcachedNode node = nodeIterator.current;
      final OP op = newOP();
      results[node.socketAddress] = op;
      if (op is MultiKeyOP)
        addMultiKeyOPToNode(op.keys, node, op);
      else if (op is SingleKeyOP)
        addSingleKeyOPToNode(op.key, node, op);
      else
        addOPToNode(node, op);
    }
    return results;
  }

  void close() {
    _closing = true;
    for (MemcachedNode node in locator.allNodes) {
      node.close();
    }
  }

  /**
   * Add a connection observer; return true if the observer was NOT existed.
   */
  bool addObserver(ConnectionObserver obs) {
    final bool existed = connObservers.contains(obs);
    connObservers.add(obs);
    return !existed;
  }

  /**
   * Remove a connection observer; return true if the observer was existed.
   */
  bool removeObserver(ConnectionObserver obs) {
    return connObservers.remove(obs);
  }

  void _connected(MemcachedNode node) {
    assert(node.isConnected);
    int rt = node.reconnectCount;
    node.connected();
    for (ConnectionObserver observer in connObservers) {
      observer.connectionEstablished(node.socketAddress, rt);
    }
  }

  void lostConnection(MemcachedNode node) {
//TODO: when we want to reconnect automatically; might have to put them into a queue.
//    queueReconnect(node);
    for (ConnectionObserver observer in connObservers) {
      observer.connectionLost(node.socketAddress);
    }
  }

  void _checkState() {
    if (_closing) throw new StateError("Connection is closing");
  }

  FailureMode get failureMode => _failureMode;

//  void _ioLoop() {
//    new Future.delayed(new Duration(milliseconds:_FREQ))
//    .then((_) {
//      _logger.finest("_ioLoop...");
//      if (!_handleIO()) {
//        _logger.finest("Still IO to be processed, continue the _ioLoop.");
//        _ioLoop();
//      } else {
//        _logger.finest("No more IO to be processed, stop the _ioLoop.");
//      }
//    })
//    .catchError((err) => _logger.warning("_ioLoop:\n$err"));
//  }
//
//  // Return true if still IO to be processed; otherwise false
//  bool _handleIO() =>
//      _closeOddNodes();
//
//  // Close odd nodes(those nodes has been down)
//  bool closeOddNodes() {
//    // try to shutdown odd nodes
//    for (MemcachedNode qa : nodesToShutdown) {
//      if (!addedQueue.contains(qa)) {
//        nodesToShutdown.remove(qa);
//        List<OP> notCompletedOperations = qa.destroyInputQueue();
//        if (qa.getChannel() != null) {
//          qa.getChannel().close();
//          qa.setSk(null);
//          if (qa.getBytesRemainingToWrite() > 0) {
//            _logger.warning("Shut down with ${qa.getBytesRemainingToWrite} bytes remaining to write",
//                qa.getBytesRemainingToWrite());
//          }
//          _logger.fine("Shut down channel %s", qa.getChannel());
//        }
//        redistributeOperations(notCompletedOperations);
//      }
//    }
//
//    return false;
//  }
//
//  void _redistributeOperations(Iterable<OP> ops) {
//    for (OP op in ops) {
//      if (op.isCancelled || op.isTimedOut) {
//        continue;
//      }
//      if (op is KeyedOperation) {
//        KeyedOperation ko = (KeyedOperation) op;
//        int added = 0;
//        for (String k : ko.getKeys()) {
//          for (Operation newop : opFact.clone(ko)) {
//            addOperation(k, newop);
//            added++;
//          }
//        }
//        assert added > 0 : "Didn't add any new operations when redistributing";
//      } else {
//        // Cancel things that don't have definite targets.
//        op.cancel();
//      }
//    }
//  }

}
