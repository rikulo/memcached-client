part of memcached_client;

/**
 * An operation that will return a [Future].
 */
abstract class FutureOP<T> extends OP {
  Future<T> get future;
}
