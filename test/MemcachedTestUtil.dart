//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:33:48 PM
// Author: henrichen
library memcached_test_util;

import 'dart:async';
import 'dart:utf';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';

Future<MemcachedClient> prepareBinaryClient()
=> MemcachedClient.connect([new SocketAddress('127.0.0.1', 11211)],
      factory: new BinaryConnectionFactory());

Future<MemcachedClient> prepareTextClient()
=> MemcachedClient.connect([new SocketAddress('127.0.0.1', 11211)],
      factory: new TextConnectionFactory());

Future<TapClient> prepareTapClient()
=> new Future.value(new TapClient([new SocketAddress('10.1.3.128', 11210)]));