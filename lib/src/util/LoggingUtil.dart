//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Jan 30, 2013  10:12:51 AM
// Author: hernichen

part of memcached_client;

Logger initLogger(String parent, dynamic inst) =>
    new Logger('$parent.${inst.runtimeType}');

Logger initStaticLogger(String fullClassName) =>
    new Logger(fullClassName);

void setupLogger({String name : '', Level level : Level.ALL}) {
  hierarchicalLoggingEnabled = true;
  Logger root = new Logger(name);
  root.level = level;
  root.onRecord.listen((LogRecord r) {
    print('${r.sequenceNumber} ${r.time} ${r.loggerName} ${r.level}: ${r.message}');
  });
}

