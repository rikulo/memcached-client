//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Feb 26, 2013  11:09:34 AM
// Author: hernichen

part of memcached_client;

abstract class TextOP extends OP {
  Logger _logger;
  List<int> _cmd; //command in a byte array
  OPState _state; //null is state 0
  int seq;

  TextOP() {
    _logger = initLogger('memcached_client.op.text', this);
  }

  List<int> get cmd => _cmd;

  OPState get state => _state;

  void set state(OPState s) {
    _state = s;
  }

  int handleCommand(List<int> aLine) => handleTextCommand(decodeUtf8(aLine));

  int handleTextCommand(String aLine);
}
