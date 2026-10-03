import 'dart:async';

import 'package:flashcards/utils/result.dart';
import 'package:flutter/foundation.dart';

/// Runs saves without making the student wait for the server.
///
/// Firestore keeps every write on the device and sends it as soon as the
/// connection allows, so a review can move on to the next card right away.
/// Waiting for the server instead froze the screen on a weak connection.
class BackgroundSaver {
  final _errors = StreamController<Exception>.broadcast();
  final _pending = <Future<void>>{};

  /// Failed saves, to tell the student.
  Stream<Exception> get errors => _errors.stream;

  bool get hasPendingSaves => _pending.isNotEmpty;

  /// Waits (at most [timeout]) for the saves started so far, e.g. before
  /// loading cards that depend on them.
  Future<void> settle([Duration timeout = const Duration(seconds: 8)]) async {
    if (_pending.isEmpty) return;
    try {
      await Future.wait(_pending.toList()).timeout(timeout);
    } on Object {
      // Still saving on a slow connection, continue anyway.
    }
  }

  void run(String label, Future<Result<void>> Function() save) {
    late final Future<void> task;
    task = Future(save)
        .then((result) {
          if (result case Error(:final error)) _report(label, error);
        })
        .catchError((Object error) {
          _report(
            label,
            error is Exception ? error : Exception(error.toString()),
          );
        })
        .whenComplete(() => _pending.remove(task));
    _pending.add(task);
  }

  void _report(String label, Exception error) {
    debugPrint('Background save "$label" failed: $error');
    if (!_errors.isClosed) _errors.add(error);
  }

  void dispose() => _errors.close();
}

/// Reads that take longer than this show an error the student can retry,
/// instead of a loading screen that never ends.
Duration networkReadTimeout = const Duration(seconds: 20);

extension ResultTimeout<T> on Future<Result<T>> {
  Future<Result<T>> withReadTimeout([Duration? timeout]) {
    return this.timeout(
      timeout ?? networkReadTimeout,
      onTimeout: () => Result.error(
        TimeoutException(
          "The connection is too slow to load the next card. "
          "Check your internet and try again.",
        ),
      ),
    );
  }
}
