//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

/**
 * A socket channel that sends OP to server and receive response.
 */
class TextOPChannel extends _OPChannelImpl<int> {
  Logger _logger;
  final OPQueue<int, OP> _writeQ;
  final OPQueue<int, OP> _readQ;

  OP _readOP; //current OP to be read from socket

  static Future<TextOPChannel> start(SocketAddress saddr) => _OPChannelImpl
      ._start(saddr, (Socket socket) => new TextOPChannel._(saddr, socket));

  TextOPChannel._(SocketAddress saddr, Socket socket)
      : _writeQ = new OPQueueQueue(),
        _readQ = new OPQueueQueue(),
        super._(saddr, socket) {
    _logger = initLogger("memcached_client.op.text", this);
  }

  @override
  OPQueue<int, OP> get writeQ => _writeQ;

  @override
  OPQueue<int, OP> get readQ => _readQ;

  @override
  bool get isAuthenticated => true;

  @override
  void authenticate() {
    //Should never call here
    throw new StateError("Should never call authenticate in Text protocol");
  }

  int _crj = -2, //CR code position
      _offset = 0, //offset to the already parsed response buffer
      _size = _HANDLE_CMD; //the data block size to read data block
  //Callback listen to onData of the Socket Stream; will call
  //handleCommand() and handleData() to handle command/data.
  @override
  void processResponse() {
    //_logger.finest("processResponse:\n${UTF8.decode(_pbuf)}");
    bool more = true;
    while (more) {
      int el = _size >= 0 ? _size : _HANDLE_CMD; //expected end of line
      int end = _pbuf.length;
      int j = _offset;
      //parse lines in buf
      for (; j < end; ++j) {
        if (_pbuf[j] == _CR)
          _crj = j;
        else if (_pbuf[j] == _LF &&
            (_crj + 1) == j &&
            (el < 0 || j == el + 1)) {
          //find the end of line "\r\n"
          _crj = -2; //reset _crj
          el = j + 1; //including ending CRLF

          //process a line
          List<int> aLine = _pbuf.sublist(0, el - 2); //exclude ending CRLF
          _pbuf.removeRange(0, el); //remove processed line
          _offset = 0; //reset _offset
          if (_readOP == null || _readOP.state == OPState.COMPLETE) {
            _readOP = readQ.pop();
            _readOP.nextState();
          }

          _size = _size >= 0
              ? _readOP.handleData(aLine)
              : //handle data block
              _readOP.handleCommand(aLine); //handle command line

          //prepare next line
          if (_size == _HANDLE_COMPLETE) {
            _size = _HANDLE_CMD;
            //_logger.finest("_HANDLE_COMPLETE: $_readOP\n");
            _readOP.complete();

            //close this channel if all processed
            if (_readOP.state == OPState.COMPLETE) _tryClose();
          }

          break;
        }
      }

      if ((j + 1) < end) {
        //still data in _pbuf not read yet!
        more = true;
      } else {
        //read all in _pbuf (_pbuf.length might change)
        more = false;
        _offset = _pbuf.length;
      }
    }
  }

  //callback when socket closed
  void _socketClosed() {
    //TODO: do nothing in the moment
  }
}
