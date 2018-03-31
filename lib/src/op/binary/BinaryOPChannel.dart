//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

/**
 * A socket channel that sends OP to server and receive response.
 */
class BinaryOPChannel extends _OPChannelImpl<int> {
  Logger _logger;
  final OPQueue<int, OP> _writeQ;
  final OPQueue<int, OP> _readQ;
  final AuthDescriptor _authDescriptor;
  final BinaryOPFactory _factory;

  int _authRetry; //times of retry to authentication; null means forever.

  static Future<BinaryOPChannel> start(
          SocketAddress saddr, AuthDescriptor authDescriptor,
          {int authRetry}) =>
      _OPChannelImpl._start(
          saddr,
          (Socket socket) =>
              new BinaryOPChannel._(saddr, socket, authDescriptor, authRetry));

  BinaryOPChannel._(SocketAddress saddr, Socket socket,
      AuthDescriptor authDescriptor, int authRetry)
      : _authDescriptor = authDescriptor,
        _authRetry = authRetry,
        _writeQ = new OPQueueQueue(),
        _readQ = new OPQueueMap(),
        _factory = new BinaryOPFactory(),
        super._(saddr, socket) {
    _logger = initLogger("memcached_client.op.binary", this);
  }

  @override
  OPQueue<int, OP> get writeQ => _writeQ;

  @override
  OPQueue<int, OP> get readQ => _readQ;

  bool _authenticated; //whether authenticated

  @override
  bool get isAuthenticated => _authenticated;

  @override
  bool _authenticating = false;

  void authenticate() {
    if (_authDescriptor == null) {
      //no need to do authentication, assume done
      _authenticated = true;
      return;
    } else if (_authenticating) {
      return; //wait authentication to complete
    }

    if (_authRetry == null || _authRetry-- >= 0) {
      SaslAuthOP op = _newAuthOP();

      op.future.then((ok) {
        if (ok) {
          //_logger.finest("authenticated!");
          _authenticated = ok; //fail would keep authenticated == null
        }
      }).catchError(
          (err, st) => _logger.warning("Fail to authenticate", err, st));

      _authenticating = true;
      prependOP(op);
      _processNextOP();
    } else
      throw new StateError('Fail to login "${_saddr.host}:${_saddr.port}" '
          'for bucket "${_authDescriptor.bucket}". '
          'Wrong password?');
  }

  OP _readOP; //current OP to be read from socket
  int _bodylen = _HANDLE_CMD; //control value when do processResponse().
  //Callback listen to onData of the Socket Stream; will call
  //op.handleCommand() and op.handleData() to handle command/data.
  void processResponse() {
    //_logger.finest("pbuf:$_pbuf");
    while (true) {
      //handle response header
      if (_bodylen == _HANDLE_CMD) {
        if (_pbuf.length < 24) {
          //not enough header for processing
          break;
        } else {
          List<int> aLine = _pbuf.sublist(0, 24);
          int opaque = _getOpaque(aLine);
          //20130628, henrichen: Tricky! TapOP is special,seq does not necessary match!
          if (_readOP is TapRequestOP && _readOP.state == OPState.READING) {
            //_logger.finest("Streaming _readOP:${_readOP}");
          } else if (_writeOP is! TapOP) {
            //(multiple getkq + noop) could return same seq number
            if (_readOP == null || opaque != _readOP.seq) {
              _readOP = readQ.pop(opaque);
              _readOP.nextState();
            }
          } else {
            _readOP = _writeOP;
            _writeOP =
                null; //so TapAckOP after TapRequestOP can be sent to Tap server
            _readOP
                .nextState(); //so we kept the TapRequestOP.state at "READING"
            //_logger.finest("_readOP:${_readOP}, _readOP.state:${_readOP.state}");
          }
          _bodylen = _readOP.handleCommand(aLine);
          _pbuf.removeRange(0, 24);
        }
      }

      //handle data
      if (_bodylen >= 0) {
        if (_pbuf.length < _bodylen) {
          //not enough data for processing
          break;
        } else {
          List<int> aLine = _pbuf.sublist(0, _bodylen);
          _pbuf.removeRange(0, _bodylen);
          _bodylen = _readOP.handleData(aLine);
        }
      }

      //check if complete
      if (_bodylen == _HANDLE_COMPLETE) {
        //complete, reset parser
        _bodylen = _HANDLE_CMD;
        //_logger.finest("_HANDLE_COMPLETE: $_readOP\n");
        _readOP.complete();

        //close this channel if all processed
        if (_readOP.state == OPState.COMPLETE) _tryClose();
      }
    }
  }

  //Create an Authentication Operation
  SaslAuthOP _newAuthOP() {
    List<int> userlist = UTF8.encode(_authDescriptor.bucket);
    List<int> passlist = UTF8.encode(_authDescriptor.password);
    List<int> bytes = new Uint8List(2 + userlist.length + passlist.length);
    copyList(userlist, 0, bytes, 1, userlist.length);
    copyList(passlist, 0, bytes, 1 + userlist.length + 1, passlist.length);

    SaslAuthOP op = _factory.newSaslAuthOP("PLAIN", bytes);

    return op;
  }

  //Retreive opaque value from memcached's binary response header
  int _getOpaque(List<int> aLine) => bytesToInt32(aLine, 12);

  //callback when socket closed
  void _socketClosed() {
    if (_readOP is TapRequestOP) (_readOP as TapRequestOP).socketClosed();
  }
}
