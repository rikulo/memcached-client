//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, May 23, 2013  02:56:34 PM
// Author: hernichen

part of memcached_client;

/** A tap ack operation sent back to Tap server */
class TapRequestOP extends TapOP implements StreamOP<ResponseMessage> {
  final StreamController<ResponseMessage> _streamCtrl;

  TapRequestOP(String id, RequestMessage message)
      : _streamCtrl = new StreamController(sync:true) {

    if (message != null) {
      message.setName(id == null ? _uuid() : id);
      message.setFlags(TapRequestFlag.FIX_BYTEORDER);
      _cmd = _prepareTapRequestCommand(id, message);
    }
  }

  //-- TapRequestOP --//
  @override
  Stream<ResponseMessage> get stream => _streamCtrl.stream;

  @override
  int handleData(List<int> line) {
    //_logger.finest("TapRequestOPData: $this, $line.");

    ResponseMessage response = new ResponseMessage();
    response.opcode = TapOpcode.valueOf(this._opCode);
    response.keylength = this._keylen;
    response.extralength = this._keylen;
    response.datatype = this._dataType;
    response.vbucket = this._status;
    response.totalbody = this._bodylen;
    response.opaque = this._opaque;
    response.cas = this._cas;
    response.initDataFields(line);

    if ((response.bitflags & TapResponseFlag.TAP_ACK.flag) != 0) {
      //ack back Tap server that we have received the streamed-back data
      final TapAckOP op = new TapAckOP(response.opcode, response.opaque);
      //op.future.then((_) => _logger.finest("ack back and done: $op.opcode, $op.opaque"));
      handlingNode.addOP(op);
    }
    if (response.opcode != TapOpcode.OPAQUE
        && response.opcode != TapOpcode.NOOP) {
      _streamCtrl.add(response);
    }
    return _HANDLE_CMD; //handle next line of command
  }

  //Streaming socket is closed (by server).
  void socketClosed() {
    if (!_streamCtrl.isClosed) {
      //_logger.finest("Tap server socket closed; close tap stream");
      _streamCtrl.close();
    }
  }

  /**
   * Prepare a store command.
   */
  List<int> _prepareTapRequestCommand(String id, RequestMessage message) {
    final cmd = message.bytes;
    //_logger.finest("_prepareTapRequestCommand:$cmd");
    return cmd;
  }
}
