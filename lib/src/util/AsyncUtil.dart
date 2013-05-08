//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Apr 23, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

class TimeoutError extends RuntimeError {
  TimeoutError(message)
      : super(message);
}

/**
 * Make a Future with timeout mechanism which will throw a [TimeoutError]
 * if the Future is not completed before the specified timeout duration.
 *
 * + origin - original Future to be wrapped.
 * + timeout - timeout duration.
 * + description - error message if timeout.
 */
Future timeoutFuture(Future origin, Duration timeout, String description) {
  var cmpl = new Completer();
  var timer = new Timer(timeout), () {
    cmpl.completeError(new TimeoutError(description));
  });
  origin.then((value) {
    if (cmpl.isCompleted) return;
    timer.cancel();
    cmpl.complete(value);
  }).catchError((e) {
    if (cmpl.isCompleted) return;
    timer.cancel();
    cmpl.completeError(e);
  });
  return cmpl.future;
}

/**
 * Wrap a [Stream] into a [Future] so exceptions thrown in
 * onData, onError, and onDone callbacks can be catched in the returned
 * Future. Whenever exception occured and catched, the subscription to the
 * stream is cancelled automatically if cancelOnError is set to true(default is
 * false).
 *
 * Notice that the value returned from onDone would be the completed value
 * of the returned Future.
 *
 * Also notice that for this utility the error event pass to onError is
 * deemed only as a special kind of data event and is not handled
 * by catchError of the returned Future.
 *
 * + [stream] - the source stream
 * + [onData] - the data event handling callbacks
 * + [onError] - the error event handling callbacks
 * + [onDone] - when the stream is closed
 * + [cancelOnError] - whether automatially unsubscribe from the stream if
 *                     exception thrown.
 */
Future listenStream(Stream stream, void onData(data),
                    void onError(err), onDone(), {bool cancelOnError: false}) {
  var cmpl = new Completer();
  var ss = stream.listen(null);
  ss.onData((data) {
    new Future.sync(() {
      if (!cmpl.isCompleted) {
        try {
          onData(data);
        } catch (err) {
          if (cancelOnError) ss.cancel();
          cmpl.completeError(err);
        }
      }
    })
    .catchError((err) {
      if (!cmpl.isCompleted) {
        if (cancelOnError) ss.cancel();
        cmpl.completeError(err);
      }
    });
  });

  ss.onError((errorEvent) {
    new Future.sync(() {
      if (!cmpl.isCompleted) {
        try {
          onError(errorEvent);
        } catch (err) {
          if (cancelOnError) ss.cancel();
          cmpl.completeError(err);
        }
      }
    })
    .catchError((err) {
      if (!cmpl.isCompleted) {
        if (cancelOnError) ss.cancel();
        cmpl.completeError(err);
      }
    });
  });

  ss.onDone(() {
    new Future.sync(() {
      if (!cmpl.isCompleted) {
        try {
          return onDone();
        } catch (err) {
          if (cancelOnError) ss.cancel();
          cmpl.completeError(err);
        }
      }
    })
    .then((value) {
      if (!cmpl.isCompleted) cmpl.complete(value);
    }
    .catchError((err) {
      if (!cmpl.isCompleted) {
        if (cancelOnError) ss.cancel();
        cmpl.completeError(err);
      }
    });
  });

  return cmpl.future;
}
