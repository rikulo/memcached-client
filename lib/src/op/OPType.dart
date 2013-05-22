part of memcached_client;

/**
 * The protocol operation type.
 */
class OPType extends Enum {
  //Version
  /**
   * Version of the server.
   */
  static const version = const OPType(0x0b, 'version');

  //Store
  /**
   * Unconditionally store a value in the cache.
   */
  static const set = const OPType(0x01, 'set');
  /**
   * Store a value in the cache iff there is not already something stored for
   * the given key.
   */
  static const add = const OPType(0x02, 'add');
  /**
   * Store a value in the cache iff there is already something stored for the
   * given key.
   */
  static const replace = const OPType(0x03, 'replace');

  /**
   * append a value after current value.
   */
  static const append = const OPType(0x0e, 'append');

  /**
   * Prepend a value in front of current value.
   */
  static const prepend = const OPType(0x0f, 'prepend');

  /**
   * Store a value but only if no one else has updated since last fetched.
   */
  static const cas = const OPType(0x01, 'cas'); //== OPType.set in binary protocol

  /**
   * Touch a document
   */
  static const touch = const OPType(0x1c, 'touch');

  //Mutate
  /**
   * Increse a value by a spcified number.
   */
  static const incr = const OPType(0x05, 'incr');

  /**
   * Decrease a value by a specified number.
   */
  static const decr = const OPType(0x06, 'decr');

  //Retrieve
  /**
   * General get
   */
  static const get = const OPType(0x00, 'get');

  /**
   * Get and touch.
   */
  static const gat = const OPType(0x1d, 'gat');

  /**
   * Get and lock.
   */
  static const getl = const OPType(0x94, 'getl');

  /**
   * Get with cas "fingerprint"
   */
  static const gets = const OPType(0x00, 'gets');

  static const getk = const OPType(0x0c, 'getk'); //binary protocol

  static const getkq = const OPType(0x0d, 'getkq'); //binary protocol

  //Delete
  /**
   * Delete a document.
   */
  static const delete = const OPType(0x04, 'delete');

  //SASL
  /**
   * SASL authentication
   */
  static const saslMechs = const OPType(0x20, 'saslMechs');

  static const saslAuth = const OPType(0x21, 'saslAuth');

  static const saslStep = const OPType(0x22, 'saslStep');

  //Other
  /**
   * Observe operation.
   */
  static const observe = const OPType(0x92, 'observe');

  /**
   * Unlock a locking document.
   */
  static const unlock = const OPType(0x95, 'unl');

  /**
   * No operation.
   */
  static const noop = const OPType(0x0a, 'noop');

  final String name;
  const OPType(int ordinal, this.name)
      : super(ordinal);
}



