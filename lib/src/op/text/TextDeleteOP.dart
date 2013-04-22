part of memcached_client;

/** A Delete Operation */
class TextDeleteOP extends TextOP implements DeleteOP {
  final Completer<bool> _cmpl; //completer to complete the future of this operation

  Future<bool> get future => _cmpl.future;

  TextDeleteOP(String key)
      : _cmpl = new Completer() {
    _cmd = _prepareDeleteCommand(key);
  }

  //@Override
  int handleTextCommand(String line) {
    _logger.finest("DelOPCommand: $this, [${line}]");
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

  /** Prepare a delete command.
   */
  List<int> _prepareDeleteCommand(String key) {
    List<int> cmd = new List();

    cmd..addAll(encodeUtf8(OPType.delete.name))
       ..add(_SPACE)
       ..addAll(encodeUtf8(key))
       ..addAll(_CRLF);

    _logger.finest("_prepareDeleteCommand:[${decodeUtf8(cmd)}]\n");
    return cmd;
  }

  String toString() => "DeleteOP: $seq";
}


