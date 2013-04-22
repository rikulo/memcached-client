//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

/** A get operation of binary protocol */
class BinaryGetOP extends BinaryOP implements GetOP {
  final StreamController<GetResult> _streamCtrl;

  List<OPStatus> _errors; //accumulated errors, if any
  final bool _ignoreCas;
  final List<int> _cmdOffsets;

  BinaryGetOP(OPType type, List<String> keys)
      : _streamCtrl = new StreamController(),
        _ignoreCas = type == OPType.get,
        _cmdOffsets = new List(keys.length + 1) {
    _cmd = _prepareGetCommand(keys);
    _errors = new List();
  }

  //-- GetOP --//
  //@Override
  Stream<GetResult> get stream => _streamCtrl.stream;

  //@Override
  void set seq(int s) {
    //opacque field for this OP(multiple getkq + noop)
    List<int> src = int32ToBytes(s);
    for(int offset in _cmdOffsets)
      copyList(src, 0, _cmd, offset + 12, 4);
    _seq= s;
  }

  //@Override
  void set vbucketID(int id) {
    //vbucketID field for this OP(multiple getkq + noop)
    List<int> src = int16ToBytes(id);
    for(int offset in _cmdOffsets)
      copyList(src, 0, _cmd, offset + 6, 2);
  }

  //@Override
  int handleData(List<int> line) {
    _logger.finest("BinaryGetOPData: $this, $line.");

    if (_opCode == OPType.getkq.ordinal) {
      if (_status != 0) {
        _errors.add(OPStatus.valueOf(_status));
      } else {
        int extralen = 4;
        int flags = bytesToInt32(line, 0);
        List<int> key = new Uint8List(_keylen);
        int valuelen = _bodylen - _keylen - extralen;
        List<int> val = new Uint8List(valuelen);
        if (_keylen > 0)
          copyList(line, extralen, key, 0, _keylen);
        if (valuelen > 0)
          copyList(line, extralen + _keylen, val, 0, valuelen);
        _streamCtrl.add(new GetResult(decodeUtf8(key), flags, _ignoreCas ? null : _cas, val));
      }
      return _HANDLE_CMD; //handle next line of command
    } else { //noop, last packet!
      if (_status != 0) {
        _errors.add(OPStatus.valueOf(_status));
      }

      if (!_errors.isEmpty) {
        _streamCtrl.addError(_errors);
      }

      _streamCtrl.close();
      return _HANDLE_COMPLETE; //complete
    }
  }

  /** Prepare n getkq commands + one noop command.
   */
  List<int> _prepareGetCommand(List<String> keys) {
    List<int> multicmds = new List();
    int len = keys.length;
    int j = 0;
    for(String key in keys) {
      _cmdOffsets[j++] = multicmds.length;
      multicmds.addAll(_prepareGetKQCommand(key));
    }
    _cmdOffsets[j] = multicmds.length;
    multicmds.addAll(_prepareNoopCommand());
    return multicmds;
  }

  //Prepare Noop command
  List<int> _prepareNoopCommand() {
    Uint8List cmd = new Uint8List(24);
    //0, 1 byte: Magic byte of request
    cmd[0] = _MAGIC_REQ;
    //1, 1 byte: Opcode
    cmd[1] = OPType.noop.ordinal;

    _logger.finest("_prepareNoopCommand:$cmd");
    return cmd;
  }

  //Prepare one getkq command
  const int _req_extralen = 0;
  List<int> _prepareGetKQCommand(String key) {
    List<int> keybytes = encodeUtf8(key);
    int keylen = keybytes.length;
    int valuelen = 0;
    int bodylen = _req_extralen + keylen + valuelen;

    Uint8List cmd = new Uint8List(24 + bodylen);
    //0, 1 byte: Magic byte of request
    cmd[0] = _MAGIC_REQ;
    //1, 1 byte: Opcode
    cmd[1] = OPType.getkq.ordinal;
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
    _logger.finest("_prepareGetKQCommand:$cmd");
    return cmd;
  }

  String toString() => "BinaryGetOP: $seq";
}
