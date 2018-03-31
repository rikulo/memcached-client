//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:35:34 AM
// Author: hernichen

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
   * + [document] - the document to be set
   * + [cas] - optional: the document version
   * + [exptime] - optional: document expiration time in seconds; defalut to 0
   *   which means permenent. If [exptime] exceeds 30 days(30x24x60x60), it is
   *   deemed as an absolute date in seconds since epoch time.
   */
  Future<bool> set(String key, List<int> document, {int cas, int exptime});

  /**
   * Add specified document if the provided key is not existed yet. Returns
   * true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   *
   * + [key] - the key of the document
   * + [document] - the document to be set
   * + [exptime] - optional: document expiration time in seconds; defalut to 0
   *   which means permenent. If [exptime] exceeds 30 days(30x24x60x60), it is
   *   deemed as an absolute date in seconds since epoch time.
   */
  Future<bool> add(String key, List<int> document, {int exptime});

  /**
   * Replace the existing document of the provided key with the specified byte
   * array. Returns true if succeed; otherwise, throw
   * OPStatus.NOT_STORED or other Error status.
   *
   * + [key] - the key of the document
   * + [document] - the document to be set
   * + [cas] - optional: the document version
   * + [exptime] - optional: document expiration time in seconds; defalut to 0
   *   which means permenent. If [exptime] exceeds 30 days(30x24x60x60), it is
   *   deemed as an absolute date in seconds since epoch time.
   */
  Future<bool> replace(String key, List<int> document, {int cas, int exptime});

  /**
   * Prepend byte array in front of the existing document of the provided key.
   * Returns true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   *
   * + [key] - the key of the document
   * + [prepend] - the byte array prepend in front of the existing document
   * + [cas] - optional: the document version
   */
  Future<bool> prepend(String key, List<int> prepend, {int cas});

  /**
   * append byte array at the rear of the existing document of the provided key.
   * Returns true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   *
   *
   * + [key] - the key of the document
   * + [append] - the byte array append at the rear of the existing document
   * + [cas] - optional: the document version
   */
  Future<bool> append(String key, List<int> append, {int cas});

  /**
   * Delete the specified key; return true if succeed. Otherwise,
   * throws OPStatus.NOT_FOUND or other errors.
   *
   * + [key] - the key of the document
   * + [cas] - optional: the document version
   */
  Future<bool> delete(String key, {int cas});

  /**
   * Increment the docuemnt(must be an integer) by the provided [by] value.
   * Returns the result integer; otherwise, throw OPStatus.NOT_FOUND or other
   * error status. Note increment might cause counter to wrap over(64bit unsigned).
   *
   * + [key] - the key of the document
   * + [by] - the number to be increased onto the number document
   * + [def] - optional: the default number to return if the doucment did not
   *   exist; default to 0. If [exptime] is set to -1, this value is ignored.
   * + [exptime] - optional: document expiration time in seconds; default to 0
   *   which means permenent. If [exptime] exceeds 30 days(30x24x60x60), it is
   *   deemed as an absolute date in seconds since unix epoch time. -1
   *   indicate to throw OPStatus.NOT_FOUND if document did not exist.
   */
  Future<int> increment(String key, int by, {int def, int exptime});

  /**
   * Decrement the document(must be an integer) by the provided [by] value.
   * Returns the result integer; otherwise, throw OPStatus.NOT_FOUND or other
   * error status. Note decrement will NEVER result in "negative value" or "wrap
   * the counter), it will stay at 0 instead.
   *
   * + [key] - the key of the document
   * + [by] - the number to be decreased from the number document
   * + [def] - optional: the default number to return if the doucment did not
   *   exist; default to 0. If [exptime] is set to -1, this value is ignored.
   * + [exptime] - optional: document expiration time in seconds; default to 0
   *   which means permenent. If [exptime] exceeds 30 days(30x24x60x60), it is
   *   deemed as an absolute date in seconds since unix epoch time. -1
   *   indicate to throw OPStatus.NOT_FOUND if document did not exist.
   */
  Future<int> decrement(String key, int by, {int def, int exptime});

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

  /**
   * Get document as a GetResult of the provided key and reset the document
   * expiration time in seconds. 0 means permenent, If exptime exceeds
   * 30 days(30x24x60x60), it is deemed as an absolute date in seconds.
   * This API returns GetResult if succeed; otherwise, throw OPStatus.NOT_FOUND
   * or other error status.
   *
   * + [exptime] - optional: document expiration time in seconds; defalut to 0
   *   which means permenent. If [exptime] exceeds 30 days(30x24x60x60), it is
   *   deemed as an absolute date in seconds since epoch time.
   */
  Future<GetResult> getAndTouch(String key, int exptime);

  /**
   * Touch document expiration time in seconds. 0 means permenent.
   * If exptime exceeds 30 days(30x24x60x60), it is deemed as an
   * absolute date in seconds. Returns true if succeed; othewise,
   * throw OPStatus.NOT_FOUND or other Error status.
   *
   * + [exptime] - optional: document expiration time in seconds; defalut to 0
   *   which means permenent. If [exptime] exceeds 30 days(30x24x60x60), it is
   *   deemed as an absolute date in seconds since epoch time.
   */
  Future<bool> touch(String key, int exptime);

  /**
   * Returns the versions of the connected servers. Returns version as a String.
   */
  Future<Map<SocketAddress, String>> versions();

  /**
   * Returns the statistics of the connected servers. Returns statistics as a
   * Map<String, String>.
   * see [here](https://github.com/membase/ep-engine/blob/master/docs/stats.org)
   * for details regarding statistics.
   *
   * + [prefix] - which statistic to get. Search "Statistics" in this
   * [document](https://github.com/memcached/memcached/blob/master/doc/protocol.txt)
   * for detail regarding which prefix are allowed
   *
   */
  Future<Map<SocketAddress, Map<String, String>>> stats({String prefix});

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
  static Future<MemcachedClient> connect(List<SocketAddress> saddrs,
          {ConnectionFactory factory}) =>
      MemcachedClientImpl.connect(saddrs, factory: factory);
}
