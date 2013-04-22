//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 15, 2013  03:02:34 PM
// Author: hernichen

part of memcached_client;

abstract class SaslOP extends BinaryOP implements FutureOP<bool> {
  Completer<bool> _cmpl; //completer to complete the future of this operation

  Future<bool> get future => _cmpl.future;

  SaslOP(OPType type, String mechanism, List<int> authData)
      : _cmpl = new Completer() {
    _cmd = _prepareSaslCommand(type, mechanism, authData);
  }

  static const int _req_extralen = 0;

  List<int> _prepareSaslCommand(OPType type, String key, List<int> val) {
    List<int> keybytes = encodeUtf8(key);
    int keylen = keybytes.length;
    int valuelen = val.length;
    int bodylen = _req_extralen + keylen + valuelen;

    Uint8List cmd = new Uint8List(24 + bodylen);
    //0, 1 byte: Magic byte of request
    cmd[0] = _MAGIC_REQ;
    //1, 1 byte: Opcode
    cmd[1] = type.ordinal;
    //2, 2 bytes: Key length
    copyList(int16ToBytes(keylen), 0, cmd, 2, 2);
    //4, 2 bytes: extra length
    //6, 2 bytes: vBucket id
    //8, 4 bytes: total body length
    copyList(int32ToBytes(bodylen), 0, cmd, 8, 4);
    //12, 4 bytes: Opaque
    //16, 8 bytes: CAS
    //24, _req_extralen: extra
    //24+_req_extralen, keylen: key
    copyList(keybytes, 0, cmd, 24 + _req_extralen, keylen);
    //24+_req_extralen+keylen, valuelen
    if (valuelen != null && 0 != valuelen)
      copyList(val, 0, cmd, 24 + _req_extralen + keylen, valuelen);
    return cmd;
  }
}

