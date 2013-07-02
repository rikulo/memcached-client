//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Jun 28, 2013  11:39:35 AM
// Author: hernichen

part of memcached_client;

/**
 * Tap Client to a memcached cluster servers.
 *
 * Detail Tap protocol: http://www.couchbase.com/wiki/display/couchbase/TAP+Protocol
 */
class TapClient {
  final StreamController<ResponseMessage> _ctrl;
  final ConnectionFactory _connFact;
  final List<SocketAddress> _saddrs;
  final Map<TapStream, TapConnectionProvider> _omap;

  bool _closing = false;
  Logger _logger;

  /// Provide socket address to tap memcached servers.
  /// + [saddrs] - direct connection to memcached servers
  /// + [factory] - connection factory
  TapClient(List<SocketAddress> saddrs, [ConnectionFactory factory])
      : _saddrs = saddrs,
        _connFact = factory != null ? factory : new BinaryConnectionFactory(),
        _ctrl = new StreamController(),
        _omap = new HashMap() {
    if (saddrs == null || saddrs.isEmpty)
      throw new ArgumentError("Need at least one server to connect to: $saddrs");
    _logger = initLogger('memcached_client.spi', this);
  }

  /// Fetch received response message from this stream.
  Stream<ResponseMessage> get stream => _ctrl.stream;

  /// Specify a custom tap request and expect a stream back with ResponseMessage
  /// accordingly.
  ///
  /// + [id] - the named tap id that can be used to resume a disconnected tap
  /// stream
  /// + [message] - the custom tap request message to initiate the tap stream
  Future<TapStream> tapRequest(String id, RequestMessage message) {
    return _tapConn
    .then((TapConnectionProvider tconn) {
      Map<SocketAddress, TapOP> map =
          tconn.broadcastOP(() => _opFactory.newTapRequest(id, message));
      Iterable<TapOP> ops = map.values;
      _combineStreams(_ctrl, ops);
      final TapStream ts = new TapStream(ops);
      _omap[ts] = tconn;
      return ts;
    })
    .catchError((err) => _ctrl.addError(err));
  }

  /// Specify a tap stream that will take a snapshot of items in memcached.
  ///
  /// + [id] - the named tap id that can be used to resume a disconnected tap
  /// stream
  Future<TapStream> tapDump(String id) {
    return _tapConn
    .then((TapConnectionProvider tconn) {
      Map<SocketAddress, TapOP> map =
          tconn.broadcastOP(() => _opFactory.newTapDump(id));
      Iterable<TapOP> ops = map.values;
      _combineStreams(_ctrl, ops);
      final TapStream ts = new TapStream(ops);
      _omap[ts] = tconn;
      return ts;
    })
    .catchError((err) => _ctrl.addError(err));
  }

  /// Specify a tap stream which will return the oldest entry (millisecond from
  /// epoch) you are interested in. Specifying a time in the future(or -1), will
  /// make it to start straming only current changes.
  ///
  /// + [id] - the named tap id that can be used to resume a disconnected tap
  /// stream
  /// + [millisecondsSinceEpoch] - the date of the oldest entry you are
  /// interested in.
  Future<TapStream> tapBackfill(String id, [int millisecondsSinceEpoch = -1]) {
    return _tapConn
    .then((TapConnectionProvider tconn) {
      Map<SocketAddress, TapOP> map =
          tconn.broadcastOP(() => _opFactory.newTapBackfill(id, millisecondsSinceEpoch));
      Iterable<TapOP> ops = map.values;
      _combineStreams(_ctrl, ops);
      final TapStream ts = new TapStream(ops);
      _omap[ts] = tconn;
      return ts;
    })
    .catchError((err) => _ctrl.addError(err));
  }

  /// close all tap streams currently running.
  void close() {
    if (!_closing) {
      _closing = true;
      for (TapConnectionProvider tapConn in _omap.values)
        tapConn.shutdown();
    }
  }

  OPFactory get _opFactory => _connFact.opFactory;

  Future<TapConnectionProvider> get _tapConn {
    return _connFact.createConnection(_saddrs)
        .then((mconn) => new TapConnectionProvider(mconn, _connFact));
  }

  void _combineStreams(StreamController<ResponseMessage> ctrl, Iterable<OP> ops) {
    _logger.finest("ops.length:${ops.length}");
    int done = ops.length;
    for (var op in ops) {
      op.stream.listen(
        (data) => ctrl.add(data),
        onError: (err) => ctrl.addError(err),
        onDone: () {if (--done == 0) ctrl.close();});
    }
  }
}