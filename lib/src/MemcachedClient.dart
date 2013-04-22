part of memcached_client;

/**
 * Client to a memcached cluster servers.
 *
 * '''Basic usage'''
 *
 *     Future<MemcachedClient> future = MemcachedClient.connect(
 *       [new SocketAddress(host1,port1), new SocketAddress(host2,port2), ...],
 *       new BinaryConnectionFactory());
 *
 *     // Store a value
 *     future
 *      .then((c) => c.set("someKey", someObject))
 *      .then((ok) => print("done"));
 *
 *     // Retrieve a value.
 *     future
 *      .then((c) => c.get("someKey"))
 *      .then((myObject) => print("$myObject"));
 */
abstract class MemcachedClient {
  /**
   * Maximum supported key length.
   */
  static const int MAX_KEY_LENGTH = 250;

  /**
   * Returns those servers that are currently active and respond to commands.
   */
  List<SocketAddress> get availableServers;

  /**
   * Returns those servers that are currently not active and cannot respond
   * to commands.
   */
  List<SocketAddress> get unavailableServers;

  /**
   * Returns default Transcoder used with this MemcachedClient.
   */
//  Transcoder get transcoder;

  /**
   * Returns the locator of the server nodes in the cluster.
   */
  NodeLocator get locator;

  /**
   * Set unconditinally the specified document. Returns
   * true if succeed; throw Error status otherwise.
   *
   * + [key] - the key of the document
   */
  Future<bool> set(String key, List<int> document, [int cas]);

  /**
   * Add specified document if the provided key is not existed yet. Returns
   * true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   */
  Future<bool> add(String key, List<int> document);

  /**
   * Replace the existing document of the provided key with the specified byte
   * array. Returns true if succeed; otherwise, throw
   * OPStatus.NOT_STORED or other Error status.
   */
  Future<bool> replace(String key, List<int> document, [int cas]);

  /**
   * Prepend byte array in front of the existing document of the provided key.
   * Returns true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   */
  Future<bool> prepend(String key, List<int> prepend, [int cas]);

  /**
   * append byte array at the rear of the existing document of the provided key.
   * Returns true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   */
  Future<bool> append(String key, List<int> document, [int cas]);

  /**
   * Delete the specified key; return true if succeed. Otherwise,
   * throws OPStatus.NOT_FOUND or other errors.
   */
  Future<bool> delete(String key);

  /**
   * Increment the docuemnt(must be an integer) by the provided [by] value.
   * Returns the result integer; otherwise, throw OPStatus.NOT_FOUND or other
   * error status.
   */
  Future<int> increment(String key, int by);

  /**
   * Decrement the document(must be an integer) by the provided [by] value.
   * Returns the result integer; otherwise, throw OPStatus.NOT_FOUND or other
   * error status.
   */
  Future<int> decrement(String key, int by);

  /**
   * Get document as a GetResult of the provided key. If you need cas token
   * to avoid racing when setting the document of the key, please use gets API.
   * This API returns GetResult if succeed; otherwise, throw OPStatus.NOT_FOUND
   * or other error status.
   */
  Future<GetResult> get(String key);

  /**
   * Get list of documents as a Stream of [GetResult]. If you need cas token
   * to avoid racing when setting the document of the key, please use getsAll
   * API. This API returns a Stream of GetResult per the provided key list;
   * return an empty Stream if none of the doucment of the provided key exists.
   */
  Stream<GetResult> getAll(List<String> keys);

  /**
   * Get document as a GetResult of the provided key with cas token. The cas
   * token can be used to avoid racing when setting the document of the key.
   * This API returns GetResult if succeed; otherwise, throw OPStatus.NOT_FOUND
   * or other error status.
   */
  Future<GetResult> gets(String key);

  /**
   * Get list of documents with cas tokens as a Stream of [GetResult]. The
   * cas token can be used to avoid racing when setting the document of the key.
   * This API returns a Stream of GetResult per the provided key list;
   * return an empty Stream if none of the doucment of the provided key exists.
   */
  Stream<GetResult> getsAll(List<String> keys);

  /** Touch document expiration time in seconds. 0 means permenent.
   * If exptime exceeds 30 days(30*24*60*60), it is deemed as an
   * absolute date in seconds. Returns true if succeed; othewise,
   * throw OPStatus.NOT_FOUND or other Error status.
   */
  Future<bool> touch(String key, int exptime);

  /**
   * Returns the versions of the connected servers. Returns version as a String.
   */
  Future<Map<MemcachedNode, String>> versions();

  /**
   * Returns the set of supported SASL authentication mechanisms.
   */
  Future<Set<String>> listSaslMechs();

  /**
   * Close this memcached client.
   */
  void close();

  /**
   * Create and connect to a cluster of servers per the specified server
   * addresses and optional connection factory.
   *
   * + [saddrs] - socket addresses of a cluster of servers
   * + [factory] - optional connection factory; default: [BinaryConnectionFactory].
   */
  static Future<MemcachedClient> connect(
      List<SocketAddress> saddrs, [ConnectionFactory factory]) =>
      MemcachedClientImpl.connect(saddrs, factory);
}
