//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 22, 2013  10:23:02 AM
// Author: hernichen

part of memcached_client;

/**
 * Simple array modulo NodeLocator.
 */
class ArrayModNodeLocator implements NodeLocator {
  final HashAlgorithm _hashAlg;
  List<MemcachedNode> _nodes;

  ArrayModNodeLocator(List<MemcachedNode> nodes, HashAlgorithm hashAlg)
      : _hashAlg = hashAlg {
    _nodes = nodes;
  }

  @override
  MemcachedNode getPrimary(String key) => _nodes[_getServerForKey(key)];

  @override
  Iterator<MemcachedNode> getSequence(String key) =>
      new _ArrayModNodeIterator(_getServerForKey(key), _nodes);

  @override
  Iterable<MemcachedNode> get allNodes => _nodes;

  @override
  void updateLocator(List<MemcachedNode> nodes) {
    _nodes = nodes;
  }

  int _getServerForKey(String key) {
    int rv = _hashAlg(key) % _nodes.length;
    assert (rv >= 0);
    return rv;
  }
}

class _ArrayModNodeIterator implements Iterator<MemcachedNode> {
  final int _start;
  final List<MemcachedNode> _nodes;
  MemcachedNode _current;
  int _next;

  _ArrayModNodeIterator(int start, List<MemcachedNode> nodes)
      : _start = start,
        _nodes = nodes,
        _next = start;

  MemcachedNode get current => _current;

  bool moveNext() {
    if (_next == null)
      return false;
    if (++_next >= _nodes.length)
      _next = 0;
    if (_next == _start) {
      _current = null;
      _next = null;
      return false;
    }
    _current = _nodes[_start];
    return true;
  }
}
