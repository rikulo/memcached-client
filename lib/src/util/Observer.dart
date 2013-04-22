//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Apr 10, 2013  04:17:08 PM
// Author: hernichen

part of memcached_client;

/**
 * Object that wants to be informed of changes in [Observable] objects.
 */
abstract class Observer<T> {
  /**
   * This method is called whenever the [Observable] object is changed
   * and notified this [Observer].
   */
  void update(Observable o, T arg);
}
