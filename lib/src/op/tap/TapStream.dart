//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Jun 25, 2013  06:15:03 PM
// Author: hernichen

part of memcached_client;

/**
 * Holds multiple operations put together for a tap stream.
 *
 * A TapStream handles the series of messages coming back from a given node
 * which is sending data over TAP.  The TapClient will typically manage a
 * set of TapStreams.
 */
class TapStream {
  final Iterable<TapOP> ops;

  TapStream(Iterable<TapOP> ops) : this.ops = ops;

  /**
   * Cancels all operations still waiting on an existing TapStream.
   */
  void cancel() {
    for (TapOP op in ops) {
      op.cancel();
    }
  }

  /**
   * Check if all operations in the TapStream are completed.
   * true if all operations currently in the TapStream are completed
   */
  bool get isCompleted {
    for (TapOP op in ops) {
      if (op.state != OPState.COMPLETE) {
        return false;
      }
    }
    return true;
  }

  /**
   * Determine if messages sent to this server and recorded on this TapStream
   * have been canceled.true if all operations on this TapStream have been
   * canceled.
   */
  bool get isCancelled {
    for (TapOP op in ops) {
      if (!op.isCancelled) {
        return false;
      }
    }
    return true;
  }

  /**
   * Determine if messages sent to this server and recorded on this TapStream
   * have been determined to be in error. true if all operations on this
   * TapStream are in an error state.
   */
  bool get hasErrored {
    for (TapOP op in ops) {
      if (!op.hasErrored) {
        return false;
      }
    }
    return true;
  }
}
