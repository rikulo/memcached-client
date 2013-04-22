//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Apr 10, 2013  04:17:08 PM
// Author: hernichen

part of memcached_client;

/**
 * An Observable object which has one or more [Observer]s that are interested in
 * whether this object is changed. Basically the [Observable]'s `notifyObservers`
 * methods would causes all of its observers to be notified of the change by a
 * call to their `update` method.
 */
class Observable {
  Set<Observer> _observers;
  bool _changed;

  Observable()
      : _observers = new HashSet(),
        _changed = false;

  void clearChanged() {
    _changed = false;
  }

  bool get hasChanged => _changed;

  void setChanged() {
    _changed = true;
  }

  void addObserver(Observer o) {
    _observers.add(o);
  }

  int get countObservers => _observers.length;

  void deleteObserver(Observer o) {
    _observers.remove(o);
  }

  void deleteObservers() {
    _observers.clear();
  }

  void notifyObservers([var arg]) {
    if (_changed) {
      for(Observer o in _observers) {
        o.update(this, arg);
      }
    }
  }
}