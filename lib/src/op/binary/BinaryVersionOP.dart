//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Apr 10, 2013  10:23:09 AM
// Author: hernichen

part of memcached_client;

/** A version command of binary protocol */
class BinaryVersionOP extends BinaryOP implements VersionOP {
  final Completer<String> _cmpl; //completer to complete the future of this operation

  Future<String> get future => _cmpl.future;

  BinaryVersionOP()
      : _cmpl = new Completer() {
    _cmd = _prepareVersionCommand();
  }

  //@Override
  int handleData(List<int> line) {
    print("BinaryVersionOpData: $this, $line\n");
    if (_status != 0)
      _cmpl.completeError(OPStatus.valueOf(_status));
    else {
      _cmpl.complete(decodeUtf8(line));
    }

    return _HANDLE_COMPLETE;
  }

  List<int> _prepareVersionCommand() {
    Uint8List cmd = new Uint8List(24);
    //0, 1 byte: Magic byte of request
    cmd[0] = _MAGIC_REQ;
    //1, 1 byte: Opcode
    cmd[1] = OPType.version.ordinal;

    print("_prepareVersionCommand:$cmd\n");
    return cmd;
  }

  String toString() => "BinaryVersionOP: $seq";
}
