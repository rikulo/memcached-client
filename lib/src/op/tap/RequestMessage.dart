//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Jun 25, 2013  03:43:26 PM
// Author: hernichen

part of memcached_client;

/**
 * A tap request message that is used to start tap streams, perform sasl
 * authentication, and maintain the health of tap streams.
 */
class RequestMessage extends BaseMessage {
  bool hasBackfill = false;
  bool hasVBucketList = false;
  bool hasVBucketCheckpoints = false;
  bool get hasFlags => bitflags != 0;
//  List<TapRequestFlag> flagList;
  int bitflags = 0;
  List<int> vblist; //2bytes list
  String name;
  int backfilldate = -1; //8bytes
  Map<int, int> vBucketCheckpoints; //2bytes -> 8bytes

  /**
   * Create a tap request message. These messages are used to start tap streams.
   */
  RequestMessage() {
    opcode = TapOpcode.REQUEST;
//    flagList = new List();
    vblist = new List(0);
    vBucketCheckpoints = new HashMap();
    name = _uuid();
    totalbody = name.length;
    keylength = name.length;
  }

  /**
   * Sets the flags for the tap stream. These flags decide what kind of tap
   * stream will be received.
   *
   * + [f] - The flags to use for this tap stream.
   */
  void setFlags(TapRequestFlag f) {
    if ((bitflags & f.flag) == 0) {
      if (!hasFlags) {
        extralength += 4;
        totalbody += 4;
      }
      if (f == TapRequestFlag.BACKFILL) {
        hasBackfill = true;
        totalbody += 8;
      }
      if (f == TapRequestFlag.LIST_VBUCKETS
        || f == TapRequestFlag.TAKEOVER_VBUCKETS) {
        hasVBucketList = true;
        totalbody += 2;
      }
      if (f == TapRequestFlag.CHECKPOINT) {
        hasVBucketCheckpoints = true;
        totalbody += 2;
      }
      bitflags |= f.flag;
    }
  }

//  /**
//   * Returns the flags for this message.
//   */
//  List<TapRequestFlag> getFlags() {
//    return flagList;
//  }

  /**
   * Stream all keys inserted into the server after a given date.
   *
   * + [date] - The date to stream keys from. Null to stream all keys.
   */
  void setBackfill(int date) {
    backfilldate = date;
  }

  /**
   * Sets a list of vbuckets to stream keys from.
   *
   * + [vbs] - A list of vbuckets.
   */
  void setVbucketlist(List<int> vbs) {
    int oldSize = (vblist.length + 1) * 2;
    int newSize = (vbs.length + 1) * 2;
    totalbody += newSize - oldSize;
    vblist = vbs;
  }

  /**
   * Sets a map of vbucket checkpoints.
   *
   * + [vbchkpnts] - A map of vbucket checkpoint identifiers
   */
  void setvBucketCheckpoints(Map<int, int> vbchkpnts) {
    int oldSize = (vBucketCheckpoints.length) * 10;
    int newSize = (vbchkpnts.length) * 10;
    totalbody += newSize - oldSize;
    vBucketCheckpoints = vbchkpnts;
  }

  /**
   * Sets a name for this tap stream. If the tap stream fails this name can be
   * used to try to restart the tap stream from where it last left off.
   *
   * + [n] - The name for the tap stream.
   */
  void setName(String n) {
    if (n.length > 65535) {
      throw new ArgumentError("Tap name too long: $n");
    }
    totalbody += n.length - name.length;
    keylength = n.length;
    name = n;
  }

  /**
   * Encodes the message into binary.
   */
  @override
  List<int> get bytes {
    List<int> bb = new List(BaseMessage.HEADER_LENGTH + totalbody);
    bb[0] = _MAGIC_REQ;
//    copyList(int8ToBytes(magic.magic), 0, bb, BaseMessage.MAGIC_OFFSET, 1);
    copyList(int8ToBytes(opcode.opcode), 0, bb, BaseMessage.OPCODE_OFFSET, 1);
    copyList(int16ToBytes(keylength), 0, bb, BaseMessage.KEYLENGTH_OFFSET, 2);
    copyList(int8ToBytes(extralength), 0, bb, BaseMessage.EXTRALENGTH_OFFSET, 1);
    copyList(int8ToBytes(datatype), 0, bb, BaseMessage.DATATYPE_OFFSET, 1);
    copyList(int16ToBytes(vbucket), 0, bb, BaseMessage.VBUCKET_OFFSET, 2);
    copyList(int32ToBytes(totalbody), 0, bb, BaseMessage.TOTALBODY_OFFSET, 4);
    copyList(int32ToBytes(opaque), 0, bb, BaseMessage.OPAQUE_OFFSET, 4);
    copyList(int64ToBytes(cas), 0, bb, BaseMessage.CAS_OFFSET, 8);

    int offset = BaseMessage.HEADER_LENGTH;
    if (hasFlags) {
//      int flag = 0;
//      for (int i = 0; i < flagList.length; i++) {
//        flag |= flagList[i].flag;
//      }
      copyList(int32ToBytes(bitflags), 0, bb, offset, 4);
      offset += 4;
    }
    List<int> namebytes = UTF8.encode(name);
    copyList(namebytes, 0, bb, offset, namebytes.length);
    offset += namebytes.length;
    if (hasBackfill) {
      copyList(int64ToBytes(backfilldate), 0, bb, offset, 8);
      offset += 8;
    }
    if (hasVBucketList) {
      copyList(int16ToBytes(vblist.length), 0, bb, offset, 2);
      offset += 2;
      for (int i = 0; i < vblist.length; i++) {
        copyList(int16ToBytes(vblist[i]), 0, bb, offset, 2);
        offset += 2;
      }
    }
    if (hasVBucketCheckpoints) {
      copyList(int16ToBytes(vBucketCheckpoints.length), 0, bb, offset, 2);
      offset += 2;
      for (int vBucket in vBucketCheckpoints.keys) {
        copyList(int16ToBytes(vBucket), 0, bb, offset, 2);
        offset += 2;
        copyList(int64ToBytes(vBucketCheckpoints[vBucket]), 0, bb, offset, 8);
        offset += 8;
      }
    }

    return bb;
  }
}

final Random _random = new Random();
String _uuid() {
  List<int> out = new List();
  double val = _random.nextDouble();
  int nLetter = 16;
  for(int j = 0; j < 16; ++j) {
    double nv = val * 26;
    int ival = nv.toInt();
    val = nv - ival;
    out.add(ival + 97); //'a'
  }
  return new String.fromCharCodes(out);
}
