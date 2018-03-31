//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 01, 2013  19:15:02 PM
// Author: hernichen

part of memcached_client;

class SocketAddress {
  String host;
  int port;

  SocketAddress(this.host, this.port);

  String toUri() => '$host:$port';

  String toString() => toUri();

  @override
  int get hashCode => host.hashCode ^ port;

  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! SocketAddress) return false;

    return this.host == other.host && this.port == other.port;
  }
}
