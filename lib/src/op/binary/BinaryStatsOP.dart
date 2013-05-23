//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, May 23, 2013  02:56:34 PM
// Author: hernichen

part of memcached_client;

/** A stats operation of binary protocol */
class BinaryStatsOP extends BinaryOP implements StatsOP {
  final Completer<Map<String, String>> _cmpl;
  final Map<String, String> _stats;

  BinaryStatsOP(String key)
      : _cmpl = new Completer(),
        _stats = new HashMap() {
    _cmd = _prepareStatsCommand(key);
  }

  //-- StatsOP --//
  //@Override
  Future<Map<String, String>> get future => _cmpl.future;

  //@Override
  int handleData(List<int> line) {
    _logger.finest("BinaryStatsOPData: $this, $line.");

    if (_keylen > 0) { //not the last packet
      if (_status != 0) {
        _cmpl.completeError(OPStatus.valueOf(_status));
      } else {
        int extralen = 0;
        int flags = bytesToInt32(line, 0);
        List<int> key = new Uint8List(_keylen);
        int valuelen = _bodylen - _keylen;
        List<int> val = new Uint8List(valuelen);
        copyList(line, extralen, key, 0, _keylen);
        if (valuelen > 0)
          copyList(line, _keylen, val, 0, valuelen);
        _stats[decodeUtf8(key)] = valuelen > 0 ? decodeUtf8(val) : null;
      }
      return _HANDLE_CMD; //handle next line of command
    } else { //last packet!
      if (_status != 0) {
        _cmpl.completeError(OPStatus.valueOf(_status));
      } else {
        _cmpl.complete(_stats);
      }
      return _HANDLE_COMPLETE; //complete
    }
  }

  const int _req_extralen = 0;
  /**
   * Prepare a store command.
   */
  List<int> _prepareStatsCommand(String key) {
    List<int> keybytes = key == null ? new List(0) : encodeUtf8(key);
    int keylen = keybytes.length;
    int bodylen = _req_extralen + keylen;

    Uint8List cmd = new Uint8List(24 + bodylen);
    //0, 1 byte: Magic byte of request
    cmd[0] = _MAGIC_REQ;
    //1, 1 byte: Opcode
    cmd[1] = OPType.stats.ordinal;
    //2, 2 bytes: Key length
    if (keylen > 0)
      copyList(int16ToBytes(keylen), 0, cmd, 2, 2);
    //4, 2 bytes: extra length
    //6, 2 bytes: vBucket id
    //8, 4 bytes: total body length
    copyList(int32ToBytes(bodylen), 0, cmd, 8, 4);
    //12, 4 bytes: Opaque
    //16, 8 bytes: CAS
    //24, _req_extralen: extra
    //24+_req_extralen, keylen: key
    if (keylen > 0)
      copyList(keybytes, 0, cmd, 24 + _req_extralen, keylen);
    //24+_req_extralen+keylen, valuelen
    _logger.finest("_prepareStatsCommand:$cmd");
    return cmd;
  }

  String toString() => "BinaryStatsOP: $seq";
}
