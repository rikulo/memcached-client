part of memcached_client;

class HttpResult {
  int status;
  HttpHeaders headers;
  List<int> contents;

  HttpResult(this.status, this.headers, this.contents);
}

class HttpUtil {
  static Logger _logger = initStaticLogger('memcached_client.util.HttpUtil');
  static Future<HttpResult> uriDelete(HttpClient hc, Uri base, Uri resource,
      String usr, String pass, [Map<String, String> headers]) {

    Completer<HttpResult> cmpl = new Completer();
    prepareHttpDelete(hc, base, resource)
    .then((req) {
      HttpHeaders h = req.headers;
      if (headers != null) {
        for (String key in headers.keys)
          h.set(key, headers[key]);
      }
      if (usr != null) {
        h.set(HttpHeaders.AUTHORIZATION, buildAuthHeader(usr, pass));
      }
      return req.close();
    })
    .then((res) {
      int status = res.statusCode;
      HttpHeaders headers = res.headers;
      List<int> contents = new List();
      res.listen((bytes) => contents.addAll(bytes), //read response
        onDone : () => cmpl.complete(new HttpResult(status, headers, contents)), //done read response
        onError: (err) => cmpl.completeError(err) //fail to read response
      );
    })
    .catchError((err) => cmpl.completeError(err));
    return cmpl.future;
  }

  static Future<String> uriPut(HttpClient hc, Uri base, Uri resource,
      String usr, String pass, String value, [Map<String, String> headers]) {

    Completer<String> cmpl = new Completer();
    prepareHttpPut(hc, base, resource)
    .then((req) {
      HttpHeaders h = req.headers;
      if (headers != null) {
        for (String key in headers.keys)
          h.set(key, headers[key]);
      }
      if (usr != null) {
        h.set(HttpHeaders.AUTHORIZATION, buildAuthHeader(usr, pass));
      }
      _logger.finest("PUT:VALUE $value");
      req.write(value);
      return req.close();
    })
    .then((res) {
      StringBuffer sb = new StringBuffer();
      res.listen((bytes) => sb.write(decodeUtf8(bytes)), //read response
        onDone : () => cmpl.complete(sb.toString()), //done read response
        onError: (err) => cmpl.completeError(err) //fail to read response
      );
    })
    .catchError((err) => cmpl.completeError(err));
    return cmpl.future;
  }

  static Future<String> uriGet(HttpClient hc, Uri base, Uri resource,
      String usr, String pass, [Map<String, String> headers]) {

    Completer<String> cmpl = new Completer();
    prepareHttpGet(hc, base, resource)
    .then((req) {
      HttpHeaders h = req.headers;
      if (headers != null) {
        for (String key in headers.keys)
          h.set(key, headers[key]);
      }
      if (usr != null) {
        h.set(HttpHeaders.AUTHORIZATION, buildAuthHeader(usr, pass));
      }
      return req.close();
    })
    .then((res) {
      StringBuffer sb = new StringBuffer();
      res.listen((bytes) => sb.write(decodeUtf8(bytes)), //read response
        onDone : () => cmpl.complete(sb.toString()), //done read response
        onError: (err) => cmpl.completeError(err) //fail to read response
      );
    })
    .catchError((err) => cmpl.completeError(err));
    return cmpl.future;
  }

  static Future<HttpClientRequest> prepareHttpGet(HttpClient hc, Uri base, Uri resource) {
    return new Future.sync(() {
      if (!resource.isAbsolute && base != null) {
        resource = base.resolveUri(resource);
      }
      _logger.finest("GET $resource");
      return hc.openUrl('GET', resource);
    });
  }

  static Future<HttpClientRequest> prepareHttpPost(HttpClient hc, Uri base, Uri resource) {
    return new Future.sync(() {
      if (!resource.isAbsolute && base != null) {
        resource = base.resolveUri(resource);
        _logger.finest("POST $resource");
      }
      return hc.openUrl('POST', resource);
    });
  }

  static Future<HttpClientRequest> prepareHttpPut(HttpClient hc, Uri base, Uri resource) {
    return new Future.sync(() {
      if (!resource.isAbsolute && base != null) {
        resource = base.resolveUri(resource);
        _logger.finest("PUT $resource");
      }
      return hc.openUrl('PUT', resource);
    });
  }

  static Future<HttpClientRequest> prepareHttpDelete(HttpClient hc, Uri base, Uri resource) {
    return new Future.sync(() {
      if (!resource.isAbsolute && base != null) {
        resource = base.resolveUri(resource);
        _logger.finest("DELETE $resource");
      }
      return hc.openUrl('DELETE', resource);
    });
  }

  static String buildAuthHeader(String usr, String pass) {
    StringBuffer sb = new StringBuffer()
        ..write(usr)
        ..write(':');
    if (pass != null)
      sb.write(pass);

    StringBuffer result = new StringBuffer()
        ..write('Basic ')
        ..write(CryptoUtils.bytesToBase64(encodeUtf8(sb.toString())));
    String st = result.toString();
    if (st.endsWith('\r\n'))
      st = st.substring(0, st.length - 2);
    return st;
  }

  /**
   * Split a string containing whitespace or comma separated host or IP
   * addresses and port numbers of the form "host:port host2:port" or
   * "host:port, host2:port" into a List of InetSocketAddress instances suitable
   * for instantiating a MemcachedClient.
   *
   * Note that colon-delimited IPv6 is also supported. For example: ::1:11211
   */
  static List<SocketAddress> parseSocketAddresses(String s) {
    if (s == null) {
      throw new ArgumentError("Null host list");
    }
    if (s.trim().isEmpty) {
      throw new ArgumentError("No hosts in list: [$s]");
    }
    List<SocketAddress> addrs = new List();

    for (String hoststuff in s.split("(?:\\s|,)+")) {
      if (hoststuff == "") {
        continue;
      }

      int finalColon = hoststuff.lastIndexOf(':');
      if (finalColon < 1) {
        throw new ArgumentError("Invalid server $hoststuff in list:  [$s]");
      }
      String hostPart = hoststuff.substring(0, finalColon);
      String portNum = hoststuff.substring(finalColon + 1);

      addrs.add(new SocketAddress(hostPart, int.parse(portNum)));
    }
    return addrs;
  }
}

