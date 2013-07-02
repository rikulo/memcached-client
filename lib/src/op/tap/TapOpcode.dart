//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Jun 25, 2013  11:10:03 AM
// Author: hernichen

part of memcached_client;

/**
 * The Opcode enum contains a list all of the different opcodes that can be
 * passed in a tap message in the flag field.
 */
class TapOpcode extends Enum {
  /**
   * Defines a tap no-op message.
   */
  static const TapOpcode NOOP = const TapOpcode(0x0a);

  /**
   * Defines a SASL list mechanism message.
   */
  static const TapOpcode SASLLIST = const TapOpcode(0x20);

  /**
   * Defines a SASL authorization message.
   */
  static const TapOpcode SASLAUTH = const TapOpcode(0x21);

  /**
   * Defines a request message to open a tap connection.
   */
  static const TapOpcode REQUEST = const TapOpcode(0x40);

  /**
   * Defines a key-value mutation message to specify a key-value has changed.
   */
  static const TapOpcode MUTATION = const TapOpcode(0x41);

  /**
   * Defines a delete message to specify a key has been deleted.
   */
  static const TapOpcode DELETE = const TapOpcode(0x42);

  /**
   * Defines a tap flush message.
   */
  static const TapOpcode FLUSH = const TapOpcode(0x43);

  /**
   * Defines a opaque message to send control data to the consumer.
   */
  static const TapOpcode OPAQUE = const TapOpcode(0x44);

  /**
   * Defines a vBucket set message to set the state of a vBucket in the
   * consumer.
   */
  static const TapOpcode VBUCKETSET = const TapOpcode(0x45);

  /**
   * Defines the start of a checkpoint.
   */
  static const TapOpcode START_CHECKPOINT = const TapOpcode(0x46);

  /**
   * Defines the end of a checkpoint.
   */
  static const TapOpcode END_CHECKPOINT = const TapOpcode(0x47);

  int get opcode => ordinal;

  const TapOpcode(int opcode)
      : super(opcode);

  static Map<int, TapOpcode> _opMap;

  static TapOpcode valueOf(int opcode) {
    if (_opMap == null) {
      _opMap = new HashMap();
      _opMap[TapOpcode.DELETE.opcode] = TapOpcode.DELETE;
      _opMap[TapOpcode.FLUSH.opcode] = TapOpcode.DELETE;
      _opMap[TapOpcode.MUTATION.opcode] = TapOpcode.MUTATION;
      _opMap[TapOpcode.NOOP.opcode] = TapOpcode.NOOP;
      _opMap[TapOpcode.OPAQUE.opcode] = TapOpcode.OPAQUE;
      _opMap[TapOpcode.REQUEST.opcode] = TapOpcode.REQUEST;
      _opMap[TapOpcode.SASLAUTH.opcode] = TapOpcode.SASLAUTH;
      _opMap[TapOpcode.SASLLIST.opcode] = TapOpcode.SASLLIST;
      _opMap[TapOpcode.VBUCKETSET.opcode] = TapOpcode.VBUCKETSET;
      _opMap[TapOpcode.START_CHECKPOINT.opcode] = TapOpcode.START_CHECKPOINT;
      _opMap[TapOpcode.END_CHECKPOINT.opcode] = TapOpcode.END_CHECKPOINT;
    }
    return _opMap[opcode];
  }
}
