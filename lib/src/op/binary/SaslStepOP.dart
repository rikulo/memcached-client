//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 15, 2013  03:35:02 PM
// Author: hernichen

part of memcached_client;

class SaslStepOP extends SaslOP {
  SaslStepOP(String mechanism, List<int> challenge)
      : super(OPType.saslStep, mechanism, challenge) {
    throw new UnsupportedError("SaslStepOP is not supported");
  }

  int handleData(List<int> aLine) {
    return _HANDLE_COMPLETE;
  }

  String toString() => "SaslStepOP: $seq";
}

