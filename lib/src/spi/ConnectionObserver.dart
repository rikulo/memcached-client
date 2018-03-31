//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Jun 28, 2013  11:39:35 AM
// Author: hernichen

part of memcached_client;

abstract class ConnectionObserver {
  /**
   * A connection has just successfully been established on the given socket.
   *
   * + [saddr] - the address of the node whose connection was established
   * + [reconnectCount] - the number of attempts before the connection was
   *          established
   */
  void connectionEstablished(SocketAddress saddr, int reconnectCount);

  /**
   * A connection was just lost on the given socket.
   *
   * + [saddr] - the address of the node whose connection was lost
   */
  void connectionLost(SocketAddress saddr);
}
