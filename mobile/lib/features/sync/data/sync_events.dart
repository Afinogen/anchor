import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/anchor_protocol.dart';
import '../../../core/network/sync_requester.dart';
import 'sync_api.dart';

part 'sync_events.g.dart';

const String _tag = 'SyncEvents';

/// The server sends a keep-alive every 25s; a longer gap means it has died.
const Duration _heartbeatTimeout = Duration(seconds: 60);

const Duration _minRetryDelay = Duration(seconds: 1);
const Duration _maxRetryDelay = Duration(seconds: 60);

@Riverpod(keepAlive: true)
SyncEvents syncEvents(Ref ref) {
  final events = SyncEvents(ref.watch(dioProvider));
  ref.onDispose(events.disconnect);
  return events;
}

/// Holds a live connection open and starts a sync whenever the server says
/// something changed. The message carries no data of its own.
class SyncEvents {
  SyncEvents(this._dio);

  final Dio _dio;
  final Random _random = Random();

  bool _connected = false;
  bool _wasOpen = false;
  int _attempt = 0;
  CancelToken? _cancelToken;
  StreamSubscription<String>? _lines;
  Timer? _retry;
  Timer? _watchdog;

  void connect() {
    if (_connected) return;
    _connected = true;
    _attempt = 0;
    unawaited(_open());
  }

  void disconnect() {
    _connected = false;
    _wasOpen = false;
    _closeStream();
    _retry?.cancel();
    _retry = null;
  }

  Future<void> _open() async {
    if (!_connected) return;
    _closeStream();

    final token = CancelToken();
    _cancelToken = token;
    try {
      final response = await _dio.get<ResponseBody>(
        syncEventsPath,
        cancelToken: token,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: Duration.zero,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      final body = response.data;
      if (body == null) {
        _scheduleRetry();
        return;
      }

      _resetWatchdog();
      AppLogger.instance.info(_tag, 'Push channel open');

      // Messages sent while we were disconnected are lost.
      if (_wasOpen) scheduleAppSync(trigger: 'reconnect');
      _wasOpen = true;

      var event = '';
      _lines = body.stream
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter())
          .listen(
            (line) {
              _attempt = 0;
              _resetWatchdog();
              if (line.startsWith('event:')) {
                event = line.substring('event:'.length).trim();
                return;
              }
              if (line.isNotEmpty) return;
              if (event == 'sync') {
                scheduleAppSync(trigger: 'push');
              }
              event = '';
            },
            onError: (Object error) => _scheduleRetry(error: error),
            onDone: _scheduleRetry,
            cancelOnError: true,
          );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      if (error.response?.statusCode == 404) {
        AppLogger.instance.warn(
          _tag,
          'Server has no push channel; falling back to polling',
        );
        disconnect();
        return;
      }
      if (error.response?.statusCode == upgradeRequiredStatus) {
        AppLogger.instance.warn(_tag, 'Server refused our sync protocol');
        disconnect();
        scheduleAppSync(trigger: 'protocol');
        return;
      }
      _scheduleRetry(error: error);
    } catch (error) {
      _scheduleRetry(error: error);
    }
  }

  void _scheduleRetry({Object? error}) {
    _closeStream();
    if (!_connected || _retry != null) return;

    final delay = _nextDelay();
    if (error != null) {
      AppLogger.instance.warn(
        _tag,
        'Push channel dropped, retrying in ${delay.inMilliseconds}ms',
        error: error,
      );
    }
    _retry = Timer(delay, () {
      _retry = null;
      unawaited(_open());
    });
  }

  Duration _nextDelay() {
    final backoff = _minRetryDelay.inMilliseconds * (1 << _attempt);
    final capped = min(backoff, _maxRetryDelay.inMilliseconds);
    _attempt = min(_attempt + 1, 6);
    // ±25% so reconnecting devices don't all arrive at once.
    final jitter = 0.75 + _random.nextDouble() * 0.5;
    return Duration(milliseconds: (capped * jitter).round());
  }

  void _resetWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(_heartbeatTimeout, () {
      _scheduleRetry(error: StateError('no heartbeat'));
    });
  }

  void _closeStream() {
    _watchdog?.cancel();
    _watchdog = null;
    unawaited(_lines?.cancel());
    _lines = null;
    _cancelToken?.cancel();
    _cancelToken = null;
  }
}
