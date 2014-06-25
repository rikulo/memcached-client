//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, May 23, 2013  02:56:34 PM
// Author: hernichen

part of memcached_client;

/** A tap ack operation sent back to Tap server */
class TapAckOP extends TapOP implements FutureOP<bool> {
  final int _opaque;
  final Completer<bool> _cmpl;

  TapAckOP(TapOpcode opcode, int opaque)
      : _cmpl = new Completer(),
        _opaque = opaque {
    _cmd = _prepareTapAckCommand(opcode, opaque);
  }

  int get seq => _opaque;

  //-- TapAckOP --//
  @override
  Future<bool> get future => _cmpl.future;

  @override
  int handleData(List<int> line) {
    //_logger.finest("TapAckOPData: $this, $line.");
    _cmpl.complete(true);
    return _HANDLE_COMPLETE; //complete
  }

  static const int _req_extralen = 0;
  /**
   * Prepare a store command.
   */
  List<int> _prepareTapAckCommand(TapOpcode opcode, int opaque) {
    List<int> keybytes = UTF8.encode(_uuid());
    int keylen = keybytes.length;
    int bodylen = _req_extralen + keylen;

    Uint8List cmd = new Uint8List(24 + bodylen);
    //0, 1 byte: Magic byte of request
    cmd[0] = _MAGIC_REQ;
    //1, 1 byte: Opcode
    cmd[1] = opcode.opcode;
    //2, 2 bytes: Key length
    if (keylen > 0)
      copyList(int16ToBytes(keylen), 0, cmd, 2, 2);
    //4, 2 bytes: extra length
    //6, 2 bytes: vBucket id
    //8, 4 bytes: total body length
    copyList(int32ToBytes(bodylen), 0, cmd, 8, 4);
    //12, 4 bytes: Opaque
    copyList(int32ToBytes(opaque), 0, cmd, 12, 4);
    //16, 8 bytes: CAS
    //24, _req_extralen: extra
    //24+_req_extralen, keylen: key
    if (keylen > 0)
      copyList(keybytes, 0, cmd, 24 + _req_extralen, keylen);
    //24+_req_extralen+keylen, valuelen
    //_logger.finest("_prepareTapAckCommand:$cmd");
    return cmd;
  }
}
