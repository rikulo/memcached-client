//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Mon, Apr 08, 2013  02:15:53 PM
// Author: hernichen

part of memcached_client;

/**
 * Response state of an observe operation.
 */
class ObserveStatus extends Enum {
  /**
   * The observed key is uninitialized.
   */
  static const ObserveStatus UNINITIALIZED = const ObserveStatus(0xff);
  /**
   * The observed key is modified.
   */
  static const ObserveStatus MODIFIED = const ObserveStatus(0xfe);
  /**
   * The observed key is persisted.
   */
  static const ObserveStatus PERSISTED = const ObserveStatus(0x01);
  /**
   * The observed key is NOT persisted.
   */
  static const ObserveStatus NOT_PERSISTED = const ObserveStatus(0x00);
  /**
   * The observed key is DELETED.
   */
  static const ObserveStatus NOT_FOUND = const ObserveStatus(0x80);
  /**
   * The observed key is LOGICAL DELETED.
   */
  static const ObserveStatus LOGICALLY_DELETED = const ObserveStatus(0x81);

  const ObserveStatus(int ordinal)
      : super(ordinal);

  String toString() => '${ordinal}';

  static ObserveStatus valueOf(int ordinal) {
    switch(ordinal) {
      case 0x00:
        return NOT_PERSISTED;
      case 0x01:
        return PERSISTED;
      case 0x80:
        return NOT_FOUND;
      case 0x81:
        return LOGICALLY_DELETED;
      case 0xfe:
        return MODIFIED;
      default:
        return UNINITIALIZED;
    }
  }
}
