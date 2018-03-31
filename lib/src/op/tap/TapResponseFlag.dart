//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Jun 25, 2013  11:52:11 AM
// Author: hernichen

part of memcached_client;

/**
 * The Flag enum contains a list all of the different flags that can be passed
 * in a tap message in the flag field.
 */
class TapResponseFlag extends Enum {
  /**
   * This message requires acknowledgment.
   */
  static const TapResponseFlag TAP_ACK = const TapResponseFlag(0x01);

  /**
   * This message doesn't contain a value.
   */
  static const TapResponseFlag TAP_NO_VALUE = const TapResponseFlag(0x02);

  /**
   * This message is sent correctly in network byte order.
   */
  static const TapResponseFlag TAP_FLAG_NETWORK_BYTE_ORDER =
      const TapResponseFlag(0x04);

  /**
   * The flag value.
   */
  int get flag => ordinal;

  const TapResponseFlag(int flag) : super(flag);

  static List<TapResponseFlag> getFlags(int f) {
    List<TapResponseFlag> flags = new List();

    if ((f & TapResponseFlag.TAP_ACK.flag) != 0) {
      flags.add(TapResponseFlag.TAP_ACK);
    }
    if ((f & TapResponseFlag.TAP_NO_VALUE.flag) != 0) {
      flags.add(TapResponseFlag.TAP_NO_VALUE);
    }
    if ((f & TapResponseFlag.TAP_FLAG_NETWORK_BYTE_ORDER.flag) != 0) {
      flags.add(TapResponseFlag.TAP_FLAG_NETWORK_BYTE_ORDER);
    }
    return flags;
  }
}
