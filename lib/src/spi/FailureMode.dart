//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 22, 2013  09:15:05 PM
// Author: hernichen

part of memcached_client;

class FailureMode extends Enum {
  /**
   * Move on to functional nodes when nodes fail.
   *
   * In this failure mode, the failure of a node will cause its current queue
   * and future requests to move to the next logical node in the cluster for a
   * given key.
   */
  static const FailureMode Redistribute = const FailureMode(0);

  /**
   * Continue to retry a failing node until it comes back up.
   *
   * This failure mode is appropriate when you have a rare short downtime of a
   * memcached node that will be back quickly, and your app is written to not
   * wait very long for async command completion.
   */
  static const FailureMode Retry = const FailureMode(1);

  /**
   * Automatically cancel all operations heading towards a downed node.
   */
  static const FailureMode Cancel = const FailureMode(2);

  const FailureMode(int ordinal)
      : super(ordinal);
}


