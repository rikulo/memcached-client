part of memcached_client;

abstract class OPFactory {
  DeleteOP newDeleteOP(String key);

  GetOP newGetOP(OPType type, List<String> keys);

  GetSingleOP newGetSingleOP(OPType type, String key);

  MutateOP newMutateOP(OPType type, String key, int value);

  StoreOP newStoreOP(OPType type, String key, int flags, int exp, List<int> doc,
                     {int cas});

  GetAndLockOP newGetAndLockOP(String key, int locktime);

  GetAndTouchOP newGetAndTouchOP(String key, int exp);

  TouchOP newTouchOP(String key, int exp);

  VersionOP newVersionOP();

  SaslMechsOP newSaslMechsOP();

  SaslAuthOP newSaslAuthOP(String mechanism, List<int> authData,
                           {int retry : -1});

  SaslStepOP newSaslStepOP(String mechanism, List<int> challenge);

  ObserveOP newObserveOP(String key, int cas);

  UnlockOP newUnlockOP(String key, int cas);

  NoOP newNoOP();
}
