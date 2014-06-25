//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Mon, Feb 25, 2013  09:12:32 AM
// Author: hernichen

part of memcached_client;

/** A Delete Operation */
class TextDeleteOP extends TextSingleKeyOP implements DeleteOP {
  final Completer<bool> _cmpl; //completer to complete the future of this operation

  Future<bool> get future => _cmpl.future;

  TextDeleteOP(String key)
      : _cmpl = new Completer(),
        super(key) {
    _cmd = _prepareDeleteCommand(key);
  }

  //@Override
  int handleTextCommand(String line) {
    //_logger.finest("DelOPCommand: $this, [${line}]");
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

  //@Override
  int handleData(List<int> data) {
    throw "should never call here!";
  }

  /** Prepare a delete command.
   */
  List<int> _prepareDeleteCommand(String key) {
    List<int> cmd = new List();

    cmd..addAll(UTF8.encode(OPType.delete.name))
       ..add(_SPACE)
       ..addAll(UTF8.encode(key))
       ..addAll(_CRLF);

    //_logger.finest("_prepareDeleteCommand:[${UTF8.decode(cmd)}]\n");
    return cmd;
  }
}


