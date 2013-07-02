//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Jun 28, 2013  04:03:16 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

main() {
  setupLogger();

  m.prepareTapClient().then((c) {
    return c.tapDump("node1")
    .then((_) {
      c.stream.listen(
          (data) => print("responseMessage:$data"),
  //      onError: (err) => print("err:$err"),
          onDone: () => print("Done backfill"));
    });
  });
}