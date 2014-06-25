//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

/**
 * To be extended by OP that contains multiple key and is a VbucketAwareOP.
 */
abstract class MultiKeyOP extends BinaryOP implements VbucketAwareOP {
  final List<int> _cmdOffsets;
  final List<String> keys;
  Map<String, int> _vbucketMap; //associated operation vbucket index
  Set<MemcachedNode> _notMyVbucketNodes;

  /**
   * + [keys] - keys involved in this operation.
   * + [cmdOffsets] - offsets for the mulitple binary commands' header.
   */
  MultiKeyOP(this.keys, List<int> cmdOffsets)
      : _cmdOffsets = cmdOffsets,
        _notMyVbucketNodes = new HashSet();

  //--VbucketAwareOP--//
  @override
  void setVbucketID(Map<String, int> ids) {
    _vbucketMap = ids;
    for (int j = 0, len = this.keys.length; j < len; ++j) {
      final int offset = _cmdOffsets[j];
      final String key = this.keys[j];
      final int id = getVbucketID(key);
      final List<int> src = int16ToBytes(id);
      copyList(src, 0, _cmd, offset + 6, 2);
      //_logger.finest("After setVbucketID: offset:$offset, id:$id");
    }
    //_logger.finest("After setVbucketID: _cmd:$_cmd");
  }

  @override
  int getVbucketID(String key) => _vbucketMap[key];

  @override
  Iterable<MemcachedNode> get notMyVbucketNodes => _notMyVbucketNodes;

  @override
  void addNotMyVbucketNode(MemcachedNode node) {
    _notMyVbucketNodes.add(node);
  }

  @override
  void set notMyVbucketNodes(Iterable<MemcachedNode> nodes) {
    _notMyVbucketNodes.addAll(nodes);
  }
  
  @override
  String toString() => "${this.runtimeType}@$seq:$keys";
}