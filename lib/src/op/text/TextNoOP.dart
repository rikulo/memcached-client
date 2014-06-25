//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, May 22, 2013  11:32:01 AM
// Author: hernichen

part of memcached_client;

class TextNoOP extends TextOP implements NoOP {
  final Completer<bool> _cmpl; //completer to complete the future of this operation

  Future<bool> get future => _cmpl.future;

  TextNoOP()
      : _cmpl = new Completer() {
    _cmd = _prepareNoCommand();
  }

  @override
  static final int VERSION_PREFIX_LEN = 'VERSION '.length;
  int handleTextCommand(String line) {
    //_logger.finest("NoOpCommand: $this, [${line}]\n");
    OPStatus status = TextOPStatus.valueOfError(line);
    if (status != null)
      _cmpl.completeError(new OPStatus.wrap(status, this));
    else {
      _cmpl.complete(true);
    }
    return _HANDLE_COMPLETE;
  }

  @override
  int handleData(List<int> data) {
    throw "should never call here!";
  }

  List<int> _prepareNoCommand() {
    List<int> cmd = new List();

    //Use version as noop command in Text protocol
    cmd..addAll(UTF8.encode(OPType.version.name))
       ..addAll(_CRLF);

    //_logger.finest("_prepareNoCommand:[${UTF8.decode(cmd)}]\n");
    return cmd;
  }
}



