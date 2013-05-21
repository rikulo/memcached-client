//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 15, 2013  03:35:02 PM
// Author: hernichen

part of memcached_client;

/**
 * An Authentication description.
 */
class AuthDescriptor {
  final List<String> mechs;
  int authAttempts;
  int allowedAuthAttempts = -1; //TODO: configurable allowedAuthAttempts
  final String bucket;
  final String password;

  AuthDescriptor(this.mechs, String bucket, String password)
      : this.bucket = bucket == null ? 'default' : bucket,
        this.password = password == null ? '' : password;

  /**
   * Whether beyond the allowed number of authentication attempts.
   */
  bool get authThresholdReached {
    if (allowedAuthAttempts < 0) {
      return false; // negative value means auth forever
    } else if (authAttempts >= allowedAuthAttempts) {
      return true;
    } else {
      authAttempts++;
      return false;
    }
  }

  String toString() =>"bucket:$bucket";
}

