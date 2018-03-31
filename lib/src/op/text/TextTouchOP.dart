//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Mon, Feb 25, 2013  02:45:21 PM
// Author: hernichen

part of memcached_client;

/** a Touch Operation */
class TextTouchOP extends TextSingleKeyOP implements TouchOP {
  final Completer _cmpl; //completer to complete the future of this operation

  Future<bool> get future => _cmpl.future;

  TextTouchOP(String key, int exp)
      : _cmpl = new Completer(),
        super(key) {
    _cmd = _prepareTouchCommand(key, exp);
  }

  @override
  int handleTextCommand(String line) {
    //_logger.finest("TouchOpCommand: $this, [${line}]\n");
    OPStatus status = TextOPStatus.valueOfError(line);
    if (status != null)
      _cmpl.completeError(new OPStatus.wrap(status, this));
    else {
      OPStatus status = TextOPStatus.valueOf(line);
      if (status == null)
        _cmpl.complete(true);
      else
        _cmpl.completeError(new OPStatus.wrap(status, this));
    }
    return _HANDLE_COMPLETE;
  }

  @override
  int handleData(List<int> data) {
    throw "should never call here!";
  }

  /** Prepare a touch command.
   */
  List<int> _prepareTouchCommand(String key, int exp) {
    List<int> cmd = new List();

    cmd
      ..addAll(UTF8.encode(OPType.touch.name))
      ..add(_SPACE)
      ..addAll(UTF8.encode(key))
      ..add(_SPACE)
      ..addAll(UTF8.encode('$exp'))
      ..addAll(_CRLF);

    //_logger.finest("_prepareTouchCommand:[${UTF8.decode(cmd)}]\n");
    return cmd;
  }
}
