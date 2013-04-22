//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

class MemcachedClientImpl implements MemcachedClient {
  final ConnectionFactory _connFactory;
//  final Transcoder _transcoder;
  final OPFactory _opFactory;
  final MemcachedConnection _memcachedConn;
  final AuthDescriptor _authDescriptor;
  final int _opTimeout;

  Logger _logger;
  bool _closing = false;

  static Future<MemcachedClient> connect(
      List<SocketAddress> saddrs, [ConnectionFactory factory]) {
    return new Future.sync(() {
      if (saddrs == null || saddrs.isEmpty)
        throw new ArgumentError("Need at least one server to connect to: $saddrs");
      if (factory == null)
        factory = new BinaryConnectionFactory();
      return factory.createConnection(saddrs)
        .then((conn) => new MemcachedClientImpl(conn, factory));
    });
  }

  MemcachedClientImpl(
      MemcachedConnection memcachedConn,
      ConnectionFactory connFactory)
      : _memcachedConn = memcachedConn,
        _connFactory = connFactory,
        _opFactory = connFactory.opFactory,
//        _transcoder = connFactory.transcorder,
        _opTimeout = connFactory.opTimeout,
        _authDescriptor = connFactory.authDescriptor {
    _logger = initLogger('memcached_client.spi', this);
  }

  /**
   * Returns the addresses of available servers at this moment.
   */
  List<SocketAddress> get availableServers {
    List<SocketAddress> rv = new List();
    for (MemcachedNode node in locator.allNodes) {
      if (node.isActive)
        rv.add(node.socketAddress);
    }
    return rv;
  }

  /**
   * Returns the address of unavailable servers at this moment.
   */
  List<SocketAddress> get unavailableServers {
    List<SocketAddress> rv = new List();
    for (MemcachedNode node in locator.allNodes) {
      if (!node.isActive)
        rv.add(node.socketAddress);
    }
    return rv;
  }

  NodeLocator get locator => _memcachedConn.locator;

  /** set command */
  Future<bool> set(String key, List<int> doc, [int cas]) =>
      _store(OPType.set, key, 0, 0, doc, cas);

  /** add command */
  Future<bool> add(String key, List<int> doc) =>
      _store(OPType.add, key, 0, 0, doc);

  /** replace command */
  Future<bool> replace(String key, List<int> doc, [int cas]) =>
      _store(OPType.replace, key, 0, 0, doc, cas);

  /** prepend command */
  Future<bool> prepend(String key, List<int> doc, [int cas]) =>
      _store(OPType.prepend, key, 0, 0, doc, cas);

  /** append command */
  Future<bool> append(String key, List<int> doc, [int cas]) =>
      _store(OPType.append, key, 0, 0, doc, cas);

  /** touch command */
  Future<bool> touch(String key, int exp, [bool noreply]) {
    TouchOP op = _opFactory.newTouchOP(key, exp);
    _handleOperation(key, op);
    return op.future;
  }

  /** delete command */
  Future<bool> delete(String key) {
    DeleteOP op = _opFactory.newDeleteOP(key);
    _handleOperation(key, op);
    return op.future;
  }

  /** increment command */
  Future<int> increment(String key, int value) {
    MutateOP op = _opFactory.newMutateOP(OPType.incr, key, value);
    _handleOperation(key, op);
    return op.future;
  }

  /** decrement command */
  Future<int> decrement(String key, int value) {
    MutateOP op = _opFactory.newMutateOP(OPType.decr, key, value);
    _handleOperation(key, op);
    return op.future;
  }

  /** versions command */
  Future<Map<MemcachedNode, String>> versions() =>
    handleBroadcastOperation(() =>
        _opFactory.newVersionOP(), locator.allNodes.iterator);

  /** get command */
  Future<GetResult> get(String key) {
    GetSingleOP op = _opFactory.newGetSingleOP(OPType.get, key);
    _handleOperation(key, op);
    return op.future;
  }

  /** get command with multiple keys */
  Stream<GetResult> getAll(List<String> keys) =>
      _retrieveAll(OPType.get, keys);

  /** gets(with cas data version token) command */
  Future<GetResult> gets(String key) {
    GetSingleOP op = _opFactory.newGetSingleOP(OPType.gets, key);
    _handleOperation(key, op);
    return op.future;
  }

  /** gets(with cas data version token) command with multiple keys */
  Stream<GetResult> getsAll(List<String> keys) =>
      _retrieveAll(OPType.gets, keys);

  Future<Set<String>> listSaslMechs() {
    return handleBroadcastOperation(() =>
        _opFactory.newSaslMechsOP(), locator.allNodes.iterator).then((map) {
      HashSet<String> set = new HashSet();
      for(List<String> mechs in map.values)
        set.addAll(mechs);
      return set;
    });
  }

  Future<bool> _store(OPType type, String key, int flags, int exp, List<int> doc, [int cas, bool noreply]) {
    StoreOP op = _opFactory.newStoreOP(type, key, flags, exp, doc, cas:cas);
    _handleOperation(key, op);
    return op.future;
  }

  Stream<GetResult> _retrieveAll(OPType opCode, List<String> keys) {
    //break gets into groups of key
    final Map<MemcachedNode, List<String>> chunks = new HashMap();
    NodeLocator l = locator;
    bool binary = _opFactory is BinaryOPFactory;
    for (String key in keys) {
      validateKey(key, binary);
      MemcachedNode primary = l.getPrimary(key);
      MemcachedNode node = null;
      if (primary.isActive)
        node = primary;
      else {
        Iterator<MemcachedNode> i = l.getSequence(key);
        while( node == null && i.moveNext()) {
          MemcachedNode n = i.current;
          if (n.isActive)
            node = n;
        }
        if (node == null)
          node = primary;
      }
      List<String> ks = chunks[node];
      if (ks == null) {
        ks = new List();
        chunks[node] = ks;
      }
      ks.add(key);
    }

    //resync results in key sequence
    StreamController<GetResult> tgt = new StreamController();
    int keyi = 0; //key sequence index
    String currentKey = keys[0]; //the key should be add to Stream in sequence
    Map<String, GetResult> tmpMap = new HashMap(); //temporary map for out of sequence results
    for (MemcachedNode node in chunks.keys) {
      GetOP op = _opFactory.newGetOP(opCode, chunks[node]);
      _handleOperationAtNode(node, op);
      Stream<GetResult> src = op.stream;
      src.listen(
        (getr) {
          if (getr.key == currentKey) { //match the current key
            do {
              tgt.add(getr);
              //try next key; might have been stored in tmpMap
              ++keyi;
              if (keyi < keys.length) {
                currentKey = keys[keyi];
                getr = tmpMap.remove(currentKey);
              } else
                getr = null;
            } while(getr != null && getr.key == currentKey);
          } else //not match the current key; store it in tmpMap for later use
            tmpMap[getr.key] = getr;
        },
        onError: (err) => tgt.addError(err),
        onDone: () => tgt.close()
      );
    }
    return tgt.stream;
  }

  void _handleOperation(String key, OP op) {
    _memcachedConn.addOP(key, op);
  }

  void _handleOperationAtNode(MemcachedNode node, OP op) {
    _memcachedConn.addOPToNode(node, op);
  }

  Future<Map<MemcachedNode, dynamic>> handleBroadcastOperation(OP newOP(),
      Iterator<MemcachedNode> nodeIterator) =>
      _memcachedConn.broadcastOP(newOP, nodeIterator);

  void close() {
    if (_closing) return;

    _closing = true;
    _memcachedConn.close();
  }

  OPFactory get opFactory => _opFactory;
}

/** Key validation */
void validateKey(String key, bool binary) {
  List<int> keyBytes = encodeUtf8(key);
  if (keyBytes.length > MemcachedClient.MAX_KEY_LENGTH) {
    throw new ArgumentError("Key is too long (maxlen = "
        "${MemcachedClient.MAX_KEY_LENGTH})");
  }
  if (keyBytes.length == 0) {
    throw new ArgumentError(
        "Key must contain at least one character.");
  }
  if(!binary) {
    // Validate the key
    for (int j = 0; j < key.length; ++j) {
      String b = key[j];
      if (b == ' ' || b == '\n' || b == '\r' || b == 0) {
        throw new ArgumentError(
            "Key contains invalid characters:  ``$key''");
      }
    }
  }
}
