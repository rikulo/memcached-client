//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, May 23, 2013  02:56:34 PM
// Author: hernichen

part of memcached_client;

/** A tap ack operation sent back to Tap server */
class TapBackfillOP extends TapRequestOP {
  TapBackfillOP(String id, int date) : super(id, null) {
    RequestMessage message = new RequestMessage();
    message.setFlags(TapRequestFlag.BACKFILL);
    message.setFlags(TapRequestFlag.SUPPORT_ACK);
    message.setFlags(TapRequestFlag.FIX_BYTEORDER);
    message.setName(id == null ? _uuid() : id);
    message.setBackfill(date);
    _cmd = _prepareTapRequestCommand(id, message);
  }
}
