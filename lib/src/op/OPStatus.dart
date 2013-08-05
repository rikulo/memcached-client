//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Feb 19, 2013  11:31:50 AM
// Author: hernichen

part of memcached_client;

/**
 * Operation response status of binary protocol.
 */
class OPStatus {
  //Server statuses
  static const NO_ERROR = const OPStatus(0x0000, "No error");
  static const KEY_NOT_FOUND = const OPStatus(0x0001, "Key not found");
  static const KEY_EXISTS = const OPStatus(0x0002, "Key exists");
  static const VALUE_TOO_LARGE = const OPStatus(0x0003, "Value too large");
  static const INVALID_ARG = const OPStatus(0x0004, "Invalid arguments");
  static const ITEM_NOT_STORED = const OPStatus(0x0005, "Item not stored");
  static const NOT_NUMERIC = const OPStatus(0x0006, "Incr/Decr on non-numeric value");
  static const NOT_MY_VBUCKET = const OPStatus(0x0007, "The vbucket belongs to another server");
  static const AUTHEN_ERROR = const OPStatus(0x20, "Authentication error");
  static const AUTHEN_CONT = const OPStatus(0x21, "Authentication continue");
  static const UNKNOWN_COMMAND = const OPStatus(0x0081, "Unknown command");
  static const OUT_OF_MEMORY = const OPStatus(0x0082, "Out of memory");
  static const NOT_SUPPORTED = const OPStatus(0x0083, "Not supported");
  static const INTERAL_ERROR = const OPStatus(0x0084, "Internal error");
  static const BUSY = const OPStatus(0x0085, "Busy");
  static const TEMP_FAIL = const OPStatus(0x0086, "Temporary failure");

  //Client statuses
  static const CANCELLED = const OPStatus(0x8000, "Cancelled");
  static const TIMED_OUT = const OPStatus(0x8001, "Timed out");

  final int code;
  final String message;

  static Map _statusMap;

  const OPStatus(this.code, this.message);

  OPStatus.wrap(OPStatus status, var cause)
      : this.code = status.code,
        this.message = "${status.message}($cause)";

  //@override
  String toString() => "{OPStatus: $code: $message}";

  @override
  int get hashCode => code;

  @override
  bool operator ==(var other) => other is OPStatus && other.code == this.code;

  static OPStatus valueOf(int code) {
    if (_statusMap == null) {
      _statusMap = new HashMap();
      _statusMap[NO_ERROR.code] = NO_ERROR;
      _statusMap[KEY_NOT_FOUND.code] = KEY_NOT_FOUND;
      _statusMap[KEY_EXISTS.code] = KEY_EXISTS;
      _statusMap[VALUE_TOO_LARGE.code] = VALUE_TOO_LARGE;
      _statusMap[INVALID_ARG.code] = INVALID_ARG;
      _statusMap[ITEM_NOT_STORED.code] = ITEM_NOT_STORED;
      _statusMap[NOT_NUMERIC.code] = NOT_NUMERIC;
      _statusMap[NOT_MY_VBUCKET.code] = NOT_MY_VBUCKET;
      _statusMap[AUTHEN_ERROR.code] = AUTHEN_ERROR;
      _statusMap[AUTHEN_CONT.code] = AUTHEN_CONT;
      _statusMap[UNKNOWN_COMMAND.code] = UNKNOWN_COMMAND;
      _statusMap[OUT_OF_MEMORY.code] = OUT_OF_MEMORY;
      _statusMap[NOT_SUPPORTED.code] = NOT_SUPPORTED;
      _statusMap[INTERAL_ERROR.code] = INTERAL_ERROR;
      _statusMap[BUSY.code] = BUSY;
      _statusMap[TEMP_FAIL.code] = TEMP_FAIL;
    }
    return _statusMap[code];
  }
}



