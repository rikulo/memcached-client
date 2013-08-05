//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Mon, Feb 25, 2013  03:09:01 PM
// Author: hernichen

part of memcached_client;

class TextVersionOP extends TextOP implements VersionOP {
  final Completer<String> _cmpl; //completer to complete the future of this operation

  Future<String> get future => _cmpl.future;

  TextVersionOP()
      : _cmpl = new Completer() {
    _cmd = _prepareVersionCommand();
  }

  //@Override
  static final int VERSION_PREFIX_LEN = 'VERSION '.length;
  int handleTextCommand(String line) {
    _logger.finest("VersionOpCommand: $this, [${line}]\n");
    OPStatus status = TextOPStatus.valueOfError(line);
    if (status != null)
      _cmpl.completeError(new OPStatus.wrap(status, this));
    else {
      _cmpl.complete(line.substring(VERSION_PREFIX_LEN));
    }
    return _HANDLE_COMPLETE;
  }

  //@Override
  int handleData(List<int> data) {
    throw "should never call here!";
  }

  List<int> _prepareVersionCommand() {
    List<int> cmd = new List();

    cmd..addAll(encodeUtf8(OPType.version.name))
       ..addAll(_CRLF);

    _logger.finest("_prepareVersionCommand:[${decodeUtf8(cmd)}]\n");
    return cmd;
  }

  String toString() => "VersionOP: $seq";
}



