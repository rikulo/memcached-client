//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Jun 25, 2013  05:03:43 PM
// Author: hernichen

part of memcached_client;

/**
 * An acknowledgment message used to tell the server we have received a
 * series of messages.
 */
class TapAck {
  final TapConnectionProvider connection;
  final TapOpcode opcode;
  final int opaque;
  final MemcachedNode node;

  TapAck(TapConnectionProvider conn, MemcachedNode node, TapOpcode opcode,
      int opaque)
      : this.connection = conn,
        this.node = node,
        this.opcode = opcode,
        this.opaque = opaque;
}
