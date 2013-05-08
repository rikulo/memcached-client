//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

abstract class BinaryOP extends OP {
  Logger _logger;
  List<int> _cmd; //command in a byte array
  OPState _state; //null is state 0

  BinaryOP() {
    _logger = initLogger('memcached_client.op.binary', this);
  }

  OPState get state => _state;

  void set state(OPState s) {
    _state = s;
  }

  int _seq;

  int get seq => _seq;

  void set seq(int s) {
    //opacque field
    copyList(int32ToBytes(s), 0, _cmd, 12, 4);
    _seq= s;
  }

  List<int> get cmd => _cmd;

  //--VbucketAwareOP--//

  //response header command
  int _opCode;
  int _keylen;
  int _extralen;
  int _dataType;
  int _status;
  int _vbucket;
  int _bodylen = _HANDLE_CMD; //== total body length
  int _opaque;
  int _cas;

  int handleCommand(List<int> aLine) {
    _logger.finest('response header: $aLine');

    _opCode = bytesToInt8(aLine, 1);
    _keylen = bytesToInt16(aLine, 2);
    _extralen = bytesToInt8(aLine, 4);
    _dataType = bytesToInt8(aLine, 5);
    _status = bytesToInt16(aLine, 6);
    _bodylen = bytesToInt32(aLine, 8);
    _opaque = bytesToInt32(aLine, 12);
    _cas = bytesToInt64(aLine, 16);

    return _bodylen;
  }
}

const _MAGIC_REQ = 0x80; //request magic byte for binary packet of this version
const _MAGIC_RES = 0x81; //response magic byte for binary packet of this version
