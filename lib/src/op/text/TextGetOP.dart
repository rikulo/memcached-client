//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Mon, Feb 25, 2013  09:23:12 AM
// Author: hernichen

part of memcached_client;

/** a Get Operation */
class TextGetOP extends TextOP implements GetOP {
  final StreamController<GetResult> _streamCtrl;

  Stream<GetResult> get stream => _streamCtrl.stream;

  TextGetOP(OPType type, List<String> keys)
      : _streamCtrl = new StreamController(sync:true) {
    _cmd = _prepareGetCommand(type, keys);
  }

  //temporary storage
  String _key;
  int _flags;
  int _cas;

  int handleTextCommand(String line) {
    int result = _handleCommand0(line);
    if (result == _HANDLE_COMPLETE) {
      _logger.finest("$this: Close stream");
      _streamCtrl.close();
    }
    return result;
  }

  int _handleCommand0(String line) {
    _logger.finest("GetOpCommand: $this, [${line}]");
    if ("END" == line) {
      return _HANDLE_COMPLETE; //complete
    } else if (line.startsWith("VALUE ")) {
      List<String> items = line.split(' ');
      _key = items[1];
      _flags = int.parse(items[2]);
      int size = int.parse(items[3]);
      _cas = items.length > 4 ? int.parse(items[4]) : null;
      return size;
    } else {
      OPStatus status = TextOPStatus.valueOfError(line);
      if (status != null) { //some error occur!
        _streamCtrl.addError(new OPStatus.wrap(status, this));
        return _HANDLE_COMPLETE; //complete
      }

      //TODO: unknown protocol, try to read thru!
      _streamCtrl.addError(new OPStatus.wrap(new OPStatus(OPStatus.INTERAL_ERROR.code, "PROTOCOL_ERROR 'Unknown get result format:[$line]'"), this));
      return _HANDLE_COMPLETE;
    }
  }

  //Override
  int handleData(List<int> buf) {
    _logger.finest("GetOpCommand: $this, data:$buf");
    _streamCtrl.add(new GetResult(_key, _flags, _cas, buf));
    return _HANDLE_CMD; //handle next line of command
  }

  /** Prepare a multi get command.
   */
  List<int> _prepareGetCommand(OPType type, List<String> keys) {
    List<int> cmd = new List();

    cmd.addAll(encodeUtf8(type.name));
    for(String key in keys) {
      cmd..add(_SPACE)
         ..addAll(encodeUtf8(key));
    }
    cmd.addAll(_CRLF);

    _logger.finest("_prepareGetCommand:[${decodeUtf8(cmd)}]\n");
    return cmd;
  }

  String toString() => "GetOP: $seq";
}
