//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, May 24, 2013  11:51:13 PM
// Author: hernichen

part of memcached_client;

/** A KeyStats operation of binary protocol */
class BinaryKeyStatsOP extends SingleKeyOP implements KeyStatsOP {
  final Completer<Map<String, String>> _cmpl;
  final Map<String, String> _stats;

  BinaryKeyStatsOP(String key)
      : _cmpl = new Completer(),
        _stats = new HashMap(),
        super(key);

  //-- KeyStatsOP --//
  //@Override
  Future<Map<String, String>> get future => _cmpl.future;

  //@Override
  int handleData(List<int> line) {
    _logger.finest("BinaryKeyStatsOPData: $this, $line.");

    if (_keylen > 0) { //not the last packet
      if (_status != 0) {
        _cmpl.completeError(new OPStatus.wrap(OPStatus.valueOf(_status), this));
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
        _cmpl.completeError(new OPStatus.wrap(OPStatus.valueOf(_status), this));
      } else {
        _cmpl.complete(_stats);
      }
      return _HANDLE_COMPLETE; //complete
    }
  }

  //--VbucketAwareOP--//
  //@Override
  void setVbucketID(Map<String, int> ids) {
    final int id = ids.values.first;
    _vbucketID = id;
    final keyval = "key $key $id";
    _cmd = _prepareKeyStatsCommand(keyval);
  }

  static const int _req_extralen = 0;
  /**
   * Prepare a store command.
   */
  List<int> _prepareKeyStatsCommand(String key) {
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
    if (_vbucketID != 0)
      copyList(int16ToBytes(_vbucketID), 0, cmd, 6, 2);
    //8, 4 bytes: total body length
    copyList(int32ToBytes(bodylen), 0, cmd, 8, 4);
    //12, 4 bytes: Opaque
    //16, 8 bytes: CAS
    //24, _req_extralen: extra
    //24+_req_extralen, keylen: key
    if (keylen > 0)
      copyList(keybytes, 0, cmd, 24 + _req_extralen, keylen);
    //24+_req_extralen+keylen, valuelen
    _logger.finest("_prepareKeyStatsCommand:$cmd");
    return cmd;
  }

  String toString() => "BinaryKeyStatsOP: $seq";
}
