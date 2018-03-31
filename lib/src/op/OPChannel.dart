//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

abstract class OPChannel<K, V> {
  /**
   * Returns whether this OP channel is connected.
   */
  bool get isConnected;

  /**
   * Returns whether this OP channel is authenticated.
   *
   * + null to indicate need authentication; will call authenticate() to do authentication.
   * + true to indicate authentication successfully.
   * + false to indicate authentication failed; will stop operation.
   */
  bool get isAuthenticated;

  /**
   * Do the authentication. If success, shall make isAuthenticated to return true.
   */
  void authenticate();

  /**
   * Process the response from the server.
   */
  void processResponse();

  /**
   * Returns the write OPQueue.
   */
  OPQueue<K, V> get writeQ;

  /**
   * Returns the read OPQueue.
   */
  OPQueue<K, V> get readQ;

  /**
   * Enque OP into queue and kick start process if necessary.
   */
  void addOP(V op);

  /**
   * Enque OP at the beginning and kick start process if necessary.
   */
  void prependOP(V op);

  /**
   * Close this OP Channel
   */
  void close();
}

abstract class _OPChannelImpl<K> implements OPChannel<K, OP> {
  //-- Base Implementation --//
  final SocketAddress _saddr;

  Logger _logger;
  int _seq = 0; //OP sequence id for matching OP response.
  final Socket _socket;
  bool _closing = false; //Channel is closing
  OP _writeOP; //current OP writing into socket
  final List<int> _pbuf; //response scratch buffer

  //Base constructor
  static Future<_OPChannelImpl> _start(
      SocketAddress saddr, _OPChannelImpl newInstance(Socket socket)) {
    return Socket.connect(saddr.host, saddr.port).then((Socket socket) {
      final _OPChannelImpl channel = newInstance(socket);
      channel._setupResponseHandler();
      //_logger.finest("Socket to $_saddr connected!");
      return channel;
    });
  }

  _OPChannelImpl._(this._saddr, this._socket) : _pbuf = new List() {
    _logger = initLogger("memcached_client.op", this);
  }

  /**
   * Returns whether this OP channel is connected.
   */
  bool get isConnected => _socket != null;

  /**
   * Enque OP into queue and kick start process if necessary.
   */
  void addOP(OP op) {
    if (_closing) {
      //_logger.finest("The client to $_saddr is being closing; no way to addOP.");
      return;
    }
    op.seq = _seq++;
    _seq &= 0xffffffff;
    op.nextState();
    writeQ.add(op);
    //20130701, henrichen: Tricky, TapOP is special, seq will not match!
    if (op is! TapOP) readQ.add(op, op.seq as dynamic);
    if (writeQ.length == 1) {
      // 0 -> 1, new a Future for OP processing
      _processLoop();
    }
  }

  /**
   * Enque OP at the beginning and kick start process if necessary.
   */
  void prependOP(OP op) {
    if (_closing) {
      //_logger.finest("The client to $_saddr is being closing; no way to prependOP.");
      return;
    }

    op.seq = _seq++;
    op.nextState();
    writeQ.push(op);
    readQ.add(op, op.seq as dynamic);
    if (writeQ.length == 1) {
      // 0 -> 1, new a Future for OP processing
      _processLoop();
    }
  }

  /**
   * Close this Operation channel.
   */
  void close() {
    //_logger.finest("close socket to $_saddr --> _writeQ.isEmpty:${writeQ.isEmpty}, _readMap.isEmpty:${readQ.isEmpty}");
    _closing = true;
    _tryClose();
  }

  void _tryClose() {
    if (_closing && writeQ.isEmpty && readQ.isEmpty && _socket != null)
      _socket.close();
    else {
      //_logger.finest("Socket to $_saddr, writeQ:$writeQ");
      //_logger.finest("Socket to $_saddr, readQ:$readQ");
    }
  }

  void _processLoop() {
    new Future.delayed(new Duration(milliseconds: _FREQ)).then((_) {
      //_logger.finest("_processLoop for socket to $_saddr...");
      if (!isConnected) {
        //_logger.finest("Wait socket to $_saddr to be connected.");
        _processLoop();
      } else if (isAuthenticated == null) {
        //_logger.finest("Wait socket to $_saddr to be authenticated.");
        authenticate();
        _processLoop();
      } else if (!isAuthenticated) {
        //fail to authentication
        throw new StateError(
            'Fail to authenticate socket to $_saddr...Stop operation');
      } else if (!_processWriteQ()) {
        //_logger.finest("Still OP in queue, continue the _processLoop for socket to $_saddr. writeQ:${writeQ}");
        _processLoop();
      } else {
        //_logger.finest("No more OP in queue, stop the _processLoop for socket to $_saddr.");
      }
    }).catchError((err, st) => _logger.warning(
        "Error in _processLoop for socket to $_saddr", err, st));
  }

  //Process OP in write queue; return true to indicate no OP to process
  bool _processWriteQ() {
    //fetch next OP in queue when previous OP is complete.
    if (_writeOP == null ||
        _writeOP.state == OPState.WRITING ||
        _writeOP.state == OPState.COMPLETE) {
      _processNextOP();
    }
    return writeQ.isEmpty; //no more to process
  }

  void _processNextOP() {
    if (writeQ.isEmpty) return;

    _writeOP = writeQ.pop();
    //_logger.finest("Socket to $_saddr, OPState.WRITING: $_writeOP\n");
    _writeOP.nextState();
    List<int> cmd = _writeOP.cmd;
    _socket.add(cmd); //see _setupResponseHandler

    //20130701, henrichen: Tricky! TapAckOP will not have any response from socket
    if (_writeOP == TapAckOP)
      _writeOP.state =
          OPState.COMPLETE; //so next writeOP can be sent to TapServer
  }

  void _setupResponseHandler() {
    _socket.listen(
        (List<int> data) {
          if (data == null || data.length <= 0) {
            //no data
            //_logger.finest("Socket to $_saddr response null!");
            return;
          }

          _pbuf.addAll(data);
          processResponse();
        },
        onError: (err, st) =>
            _logger.warning("Socket to $_saddr response", err, st),
        onDone: () {
          //_logger.finest("Socket to $_saddr closed!");
          _socketClosed();
        });
  }

  //callback when socket was closed
  void _socketClosed();
}

abstract class OPQueue<K, V> {
  /**
   * Peek the first OP in queue; return null if empty.
   */
  V peek([K key]);

  /**
   * Pop the first OP in queue; return null if empty.
   */
  V pop([K key]);

  /**
   * Push OP at the first place of the queue.
   */
  void push(V op, [K key]);

  /**
   * Add OP at the end of the queue.
   */
  void add(V op, [K key]);

  /**
   * Returns whether is queue is empty.
   */
  bool get isEmpty;

  /**
   * Returns the length of the queue.
   */
  int get length;
}

class OPQueueQueue<K, V> implements OPQueue<K, V> {
  final Queue<V> _queue;
  OPQueueQueue() : _queue = new Queue();
  /**
   * Peek the first OP in queue; return null if empty.
   */
  V peek([K key]) => _queue.isEmpty ? null : _queue.first;

  /**
   * Pop the first OP in queue; return null if empty.
   */
  V pop([K key]) => _queue.isEmpty ? null : _queue.removeFirst();

  /**
   * Push OP at the first place of the queue.
   */
  void push(V op, [K key]) => _queue.addFirst(op);

  /**
   * Add OP at the end of the queue.
   */
  void add(V op, [K key]) => _queue.add(op);

  /**
   * Returns whether is queue is empty.
   */
  bool get isEmpty => _queue.isEmpty;

  /**
   * Returns the length of the queue.
   */
  int get length => _queue.length;

  String toString() => _queue.toString();
}

class OPQueueMap<K, V> implements OPQueue<K, V> {
  final Map<K, V> _map;
  OPQueueMap() : _map = new HashMap();
  /**
   * Peek the first OP in queue; return null if empty.
   */
  V peek([K key]) => _map[key];

  /**
   * Pop the first OP in queue; return null if empty.
   */
  V pop([K key]) => _map.remove(key);

  /**
   * Push OP at the first place of the queue.
   */
  void push(V op, [K key]) {
    _map[key] = op;
  }

  /**
   * Add OP at the end of the queue.
   */
  void add(V op, [K key]) {
    _map[key] = op;
  }

  /**
   * Returns whether is queue is empty.
   */
  bool get isEmpty => _map.isEmpty;

  /**
   * Returns the length of the queue.
   */
  int get length => _map.length;

  String toString() => _map.toString();
}

const int _FREQ = 0; //operation process timer frequency
