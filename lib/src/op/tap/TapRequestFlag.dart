//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Jun 25, 2013  12:11:33 PM
// Author: hernichen

part of memcached_client;

/**
 * The Flag enum contains a list all of the different flags that can be passed
 * in a tap message in the flag field.
 */
class TapRequestFlag extends Enum {
  /**
   * Tap backfill flag definition.
   */
  static const TapRequestFlag BACKFILL = const TapRequestFlag(0x01);

  /**
   * Tap dump flag definition.
   */
  static const TapRequestFlag DUMP = const TapRequestFlag(0x02);

  /**
   * Tap list vBuckets flag definition.
   */
  static const TapRequestFlag LIST_VBUCKETS = const TapRequestFlag(0x04);

  /**
   * Tap take over vBuckets flag definition.
   */
  static const TapRequestFlag TAKEOVER_VBUCKETS = const TapRequestFlag(0x08);

  /**
   * Tap support acknowledgment flag definition.
   */
  static const TapRequestFlag SUPPORT_ACK = const TapRequestFlag(0x10);

  /**
   * Tap send keys only flag definition.
   */
  static const TapRequestFlag KEYS_ONLY = const TapRequestFlag(0x20);

  /**
   * Tap use checkpoints.
   */
  static const TapRequestFlag CHECKPOINT = const TapRequestFlag(0x40);

  /**
   * Tap request fixed byteorder.
   *
   * Some releases of Couchbase Server (at least through 1.8.0) send data in
   * host byteorder on x86 based systems.  This requests network byte order
   * (fixed).  See MB-4834.
   */
  static const TapRequestFlag FIX_BYTEORDER = const TapRequestFlag(0x100);

  int get flag => ordinal;

  const TapRequestFlag(int flag)
      : super(flag);

  static List<TapRequestFlag> getFlags(int f) {
    List<TapRequestFlag> flags = new List();

    if ((f & TapRequestFlag.BACKFILL.flag) != 0) {
      flags.add(TapRequestFlag.BACKFILL);
    }
    if ((f & TapRequestFlag.DUMP.flag) != 0) {
      flags.add(TapRequestFlag.DUMP);
    }
    if ((f & TapRequestFlag.LIST_VBUCKETS.flag) != 0) {
      flags.add(TapRequestFlag.LIST_VBUCKETS);
    }
    if ((f & TapRequestFlag.TAKEOVER_VBUCKETS.flag) != 0) {
      flags.add(TapRequestFlag.TAKEOVER_VBUCKETS);
    }
    if ((f & TapRequestFlag.SUPPORT_ACK.flag) != 0) {
      flags.add(TapRequestFlag.SUPPORT_ACK);
    }
    if ((f & TapRequestFlag.KEYS_ONLY.flag) != 0) {
      flags.add(TapRequestFlag.KEYS_ONLY);
    }
    if ((f & TapRequestFlag.CHECKPOINT.flag) != 0) {
      flags.add(TapRequestFlag.CHECKPOINT);
    }

    return flags;
  }
}