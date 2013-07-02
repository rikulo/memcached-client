//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Jun 25, 2013  03:43:26 PM
// Author: hernichen

part of memcached_client;

/**
 * A representation of a tap stream message sent from a tap stream server.
 */
class ResponseMessage extends BaseMessage {
  // Offsets are given from the end of the header
  static const int ENGINE_PRIVATE_OFFSET = 24 - BaseMessage.HEADER_LENGTH;
  static const int FLAGS_OFFSET = 26 - BaseMessage.HEADER_LENGTH;
  static const int TTL_OFFSET = 28 - BaseMessage.HEADER_LENGTH;
  static const int RESERVED1_OFFSET = 29 - BaseMessage.HEADER_LENGTH;
  static const int RESERVED2_OFFSET = 30 - BaseMessage.HEADER_LENGTH;
  static const int RESERVED3_OFFSET = 31 - BaseMessage.HEADER_LENGTH;
  static const int ITEM_FLAGS_OFFSET = 32 - BaseMessage.HEADER_LENGTH;
  static const int ITEM_EXPIRY_OFFSET = 36 - BaseMessage.HEADER_LENGTH;
  static const int KEY_OFFSET = 40 - BaseMessage.HEADER_LENGTH;
  static final _EMPTY_LIST = new List(0);

  /** engine private field. Not returned in a no-op message. */
  int engineprivate; //2bytes
  /** value of the flags field. Not returned in a no-op message. */
//  List<TapResponseFlag> flags;
  /** value of the flags field as bits. Not returned in a no-op message. */
  int bitflags;
  /** value of the time to live field. Not returned in a no-op message. */
  int ttl; //1byte
  /** value of the reserved1 field. Not returned in a no-op message. */
  int reserved1; //1byte
  /** value of the reserved2 field. Not returned in a no-op message. */
  int reserved2; //1byte
  /** value of the reserved3 field. Not returned in a no-op message. */
  int reserved3; //1byte
  /**
   * value of the items flag field. Only returned with a tap mutation
   * message.
   */
  int itemflags; //4bytes
  /**
   * value of the item expiry field. Only returned with a tap mutation
   * message.
   */
  int itemexpiry; //4bytes
  /**
   * the state of the vbucket. Only returned with a tap vbucket state
   * message.
   */
  int vbucketstate; //4bytes
  /**
   * the checkpoint of the vbucket.  Only returned with a start/end
   * checkpoint message.
   */
  int checkpoint; //8bytes
  /**
   * value of the key field. Only returned with a tap mutation
   * or tap delete message.
   */
  List<int> key;
  /**
   * the value of the value field. Only returned with a tap mutation
   * message.
   */
  List<int> value;
  /**
   * value of the revid field. Only returned with a tap mutation
   * message.
   */
  List<int> revid;

  /**
   * Creates a ResponseMessage from binary data.
   *
   * + [b] - The binary data sent from the tap stream server.
   */
  initDataFields(List<int> b) {
    if (opcode != TapOpcode.NOOP) {
      engineprivate = bytesToInt16(b, ENGINE_PRIVATE_OFFSET);
      bitflags = bytesToInt16(b, FLAGS_OFFSET);
//      flags = TapResponseFlag.getFlags(bitflags);
      ttl = bytesToInt8(b, TTL_OFFSET);
      reserved1 = bytesToInt8(b, RESERVED1_OFFSET);
      reserved2 = bytesToInt8(b, RESERVED2_OFFSET);
      reserved3 = bytesToInt8(b, RESERVED3_OFFSET);
    } else {
      engineprivate = 0;
      bitflags = 0;
//      flags = new List();
      ttl = 0;
      reserved1 = 0;
      reserved2 = 0;
      reserved3 = 0;
    }

    if (opcode == TapOpcode.MUTATION) {
      if ((bitflags & TapResponseFlag.TAP_FLAG_NETWORK_BYTE_ORDER.flag) != 0) {
        itemflags = bytesToInt32(b, ITEM_FLAGS_OFFSET);
      } else {
        // handles Couchbase bug MB-4834
        itemflags = bytesToInt32HostOrder(b, ITEM_FLAGS_OFFSET);
      }
      itemexpiry = bytesToInt32(b, ITEM_EXPIRY_OFFSET);
      vbucketstate = 0;
      checkpoint = 0;
      revid = new List(engineprivate);
      copyList(b, KEY_OFFSET, revid, 0, engineprivate);
      key = new List(keylength);
      copyList(b, KEY_OFFSET + engineprivate, key, 0, keylength);
      value = new List(b.length - keylength - engineprivate - KEY_OFFSET);
      copyList(b, (b.length - value.length), value, 0, value.length);
    } else if (opcode == TapOpcode.DELETE) {
      itemflags = 0;
      itemexpiry = 0;
      vbucketstate = 0;
      revid = new List(engineprivate);
      copyList(b, 32, revid, 0, engineprivate);
      checkpoint = 0;
      key = new List(keylength);
      copyList(b, 32 + engineprivate, key, 0, keylength);
      value = _EMPTY_LIST;
    } else if (opcode == TapOpcode.VBUCKETSET) {
      itemflags = 0;
      itemexpiry = 0;
      vbucketstate = bytesToInt32(b, ITEM_FLAGS_OFFSET);
      checkpoint = 0;
      key = _EMPTY_LIST;
      value = _EMPTY_LIST;
      revid = _EMPTY_LIST;
    } else if (opcode == TapOpcode.START_CHECKPOINT
      || opcode == TapOpcode.END_CHECKPOINT) {
      itemflags = 0;
      itemexpiry = 0;
      vbucketstate = 0;
      checkpoint = bytesToInt64(b, KEY_OFFSET);
      key = _EMPTY_LIST;
      value = _EMPTY_LIST;
      revid = _EMPTY_LIST;
    } else if (opcode == TapOpcode.OPAQUE) {
      itemflags = 0;
      itemexpiry = 0;
      vbucketstate = bytesToInt32(b, ITEM_FLAGS_OFFSET);
      checkpoint = 0;
      key = _EMPTY_LIST;
      value = _EMPTY_LIST;
      revid = _EMPTY_LIST;
    } else {
      itemflags = 0;
      itemexpiry = 0;
      vbucketstate = 0;
      checkpoint = 0;
      key = _EMPTY_LIST;
      value = _EMPTY_LIST;
      revid = _EMPTY_LIST;
    }
  }

  List<int> get bytes {
    int bufSize = HEADER_LENGTH;
    if (opcode == TapOpcode.MUTATION) {
      bufSize += 16;
    }
    bufSize += totalbody;

    List<int> bb = new List(bufSize);
    bb[0] = _MAGIC_RES;
//    copyList(int8ToBytes(magic.magic), 0, bb, BaseMessage.MAGIC_OFFSET, 1);
    copyList(int8ToBytes(opcode.opcode), 0, bb, BaseMessage.OPCODE_OFFSET, 1);
    copyList(int16ToBytes(keylength), 0, bb, BaseMessage.KEYLENGTH_OFFSET, 2);
    copyList(int8ToBytes(extralength), 0, bb, BaseMessage.EXTRALENGTH_OFFSET, 1);
    copyList(int8ToBytes(datatype), 0, bb, BaseMessage.DATATYPE_OFFSET, 1);
    copyList(int16ToBytes(vbucket), 0, bb, BaseMessage.VBUCKET_OFFSET, 2);
    copyList(int32ToBytes(totalbody), 0, bb, BaseMessage.TOTALBODY_OFFSET, 4);
    copyList(int32ToBytes(opaque), 0, bb, BaseMessage.OPAQUE_OFFSET, 4);
    copyList(int64ToBytes(cas), 0, bb, BaseMessage.CAS_OFFSET, 8);

    if (opcode == TapOpcode.NOOP) {
      return bb;
    }

    int offset = BaseMessage.HEADER_LENGTH;
    copyList(int16ToBytes(engineprivate), 0, bb, offset, 2);
    offset += 2;

//    int flag = 0;
//    for (int i = 0; i < flags.length; i++) {
//      flag |= flags[i].flag;
//    }

    copyList(int16ToBytes(bitflags), 0, bb, offset, 2);
    offset += 2;
    copyList(int8ToBytes(ttl), 0, bb, offset, 1);
    offset += 1;
    copyList(int8ToBytes(reserved1), 0, bb, offset, 1);
    offset += 1;
    copyList(int8ToBytes(reserved2), 0, bb, offset, 1);
    offset += 1;
    copyList(int8ToBytes(reserved3), 0, bb, offset, 1);
    offset += 1;

    if (opcode == TapOpcode.MUTATION) {
      copyList(int32ToBytes(itemflags), 0, bb, offset, 4);
      offset += 4;
      copyList(int32ToBytes(itemexpiry), 0, bb, offset, 4);
      offset += 4;
      copyList(revid, 0, bb, offset, revid.length);
      offset += revid.length;
      copyList(key, 0, bb, offset, key.length);
      offset += key.length;
      copyList(value, 0, bb, offset, value.length);
      offset += value.length;
    } else if (opcode == TapOpcode.DELETE) {
      copyList(revid, 0, bb, offset, revid.length);
      offset += revid.length;
      copyList(key, 0, bb, offset, key.length);
      offset += key.length;
    } else if (opcode == TapOpcode.VBUCKETSET) {
      copyList(int32ToBytes(vbucketstate), 0, bb, offset, 4);
      offset += 4;
    }
    return bb;
  }

  @override
  String toString() {
    return "Key: $key, Flags: $itemflags, TTL: $ttl, Size: $value.length\nValue: $value";
  }
}
