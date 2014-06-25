//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, May 22, 2013  05:14:11 PM
// Author: hernichen

part of memcached_client;

/** a Unlock Operation */
class TextUnlockOP extends TextSingleKeyOP implements UnlockOP {
  final Completer _cmpl; //completer to complete the future of this operation

  Future<bool> get future => _cmpl.future;

  TextUnlockOP(String key, int cas)
      : _cmpl = new Completer(),
        super(key) {
    _cmd = _prepareUnlockCommand(key, cas);
  }

  @override
  int handleTextCommand(String line) {
    //_logger.finest("UnlockOpCommand: $this, [${line}]\n");
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
  List<int> _prepareUnlockCommand(String key, int cas) {
    List<int> cmd = new List();

    cmd..addAll(encodeUtf8(OPType.unlock.name))
       ..add(_SPACE)
       ..addAll(encodeUtf8(key))
       ..add(_SPACE)
       ..addAll(encodeUtf8('$cas'))
       ..addAll(_CRLF);

    //_logger.finest("_prepareUnlockCommand:[${decodeUtf8(cmd)}]\n");
    return cmd;
  }
}
