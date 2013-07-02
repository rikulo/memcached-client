//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Jun 25, 2013  03:43:26 PM
// Author: hernichen

part of memcached_client;

/**
 * Builds a tap message.
 */
class MessageBuilder {
  RequestMessage message;

  MessageBuilder() {
    this.message = new RequestMessage();
    message.opcode = TapOpcode.REQUEST;
  }

  void doBackfill(int date) {
    message.setBackfill(date);
    message.setFlags(TapRequestFlag.BACKFILL);
  }

  void doDump() {
    message.setFlags(TapRequestFlag.DUMP);
  }

  void specifyVbuckets(List<int> vbucketlist) {
    message.setVbucketlist(vbucketlist);
    message.setFlags(TapRequestFlag.LIST_VBUCKETS);
  }

  void supportAck() {
    message.setFlags(TapRequestFlag.SUPPORT_ACK);
  }

  void keysOnly() {
    message.setFlags(TapRequestFlag.KEYS_ONLY);
  }

  void takeoverVbuckets(List<int> vbucketlist) {
    message.setVbucketlist(vbucketlist);
    message.setFlags(TapRequestFlag.TAKEOVER_VBUCKETS);
  }

  RequestMessage getMessage() => message;
}
