//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, May 22, 2013  06:09:34 PM
// Author: hernichen

part of memcached_client;

/** A version command of binary protocol */
class BinaryNoOP extends BinaryOP implements NoOP {
  final Completer<bool> _cmpl; //completer to complete the future of this operation

  Future<bool> get future => _cmpl.future;

  BinaryNoOP()
      : _cmpl = new Completer() {
    _cmd = _prepareNoCommand();
  }

  //@Override
  int handleData(List<int> line) {
    print("BinaryNoOpData: $this, $line\n");
    if (_status != 0)
      _cmpl.completeError(new OPStatus.wrap(OPStatus.valueOf(_status), this));
    else {
      _cmpl.complete(true);
    }

    return _HANDLE_COMPLETE;
  }

  List<int> _prepareNoCommand() {
    Uint8List cmd = new Uint8List(24);
    //0, 1 byte: Magic byte of request
    cmd[0] = _MAGIC_REQ;
    //1, 1 byte: Opcode
    cmd[1] = OPType.noop.ordinal;

    print("_prepareNoCommand:$cmd\n");
    return cmd;
  }

  String toString() => "BinaryNoOP: $seq";
}
