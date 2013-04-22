part of memcached_client;

/** Represent a result after execute observe command */
class ObserveResult {
  /**
   * document id
   */
  final String key;

  /**
   * Status of the observation.
   */
  final ObserveStatus status;

  /**
   * Current version of the document.
   */
  final int cas;

  /**
   * Average persist time used in milliseconds.
   */
  final int avgPersistTime;

  /**
   * Average replica time used in milliseconds.
   */
  final int avgReplicateTime;

  /**
   * Whether this is the primary server of the document. false means that this
   * is the result from a replica server.
   */
  bool isPrimary = false;

  ObserveResult(this.key, this.status, this.cas, this.avgPersistTime, this.avgReplicateTime);

  String toString() =>
      'isPrimary:$isPrimary, key:$key, status:$status, cas:$cas, '
      'avgPersistTime:$avgPersistTime, avgReplicateTime:$avgReplicateTime';
}
