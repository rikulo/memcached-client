//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

/** A get operation of binary protocol */
class BinaryGetAndLockOP extends SingleKeyOP implements GetAndLockOP {
  final Completer<GetResult> _cmpl;

  Future<GetResult> get future => _cmpl.future;

  BinaryGetAndLockOP(String key, int exp)
      : _cmpl = new Completer(),
        super(key) {
    _cmd = _prepareGetAndLockCommand(key, exp);
  }

  //@Override
  int handleData(List<int> line) {
    _logger.finest("BinaryGetAndLockOPData: $this, $line.");
    if (_status != 0)
      _cmpl.completeError(OPStatus.valueOf(_status));
    else {
      int extralen = 4;
      int flags = bytesToInt32(line, 0);
      List<int> key = new Uint8List(_keylen);
      int valuelen = _bodylen - _keylen - extralen;
      List<int> val = new Uint8List(valuelen);
      if (_keylen > 0)
        copyList(line, extralen, key, 0, _keylen);
      if (valuelen > 0)
        copyList(line, extralen + _keylen, val, 0, valuelen);
      _cmpl.complete(new GetResult(decodeUtf8(key), flags, _cas, val));
    }

    return _HANDLE_COMPLETE;
  }

  //Prepare one getk command
  const int _req_extralen = 4;
  List<int> _prepareGetAndLockCommand(String key, int exp) {
    List<int> keybytes = encodeUtf8(key);
    int keylen = keybytes.length;
    int valuelen = 0;
    int bodylen = _req_extralen + keylen + valuelen;

    Uint8List cmd = new Uint8List(24 + bodylen);
    //0, 1 byte: Magic byte of request
    cmd[0] = _MAGIC_REQ;
    //1, 1 byte: Opcode
    cmd[1] = OPType.getl.ordinal;
    //2, 2 bytes: Key length
    copyList(int16ToBytes(keylen), 0, cmd, 2, 2);
    //4, 2 bytes: extra length
    copyList(int8ToBytes(_req_extralen), 0, cmd, 4, 1);
    //6, 2 bytes: vBucket id
    //8, 4 bytes: total body length
    copyList(int32ToBytes(bodylen), 0, cmd, 8, 4);
    //12, 4 bytes: Opaque
    //16, 8 bytes: CAS
    //24, _req_extralen: extra
    //exp
    copyList(int32ToBytes(exp), 0, cmd, 24, 4);
    //24+_req_extralen, keylen: key
    copyList(keybytes, 0, cmd, 24 + _req_extralen, keylen);
    //24+_req_extralen+keylen, valuelen
    _logger.finest("_prepareGetAndLockCommand:$cmd");
    return cmd;
  }

  String toString() => "BinaryGetAndLockOP: $seq";
}
