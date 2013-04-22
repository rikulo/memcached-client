part of memcached_client;

/**
 * State of this operation. We use the OPState to control the temple of OP
 * processing: see MemcachedNode#process().
 */
class OPState extends Enum {
  /**
   * State indicating this operation is waiting to be written to the server.
   */
  static const OPState WRITE_QUEUED = const OPState(0);
  /**
   * State indicating this operation is writing data to the server.
   */
  static const OPState WRITING = const OPState(1);
  /**
   * State indicating this operation is reading data from the server.
   */
  static const OPState READING = const OPState(2);
  /**
   * State indicating this operation is complete.
   */
  static const OPState COMPLETE = const OPState(3);
  /**
   * State indicating this operation needs to be resent.  Typically
   * this means vbucket hashing and there is a topology change.
   */
  static const OPState RETRY = const OPState(4);
  /**
   * Special State for authenticating OP.
   */
  static const OPState WAIT = const OPState(100);
  /**
   * Special state indicate that this OP is canceled before processed.
   */
  static const OPState CANCELED = const OPState(200);

  const OPState(int ordinal)
      : super(ordinal);
}


