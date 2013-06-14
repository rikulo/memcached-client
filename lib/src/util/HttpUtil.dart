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
      String usr, String pass, [Map<String, String> headers]) =>
      _uriFunc(() => prepareHttpDelete(hc, base, resource), usr, pass, headers, null);

  static Future<HttpResult> uriGet(HttpClient hc, Uri base, Uri resource,
      String usr, String pass, [Map<String, String> headers]) =>
      _uriFunc(() => prepareHttpGet(hc, base, resource), usr, pass, headers, null);

  static Future<HttpResult> uriPut(HttpClient hc, Uri base, Uri resource,
      String usr, String pass, String value, [Map<String, String> headers]) =>
      _uriFunc(() => prepareHttpPut(hc, base, resource), usr, pass, headers, value);

  static Future<HttpResult> uriPost(HttpClient hc, Uri base, Uri resource,
      String usr, String pass, String value, [Map<String, String> headers]) =>
      _uriFunc(() => prepareHttpPost(hc, base, resource), usr, pass, headers, value);

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
   * Parse list of Uris into list of SocketAddress instances.
   *
   * Note that colon-delimited IPv6 is also supported. For example: ::1:11211
   */
  static List<SocketAddress> parseSocketAddressesFromUris(List<Uri> uris) {
    List<SocketAddress> addrs = new List();
    for (Uri uri in uris) {
      final host = uri.host;
      final port = uri.port;
      addrs.add(new SocketAddress(host, port));
    }
    return addrs;
  }

  /**
   * Parse list of host:port server descriptions into list of SocketAddress
   * instances.
   *
   * Note that colon-delimited IPv6 is also supported. For example: ::1:11211
   */
  static List<SocketAddress> parseSocketAddressesFromStrings(List<String> servers) {
    List<SocketAddress> addrs = new List();

    for (String hoststuff in servers) {
      if (hoststuff == "") {
        continue;
      }

      int finalColon = hoststuff.lastIndexOf(':');
      if (finalColon < 1) {
        throw new ArgumentError("Invalid server $hoststuff in list:  servers");
      }
      String hostPart = hoststuff.substring(0, finalColon);
      String portNum = hoststuff.substring(finalColon + 1);

      addrs.add(new SocketAddress(hostPart, int.parse(portNum)));
    }
    return addrs;
  }

  /**
   * Split a string containing whitespace or comma separated host or IP
   * addresses and port numbers of the form "host:port host2:port" or
   * "host:port, host2:port" into a List of SocketAddress instances.
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
    return parseSocketAddressesFromStrings(s.split("(?:\\s|,)+"));
  }

  static Future<HttpResult> _uriFunc(Future<HttpClientRequest> prepareFunc(),
      String usr, String pass, Map<String, String> headers, String value) {
    Completer<HttpResult> cmpl = new Completer();
    prepareFunc()
    .then((req) {
      HttpHeaders h = req.headers;
      if (headers != null) {
        for (String key in headers.keys)
          h.set(key, headers[key]);
      }
      if (usr != null) {
        h.set(HttpHeaders.AUTHORIZATION, buildAuthHeader(usr, pass));
      }
      if (value != null) {
        _logger.finest("VALUE: $value");
        req.write(value);
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
}
