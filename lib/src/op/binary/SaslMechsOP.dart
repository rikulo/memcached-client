//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 15, 2013  03:35:02 PM
// Author: hernichen

part of memcached_client;

class SaslMechsOP extends BinaryOP implements FutureOP<List<String>> {
  final Completer<List<String>> _cmpl; //completer to complete the future of this operation

  Future<List<String>> get future => _cmpl.future;

  SaslMechsOP()
      : _cmpl = new Completer() {
    _cmd = _prepareSaslMechsCommand();
  }

  @override
  int handleData(List<int> line) {
    //_logger.finest("SaslMechsOPData: $this, ${UTF8.decode(line)}\n");
    if (_status != 0)
      _cmpl.completeError(new OPStatus.wrap(OPStatus.valueOf(_status), this));
    else {
      String val = UTF8.decode(line);
      _cmpl.complete(val.split(' '));
    }

    return _HANDLE_COMPLETE;
  }

  static const int _req_extralen = 0;

  List<int> _prepareSaslMechsCommand() {
//    int keylen = 0;
//    int valuelen = 0;
//    int bodylen = _req_extralen + keylen + valuelen;

    Uint8List cmd = new Uint8List(24);
    //0, 1 byte: Magic byte of request
    cmd[0] = _MAGIC_REQ;
    //1, 1 byte: Opcode
    cmd[1] = OPType.saslMechs.ordinal;
    //2, 2 bytes: Key length
    //4, 2 bytes: extra length
    //6, 2 bytes: vBucket id
    //8, 4 bytes: total body length
    //12, 4 bytes: Opaque
    //16, 8 bytes: CAS
    //24, _req_extralen: extra
    //24+_req_extralen, keylen: key
    //24+_req_extralen+keylen, valuelen
    //_logger.finest("_prepareSaslMechsCommand:$cmd\n");
    return cmd;
  }
}


