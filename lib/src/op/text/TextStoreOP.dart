part of memcached_client;

/** a Store Operation */
class TextStoreOP extends TextOP implements StoreOP {
  final Completer _cmpl; //completer to complete the future of this operation
  final OPType _type;

  Future<bool> get future => _cmpl.future;

  TextStoreOP(OPType type, String key, int flags, int exp, List<int> doc,
      int cas)
      : _type = type,
        _cmpl = new Completer() {
    _cmd = _prepareStoreCommand(type, key, flags, exp, doc, cas);
  }

  //@Override
  int handleTextCommand(String line) {
    _logger.finest("StoreOpCommand: $this, [${line}]\n");
    OPStatus status = TextOPStatus.valueOfError(line);
    if (status != null)
      _cmpl.completeError(status);
    else {
      OPStatus status = TextOPStatus.valueOf(line);
      if (status == null)
        _cmpl.complete(true);
      else
        _cmpl.completeError(status != OPStatus.ITEM_NOT_STORED ? status :
            _type == OPType.add ? OPStatus.KEY_EXISTS :
            _type == OPType.replace ? OPStatus.KEY_NOT_FOUND : status);
    }
    return _HANDLE_COMPLETE;
  }

  //@Override
  int handleData(List<int> data) {
    throw "should never call here!";
  }

  /** Prepare a store command. [type] is the store type.
   */
  List<int> _prepareStoreCommand(OPType type, String key, int flags, int exp, List<int> doc, int cas) {
    List<int> cmd = new List();

    cmd..addAll(encodeUtf8(type.name))
       ..add(_SPACE)
       ..addAll(encodeUtf8(key))
       ..add(_SPACE)
       ..addAll(encodeUtf8('$flags'))
       ..add(_SPACE)
       ..addAll(encodeUtf8('$exp'))
       ..add(_SPACE)
       ..addAll(encodeUtf8('${doc.length}'));

    if (OPType.cas == type)
      cmd..add(_SPACE)
         ..addAll(encodeUtf8('$cas'));

    cmd..addAll(_CRLF)
       ..addAll(doc)
       ..addAll(_CRLF);

    _logger.finest("_prepareStoreCommand:[${decodeUtf8(cmd)}]");
    return cmd;
  }

  String toString() => "StoreOP: $seq";
}



