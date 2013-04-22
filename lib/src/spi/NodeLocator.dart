//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of memcached_client;

/**
 * Locating a node by hash value.
 */
abstract class NodeLocator {
  /**
   * Get the primary node per the given key.
   */
  MemcachedNode getPrimary(String key);

  /**
   * Get the Iterator<MemcachedNode> of backup nodes per the given key.
   */
  Iterator<MemcachedNode> getSequence(String key);

  /**
   * Get all memcached nodes; useful for broadcasting messages.
   */
  Iterable<MemcachedNode> get allNodes;

  /**
   * Update locator status.
   */
  void updateLocator(Iterable<MemcachedNode> nodes);
}
