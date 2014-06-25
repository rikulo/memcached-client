//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Mon, Apr 08, 2013  05:48:34 PM
// Author: hernichen

part of memcached_client;

/**
 * An observe operation of binary protocol
 */
class ObserveOP extends SingleKeyOP implements FutureOP<ObserveResult> {
  final Completer<ObserveResult> _cmpl;
  final int _orgCas; //expected cas
  int _avgPersistTime; //msecs
  int _avgReplicateTime; //msecs

  Future<ObserveResult> get future => _cmpl.future;

  ObserveOP(String key, int cas)
      : _cmpl = new Completer(),
        _orgCas = cas,
        super(key) {
    _cmd = _prepareObserveCommand(key);
  }

  @override
  int handleCommand(List<int> aLine) {
    int ret = super.handleCommand(aLine);

    _avgPersistTime = bytesToInt32(aLine, 16);
    _avgReplicateTime = bytesToInt32(aLine, 20);

    return ret;
  }

  @override
  int handleData(List<int> line) {
    //_logger.finest("ObserveOPData: $this, $line.");
    if (_status != 0)
      _cmpl.completeError(new OPStatus.wrap(OPStatus.valueOf(_status), this));
    else {
      int keylen = bytesToInt16(line, 2);
      int keystatus = bytesToInt8(line, keylen+4);
      int retCas = bytesToInt64(line, keylen+5);
      //_logger.finest("ObserverStatus: $keystatus, retCas: $retCas");
      ObserveStatus status =
          _orgCas != null
          && retCas != _orgCas
          && keystatus != ObserveStatus.NOT_FOUND.ordinal
          && keystatus != ObserveStatus.LOGICALLY_DELETED.ordinal ?
          ObserveStatus.MODIFIED :
          ObserveStatus.valueOf(keystatus);
      _cmpl.complete(new ObserveResult(key, status, retCas, _avgPersistTime, _avgReplicateTime));
    }

    return _HANDLE_COMPLETE;
  }

  //--VbucketAwareOP--//
  @override
  void setVbucketID(Map<String, int> ids) {
    final id = ids.values.first;
    if (0 != id) {
      copyList(int16ToBytes(id), 0, _cmd, 24, 2);
      //_logger.finest("vbucketID:$id");
      //_logger.finest("cmd+vbuckitID:$_cmd");
    }
  }

  /**
   * Prepare observe command
   */
  //Prepare one observe command
  static const int _req_extralen = 4;
  List<int> _prepareObserveCommand(String key) {
    List<int> keybytes = UTF8.encode(key);
    int keylen = keybytes.length;
    int valuelen = 0;
    int bodylen = _req_extralen + keylen + valuelen;

    Uint8List cmd = new Uint8List(24 + bodylen);
    //0, 1 byte: Magic byte of request
    cmd[0] = _MAGIC_REQ;
    //1, 1 byte: Opcode
    cmd[1] = OPType.observe.ordinal;
    //2, 2 bytes: Key length
    //4, 2 bytes: extra length
    //6, 2 bytes: vBucket id
    //8, 4 bytes: total body length
    copyList(int32ToBytes(bodylen), 0, cmd, 8, 4);
    //12, 4 bytes: Opaque
    //16, 8 bytes: CAS
    //24, 2 bytes: vbucket id  //@See vbucketID setter
    //26, 2 bytes: Key length
    copyList(int16ToBytes(keylen), 0, cmd, 26, 2);
    //28, keylen: key
    copyList(keybytes, 0, cmd, 28, keylen);

    //_logger.finest("_prepareObserveCommand:$cmd");
    return cmd;
  }
}
