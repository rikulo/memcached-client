part of memcached_client;

/**
 * OP that depends on Vbucket index being sent to server should implement
 * this interface.
 */
abstract class VbucketAwareOP {
  /**
   * Get Vbucket index of this OP.
   */
  int getVbucketID(String key);

  /**
   * Set Vbucket index of this OP.
   */
  void setVbucketID(Map<String, int> ids);

  /**
   * Those nodes that has complained NOT_MY_VBUCKET for this [OP].
   */
  Iterable<MemcachedNode> get notMyVbucketNodes;

  /**
   * Add a node that has complained NOT_MY_VBUCKET for this [OP].
   */
  void addNotMyVbucketNode(MemcachedNode node);

  /**
   * Set directly those nodes that has complained NOT_MY_VBUCKET for this [OP].
   */
  void set notMyVbucketNodes(Iterable<MemcachedNode> nodes);
}


