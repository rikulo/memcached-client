//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  03:53:34 PM
// Author: hernichen

part of memcached_client;

abstract class TextOPFactory implements OPFactory {
  //Singleton
  static final TextOPFactory _textOPFactory = new _TextOPFactoryImpl();
  factory TextOPFactory() => _textOPFactory;
}

class _TextOPFactoryImpl implements TextOPFactory {
  DeleteOP newDeleteOP(String key, {int cas}) =>
      cas == null || cas == 0 ? new TextDeleteOP(key) :
          throw new UnsupportedError("Delete with CAS is not supported "
            "for text protocol");

  GetOP newGetOP(OPType type, List<String> keys) =>
      new TextGetOP(type, keys);

  GetSingleOP newGetSingleOP(OPType type, String key) =>
      new TextGetSingleOP(type, key);

  GetAndTouchOP newGetAndTouchOP(String key, int expiration) {
    throw new UnsupportedError("Get-and-touch does not work with text protocol");
  }

  GetAndLockOP newGetAndLockOP(String key, int exp) =>
      new TextGetAndLockOP(key, exp);

  MutateOP newMutateOP(OPType type, String key, int value) =>
      new TextMutateOP(type, key, value);

  StoreOP newStoreOP(OPType type, String key, int flags, int exp,
                     List<int> doc, {int cas}) =>
      new TextStoreOP(cas != null ? OPType.cas : type, key, flags, exp, doc, cas);

  TouchOP newTouchOP(String key, int exp) =>
      new TextTouchOP(key, exp);

  VersionOP newVersionOP() =>
      new TextVersionOP();

  StatsOP newStatsOP(String prefix) =>
      new TextStatsOP(prefix);

  KeyStatsOP newKeyStatsOP(String key) {
    throw new UnsupportedError("KeyStats does not work with text protocol");
  }

  //Sasl OPs
  SaslMechsOP newSaslMechsOP() {
    throw new UnsupportedError("SaslMechs does not work with text protocol");
  }

  SaslAuthOP newSaslAuthOP(String mechanism, List<int> authData,
                           {int retry : -1}) {
    throw new UnsupportedError("SaslAuth does not work with text protocol");
  }

  SaslStepOP newSaslStepOP(String mechanism, List<int> challenge) {
    throw new UnsupportedError("SaslStep does not work with text protocol");
  }

  //Observe OPs
  ObserveOP newObserveOP(String key, int cas) {
    throw new UnsupportedError("Observe does not work with text protocol");
  }

  //Unlock OP
  UnlockOP newUnlockOP(String key, int cas) {
    throw new UnsupportedError("Unlock does not work with text protocol");
  } // new TextUnlockOP(key, cas);
    //experiment shows text protocol always return UNLOCK_ERROR

  //No operation OP
  NoOP newNoOP() => new TextNoOP();

  //TapBackfill OP
  TapOP newTapBackfill(String id, int date) {
    throw new UnsupportedError("Tap is not supported for ASCII protocol");
  }

  //TapCustom OP
  TapOP newTapRequest(String id, RequestMessage message) {
    throw new UnsupportedError("Tap is not supported for ASCII protocol");
  }

  //TapAck OP
  TapOP newTapAck(TapOpcode opcode, int opaque) {
    throw new UnsupportedError("Tap is not supported for ASCII protocol");
  }

  //TapDump OP
  TapOP newTapDump(String id) {
    throw new UnsupportedError("Tap is not supported for ASCII protocol");
  }
}
