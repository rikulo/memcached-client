//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Mon, Feb 25, 2013  10:46:09 AM
// Author: hernichen

part of memcached_client;

/** a Mutate(increment/decrement) Operation */
class TextMutateOP extends TextOP implements MutateOP {
  final Completer<int> _cmpl; //completer to complete the future of this operation

  Future<int> get future => _cmpl.future;

  TextMutateOP(OPType type, String key, int by, int def, int exp)
      : _cmpl = new Completer() {
    _cmd = _prepareMutateCommand(type, key, by);
  }

  //@Override
  int handleTextCommand(String line) {
    _logger.finest("MutateOpCommand: $this, [${line}]\n");
    OPStatus status = TextOPStatus.valueOfError(line);
    if (status != null)
      _cmpl.completeError(new OPStatus.wrap(status, this));
    else {
      OPStatus status = TextOPStatus.valueOf(line);
      if (status == null) //assume return the result number
        _cmpl.complete(int.parse(line));
      else
        _cmpl.completeError(new OPStatus.wrap(status, this));
    }
    return _HANDLE_COMPLETE;
  }

  //@Override
  int handleData(List<int> data) {
    throw "should never call here!";
  }

  /** Prepare a store command. [type] is the store type.
   */
  List<int> _prepareMutateCommand(OPType type, String key, int by) {
    List<int> cmd = new List();

    cmd..addAll(encodeUtf8(type.name))
       ..add(_SPACE)
       ..addAll(encodeUtf8(key))
       ..add(_SPACE)
       ..addAll(encodeUtf8('$by'))
       ..addAll(_CRLF);

    _logger.finest("_prepareMutateCommand:[${decodeUtf8(cmd)}]\n");
    return cmd;
  }

  String toString() => "MutateOP: $seq";
}


