//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  10:29:52 AM
// Author: hernichen

part of memcached_client;

/** a Store Operation */
class TextStoreOP extends TextSingleKeyOP implements StoreOP {
  final Completer _cmpl; //completer to complete the future of this operation
  final OPType _type;

  Future<bool> get future => _cmpl.future;

  TextStoreOP(OPType type, String key, int flags, int exp, List<int> doc,
      int cas)
      : _type = type,
        _cmpl = new Completer(),
        super(key) {
    _cmd = _prepareStoreCommand(type, key, flags, exp, doc, cas);
  }

  //@Override
  int handleTextCommand(String line) {
    _logger.finest("StoreOpCommand: $this, [${line}]\n");
    OPStatus status = TextOPStatus.valueOfError(line);
    if (status != null)
      _cmpl.completeError(new OPStatus.wrap(status, this));
    else {
      OPStatus status = TextOPStatus.valueOf(line);
      if (status == null)
        _cmpl.complete(true);
      else {
        final OPStatus s0 = status != OPStatus.ITEM_NOT_STORED ? status :
          _type == OPType.add ? OPStatus.KEY_EXISTS :
          _type == OPType.replace ? OPStatus.KEY_NOT_FOUND : status;
        _cmpl.completeError(new OPStatus.wrap(s0, this));
      }
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

    cmd..addAll(UTF8.encode(type.name))
       ..add(_SPACE)
       ..addAll(UTF8.encode(key))
       ..add(_SPACE)
       ..addAll(UTF8.encode('$flags'))
       ..add(_SPACE)
       ..addAll(UTF8.encode('${exp == null ? 0 : exp}'))
       ..add(_SPACE)
       ..addAll(UTF8.encode('${doc.length}'));

    if (OPType.cas == type)
      cmd..add(_SPACE)
         ..addAll(UTF8.encode('$cas'));

    cmd..addAll(_CRLF)
       ..addAll(doc)
       ..addAll(_CRLF);

    _logger.finest("_prepareStoreCommand:[${UTF8.decode(cmd)}]");
    return cmd;
  }
}



