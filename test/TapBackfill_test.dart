//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Jun 28, 2013  04:03:16 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

void testTapBackfillOP(MemcachedClient client, TapClient tapClient) {
  tapClient.stream.listen(
      (data) => print("responseMessage:$data"),
//      onError: (err) => print("err:$err"),
      onDone: () => print("done backfill"));

  Future f = tapClient
  .tapBackfill("node1")
  .then((_) {
    print("set key0 with 'val1'");
    expect(client.set('key0', encodeUtf8('"val0"')), completion(isTrue));
  });

  expect(f, completes);
}

void main() {
  setupLogger();
  group('TapBackfillTest:', () {
    MemcachedClient client;
    TapClient tapClient;
    setUp(() {
      return Future.wait([
        m.prepareBinaryClient().then((c) => client = c),
        m.prepareTapClient().then((c) => tapClient = c)]);
    });
    tearDown(() {
      client.close();
      tapClient.close();
    });
    test('TestTapBackfillOP', () => testTapBackfillOP(client, tapClient));
  });
}
