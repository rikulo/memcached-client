//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

/**
 * A node in the memcached cluster along with buffering and operation channel.
 */
abstract class MemcachedNode {
  final SocketAddress socketAddress;

  MemcachedNode(SocketAddress saddr) : socketAddress = saddr;

  /**
   * True if this node is active; i.e. it is connected and
   * able to process requests.
   */
  bool get isActive =>
      opChannel.isConnected && opChannel.isAuthenticated == true;

  /**
   * True if this node is connected(but not necessary authenticated).
   */
  bool get isConnected => opChannel.isConnected;

  /**
   * Prepend an OP at the beginning of the operation queue.
   */
  void prependOP(OP op) {
    opChannel.prependOP(op);
  }

  /**
   * Add an OP at the end of the operation queue.
   */
  void addOP(OP op) {
    opChannel.addOP(op);
  }

  /**
   * close the connection to this node.
   */
  void close() {
    opChannel.close();
  }

  /**
   * Returns an OPChannel for socket accessing.
   */
  OPChannel<int, OP> get opChannel;

  /**
   * Called back when this node is connected.
   */
  void connected() {
    //TODO: connected shall reset reconnecting
  }

  /**
   * TODO: Returns the reconnection times before this node was connected.
   */
  int get reconnectCount => 0;
}
