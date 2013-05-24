//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  03:53:34 PM
// Author: hernichen

part of memcached_client;

abstract class BinaryOPFactory extends OPFactory {
  //Singleton
  static final BinaryOPFactory _binaryOPFactory = new _BinaryOPFactoryImpl();
  factory BinaryOPFactory() => _binaryOPFactory;
}

class _BinaryOPFactoryImpl implements BinaryOPFactory {
  DeleteOP newDeleteOP(String key) => new BinaryDeleteOP(key);

  GetOP newGetOP(OPType type, List<String> keys) =>
      new BinaryGetOP(type, keys);

  GetSingleOP newGetSingleOP(OPType type, String key) =>
      new BinaryGetSingleOP(type, key);

  GetAndTouchOP newGetAndTouchOP(String key, int exp) =>
      new BinaryGetAndTouchOP(key, exp);

  GetAndLockOP newGetAndLockOP(String key, int locktime) =>
      new BinaryGetAndLockOP(key, locktime);

  MutateOP newMutateOP(OPType type, String key, int value) =>
      new BinaryMutateOP(type, key, value);

  StoreOP newStoreOP(OPType type, String key, int flags, int exp,
                     List<int> doc, {int cas}) =>
      new BinaryStoreOP(type, key, flags, exp, doc, cas);

  TouchOP newTouchOP(String key, int exp) =>
      new BinaryTouchOP(key, exp);

  VersionOP newVersionOP() =>
      new BinaryVersionOP();

  StatsOP newStatsOP(String prefix) =>
      new BinaryStatsOP(prefix);

  KeyStatsOP newKeyStatsOP(String key) =>
      new BinaryKeyStatsOP(key);

  //Sasl OPs
  SaslMechsOP newSaslMechsOP() =>
      new SaslMechsOP();

  SaslAuthOP newSaslAuthOP(String mechanism, List<int> authData,
                           {int retry : -1}) =>
      new SaslAuthOP(mechanism, authData, retry);

  SaslStepOP newSaslStepOP(String mechanism, List<int> challenge) =>
      new SaslStepOP(mechanism, challenge);

  //Observe OPs
  ObserveOP newObserveOP(String key, int cas) =>
      new ObserveOP(key, cas);

  //Unlock OP
  UnlockOP newUnlockOP(String key, int cas) =>
      new BinaryUnlockOP(key, cas);

  //No OP
  NoOP newNoOP() => new BinaryNoOP();
}
