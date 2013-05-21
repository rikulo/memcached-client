part of memcached_client;

/** a Get Operation */
class TextGetAndLockOP extends TextOP implements GetAndLockOP {
  final Completer<GetResult> _cmpl;

  Future<GetResult> get future => _cmpl.future;

  TextGetAndLockOP(String key, int exp)
      : _cmpl = new Completer() {
    _cmd = _prepareGetAndLockCommand(key, exp);
  }

  //temporary storage
  String _key;
  int _flags;
  int _cas;
  bool _hasValue = false;

  int handleTextCommand(String line) {
    _logger.finest("GetAndLockOpCommand: $this, [${line}]");
    if ("END" == line) {
      if (!_hasValue)
        _cmpl.completeError(OPStatus.KEY_NOT_FOUND);
      return _HANDLE_COMPLETE; //complete
    } else if (line.startsWith("VALUE ")) {
      List<String> items = line.split(' ');
      _key = items[1];
      _flags = int.parse(items[2]);
      int size = int.parse(items[3]);
      _cas = items.length > 4 ? int.parse(items[4]) : null;
      _hasValue = true;
      return size;
    } else {
      OPStatus status = TextOPStatus.valueOfError(line);
      if (status != null) { //some error occur!
        _cmpl.completeError(status);
        return _HANDLE_COMPLETE; //complete
      }

      //TODO: unknown protocol, try to read thru!
      _cmpl.completeError(new OPStatus(OPStatus.INTERAL_ERROR.code, "PROTOCOL_ERROR 'Unknown get result format:[$line]'"));
      return _HANDLE_COMPLETE;
    }
  }

  //Override
  int handleData(List<int> buf) {
    _cmpl.complete(new GetResult(_key, _flags, _cas, buf));
    return _HANDLE_CMD; //handle next line of command
  }

  /** Prepare a get command.
   */
  List<int> _prepareGetAndLockCommand(String key, int exp) {
    List<int> cmd = new List();

    cmd..addAll(encodeUtf8(OPType.getl.name))
       ..add(_SPACE)
       ..addAll(encodeUtf8(key))
       ..add(_SPACE)
       ..addAll(encodeUtf8('$exp'))
       ..addAll(_CRLF);

    _logger.finest("_prepareGetAndLockCommand:[${decodeUtf8(cmd)}]\n");
    return cmd;
  }

  String toString() => "GetAndLockOP: $seq";
}
