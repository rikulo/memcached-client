//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, May 15, 2013  03:27:34 PM
// Author: hernichen

part of memcached_client;

/**
 * hashCode utility.
 */

/**
 * Returns hashCode of a Map per its contents.
 */
int mapHashCode(final Map map) {
  if (map == null) return null.hashCode;

  int h = 0;
  for (var key in map.keys)
    h += (key.hashCode ^ map[key].hashCode) & 0xffffffff;
  return h;
}

/**
 * Returns hashCode of a List per its contents.
 */
int listHashCode(final List list) {
  if (list == null) return null.hashCode;

  int h = 1;
  for (var e in list) {
    h = (31 * h + e.hashCode) & 0xffffffff;
  }
  return h;
}

/**
 * Returns whether two maps equals to each other per their contents.
 */
bool mapEquals(final Map m1, final Map m2) {
  if (identical(m1, m2)) return true;
  if (m1 == null || m2 == null) return false;
  if (m1.length != m2.length) return false;

  for (var k1 in m1.keys) {
    final v1 = m1[k1];
    if (v1 == null) {
      if (!(m2[k1] == null && m2.containsKey(k1)))
        return false;
    } else {
      if (v1 != m2[k1])
        return false;
    }
  }
  return true;
}

/**
 * Returns whether two lists equals to each other per their contents.
 */
bool listEquals(final List l1, final List l2) {
  if (identical(l1, l2)) return true;
  if (l1 == null || l2 == null) return false;
  if (l1.length != l2.length) return false;

  Iterator i1 = l1.iterator;
  Iterator i2 = l2.iterator;

  while(i1.moveNext() && i2.moveNext()) {
    final o1 = i1.current;
    final o2 = i2.current;
    if (!(o1 == null ? o2 == null : o1 == o2))
      return false;
  }
  return true;
}

