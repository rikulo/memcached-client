part of memcached_client;

/** a Unlock Operation */
class TextUnlockOP extends TextOP implements UnlockOP {
  final Completer _cmpl; //completer to complete the future of this operation

  Future<bool> get future => _cmpl.future;

  TextUnlockOP(String key, int cas)
      : _cmpl = new Completer() {
    _cmd = _prepareUnlockCommand(key, cas);
  }

  //@Override
  int handleTextCommand(String line) {
    _logger.finest("UnlockOpCommand: $this, [${line}]\n");
    OPStatus status = TextOPStatus.valueOfError(line);
    if (status != null)
      _cmpl.completeError(status);
    else {
      OPStatus status = TextOPStatus.valueOf(line);
      if (status == null)
        _cmpl.complete(true);
      else
        _cmpl.completeError(status);
    }
    return _HANDLE_COMPLETE;
  }

  //@Override
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

    _logger.finest("_prepareUnlockCommand:[${decodeUtf8(cmd)}]\n");
    return cmd;
  }

  String toString() => "UnlockOP: $seq";
}
