//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

abstract class SingleKeyOP extends BinaryOP implements VbucketAwareOP {
  final String key;
  int _vbucketID = 0; //associated operation vbucket index
  Set<MemcachedNode> _notMyVbucketNodes;

  SingleKeyOP(this.key)
    :_notMyVbucketNodes = new HashSet();

  //--VbucketAwareOP--//
  @override
  void setVbucketID(Map<String, int> ids) {
    final int id = ids.values.first;
    if (0 != id) {
      _vbucketID = id;
      copyList(int16ToBytes(id), 0, _cmd, 6, 2);
      //_logger.finest("vbucketID:$id");
      //_logger.finest("cmd+vbuckitID:$_cmd");
    }
  }

  @override
  int getVbucketID(String key) => _vbucketID;

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
  String toString() => "${this.runtimeType}@$seq:$key";
}