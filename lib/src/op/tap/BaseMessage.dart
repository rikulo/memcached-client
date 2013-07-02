//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Jun 25, 2013  12:11:26 PM
// Author: hernichen

part of memcached_client;

/**
 * The BaseMessage implements the header of a tap message. This class cannot be
 * instantiated.  Tap stream messages are created with the RequestMessage and
 * ResponseMessage classes.
 */
abstract class BaseMessage {
  static const int MAGIC_OFFSET = 0;
  static const int OPCODE_OFFSET = 1;
  static const int KEYLENGTH_OFFSET = 2;
  static const int EXTRALENGTH_OFFSET = 4;
  static const int DATATYPE_OFFSET = 5;
  static const int VBUCKET_OFFSET = 6;
  static const int TOTALBODY_OFFSET = 8;
  static const int OPAQUE_OFFSET = 12;
  static const int CAS_OFFSET = 16;
  static const int HEADER_LENGTH = 24;

//  /** magic field of tap message */
//  TapMagic magic;
  /** opCode field of tap message */
  TapOpcode opcode;
  /** key length field of tap message */
  int keylength = 0; //2bytes
  /** extra length field of tap message */
  int extralength = 0; //1byte
  /** data type field of tap message */
  int datatype = 0; //1byte
  /** vbucket field of tap message */
  int vbucket = 0; //2bytes
  /** total body field of tap message */
  int totalbody = 0; //4bytes
  /** opaque field of tap message */
  int opaque = 0; //4bytes
  /** cas(CheckAndSave) field of tap message */
  int cas = 0; //8bytes

  BaseMessage();
//  BaseMessage.fromBytes(List<int> b) {
//    magic = TapMagic.valueOf(bytesToInt8(b, MAGIC_OFFSET));
//    opcode = TapOpcode.valueOf(bytesToInt8(b, OPCODE_OFFSET));
//    keylength = bytesToInt16(b, KEYLENGTH_OFFSET);
//    extralength = bytesToInt8(b, EXTRALENGTH_OFFSET);
//    datatype = bytesToInt8(b, DATATYPE_OFFSET);
//    vbucket = bytesToInt16(b, VBUCKET_OFFSET);
//    totalbody = bytesToInt32(b, TOTALBODY_OFFSET);
//    opaque = bytesToInt32(b, OPAQUE_OFFSET);
//    cas = bytesToInt64(b, CAS_OFFSET);
//  }

  /**
   * Gets the length of the entire message.
   */
  int get messageLength => HEADER_LENGTH + totalbody;

  /**
   * Return a byte list of this tap message.
   */
  List<int> get bytes;
}
