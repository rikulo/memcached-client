//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Mon, Feb 25, 2013  10:12:43 AM
// Author: hernichen

part of memcached_client;

/** a Get Operation */
class TextGetSingleOP extends TextOP implements GetSingleOP {
  final Completer<GetResult> _cmpl;

  Future<GetResult> get future => _cmpl.future;

  TextGetSingleOP(OPType type, String key)
      : _cmpl = new Completer() {
    _cmd = _prepareGetCommand(type, key);
  }

  //temporary storage
  String _key;
  int _flags;
  int _cas;
  bool _hasValue = false;

  int handleTextCommand(String line) {
    _logger.finest("GetSingleOpCommand: $this, [${line}]");
    if ("END" == line) {
      if (!_hasValue)
        _cmpl.completeError(new OPStatus.wrap(OPStatus.KEY_NOT_FOUND, this));
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
        _cmpl.completeError(new OPStatus.wrap(status, this));
        return _HANDLE_COMPLETE; //complete
      }

      //TODO: unknown protocol, try to read thru!
      _cmpl.completeError(new OPStatus.wrap(new OPStatus(OPStatus.INTERAL_ERROR.code, "PROTOCOL_ERROR 'Unknown get result format:[$line]'"), this));
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
  List<int> _prepareGetCommand(OPType type, String key) {
    List<int> cmd = new List();

    cmd..addAll(encodeUtf8(type.name))
       ..add(_SPACE)
       ..addAll(encodeUtf8(key))
       ..addAll(_CRLF);

    _logger.finest("_prepareGetCommand:[${decodeUtf8(cmd)}]\n");
    return cmd;
  }

  String toString() => "GetSingleOP: $seq";
}
