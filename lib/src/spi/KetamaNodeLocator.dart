//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 22, 2013  10:23:02 AM
// Author: hernichen

part of memcached_client;

/**
 * NodeLocator using Ketama HashAlgorithm.
 */
class KetamaNodeLocator implements NodeLocator {
  Logger _logger;

  SplayTreeMap<int, MemcachedNode> _ketamaNodes;
  KetamaNodeLocatorConfig _kconfig;
  final HashAlgorithm _hashAlg;
  List<MemcachedNode> _nodes;

  KetamaNodeLocator(List<MemcachedNode> nodes, HashAlgorithm hashAlg)
      : _hashAlg = hashAlg,
        _kconfig = new KetamaNodeLocatorConfig() {
    initLogger('memcached_client.spi', this);
    _nodes = nodes;
    _setupKetamaNodes(nodes);
  }

  @override
  MemcachedNode getPrimary(String key) =>
      _getNodeForKey(_hashAlg(key), _ketamaNodes);

  @override
  Iterator<MemcachedNode> getSequence(String key) =>
      new _KetamaNodeIterator(key, 7, _ketamaNodes, _hashAlg);

  @override
  Iterable<MemcachedNode> get allNodes => _nodes;

  @override
  void updateLocator(Iterable<MemcachedNode> nodes) {
    _nodes = nodes.toList();
  }

  int get maxKey => _ketamaNodes.lastKey();

  void _setupKetamaNodes(List<MemcachedNode> nodes) {
    SplayTreeMap<int, MemcachedNode> newNodeMap = new SplayTreeMap();
    int numReps = _kconfig.nodeRepetitions;
    for (MemcachedNode node in nodes) {
      // Ketama does some special work with md5 where it reuses chunks.
      if (_hashAlg == KETAMA_HASH) {
        for (int i = 0; i < numReps / 4; i++) {
          List<int> digest = computeMd5(_kconfig.getKeyForNode(node, i));
          for (int h = 0; h < 4; h++) {
            int k = ((digest[3 + h * 4] & 0xFF) << 24)
                    | ((digest[2 + h * 4] & 0xFF) << 16)
                    | ((digest[1 + h * 4] & 0xFF) << 8)
                    | (digest[h * 4] & 0xFF);
            newNodeMap[k & 0xffffffffffffffff] = node;
            //_logger.finest("Adding node $node in position $k");
          }
        }
      } else {
        for (int i = 0; i < numReps; i++)
          newNodeMap[_hashAlg(_kconfig.getKeyForNode(node, i))] = node;
      }
    }
    _ketamaNodes = newNodeMap;
  }
}

MemcachedNode _getNodeForKey(int hash,
    SplayTreeMap<int, MemcachedNode> ketamaNodes) {

  if (!ketamaNodes.containsKey(hash))
    hash = ketamaNodes.firstKeyAfter(hash);
  return ketamaNodes[hash];
}


class _KetamaNodeIterator implements Iterator<MemcachedNode> {
  String _key;
  int _hashVal;
  int _remainingTries;
  int _numTries = 0;
  final HashAlgorithm _hashAlg;
  final SplayTreeMap<int, MemcachedNode> _ketamaNodes;
  MemcachedNode _current;

  _KetamaNodeIterator(String key, int tries,
      SplayTreeMap<int, MemcachedNode> ketamaNodes, HashAlgorithm hashAlg)
      : _hashAlg = hashAlg,
        _ketamaNodes = ketamaNodes,
        _hashVal = hashAlg(key),
        _remainingTries = tries,
        _key = key;

  void nextHash() {
    int tmpKey = _hashAlg('${_numTries++}_key');
    // This echos the implementation of Long.hashCode()
    _hashVal += (tmpKey ^ ((tmpKey >> 32) & 0xffffffff));
    _hashVal &= 0xffffffff; /* truncate to 32-bits */
    _remainingTries--;
  }

  MemcachedNode get current => _current;

  bool moveNext() {
    bool b = _remainingTries > 0;
    if (b) {
      _current = _getNodeForKey(_hashVal, _ketamaNodes);
      nextHash();
    }
    return b;
  }
}

class KetamaNodeLocatorConfig {
  static const int _numReps = 160;

  Map<MemcachedNode, String> saddrMap = new HashMap();

  // Using the internal map retrieve the socket addresses of a node.
  String _getSocketAddressForNode(MemcachedNode node) {
    String result = saddrMap[node];
    if (result == null) {
      result = node.socketAddress.toUri();
      if (result.startsWith("/")) {
        result = result.substring(1);
      }
      saddrMap[node] = result;
    }
    return result;
  }

  /**
   * Returns the number of discrete hashes that should be defined for each node
   * in the continuum.
   */
  int get nodeRepetitions => _numReps;

  /**
   * Returns a uniquely identifying key, suitable for hashing by the
   * KetamaNodeLocator algorithm.
   *
   * This default implementation uses the socket-address of the MemcachedNode
   * and concatenates it with a hyphen directly against the repetition number
   * for example a key for a particular server's first repetition may look like:
   *
   *     myhost/10.0.2.1-0
   *
   * for the second repetition
   *
   *     myhost/10.0.2.1-1
   *
   * for a server where reverse lookups are failing the returned keys may look
   * like
   *
   *     /10.0.2.1-0
   *
   * and
   *
   *     /10.0.2.1-1
   *
   * [node] The MemcachedNode to use to form the unique identifier
   * [repetition] The repetition number for the particular node in question
   *          (0 is the first repetition)
   */
  String getKeyForNode(MemcachedNode node, int repetition) =>
      "${_getSocketAddressForNode(node)}-$repetition";
}

