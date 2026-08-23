import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/data/server_info_provider.dart';
import '../../features/sync/data/sync_compatibility.dart';
import '../../features/sync/data/sync_events.dart';
import '../../features/sync/data/sync_service.dart';
import '../logging/app_logger.dart';
import '../providers/active_user_id_provider.dart';
import 'server_config_provider.dart';
import 'anchor_protocol.dart';
import 'sync_requester.dart';

part 'connectivity_provider.g.dart';

bool isOnlineFromResults(List<ConnectivityResult> results) =>
    results.isNotEmpty && !results.contains(ConnectivityResult.none);

@riverpod
Stream<List<ConnectivityResult>> connectivityStream(Ref ref) {
  return Connectivity().onConnectivityChanged;
}

/// How often to sync anyway, for servers and proxies with no live connection.
const Duration _pollInterval = Duration(minutes: 5);

@riverpod
class SyncManager extends _$SyncManager {
  bool _wasOffline = false;
  bool _rerunRequested = false;
  bool _isForeground = true;
  Future<void>? _activeSync;
  AppLifecycleListener? _lifecycleListener;
  Timer? _poll;

  @override
  bool build() {
    registerAppSyncRequester(requestSync);
    ref.onDispose(() => registerAppSyncRequester(null));

    _lifecycleListener = AppLifecycleListener(
      onResume: _onResume,
      onHide: _onHide,
    );
    ref.onDispose(() {
      _lifecycleListener?.dispose();
      _poll?.cancel();
    });

    ref.listen<AsyncValue<List<ConnectivityResult>>>(
      connectivityStreamProvider,
      (previous, next) {
        next.whenData((results) {
          if (isOnlineFromResults(results) && _wasOffline) {
            requestSync();
          }

          _wasOffline = !isOnlineFromResults(results);
        });
      },
    );

    ref.listen<String?>(activeUserIdProvider, (previous, next) {
      _applyLiveUpdates();
      if (next != null && next != previous) {
        requestSync();
      }
    });

    // Changing the server URL builds a new one, disconnected.
    ref.listen<SyncEvents>(
      syncEventsProvider,
      (previous, next) => _applyLiveUpdates(),
    );

    _applyLiveUpdates();
    _checkInitialState();

    return false; // isSyncing
  }

  void _onResume() {
    _isForeground = true;
    _applyLiveUpdates();
    requestSync();
  }

  void _onHide() {
    _isForeground = false;
    _applyLiveUpdates();
  }

  void _applyLiveUpdates() {
    final events = ref.read(syncEventsProvider);
    if (_isForeground && ref.read(activeUserIdProvider) != null) {
      events.connect();
      _poll ??= Timer.periodic(
        _pollInterval,
        (_) => scheduleAppSync(trigger: 'poll'),
      );
    } else {
      events.disconnect();
      _poll?.cancel();
      _poll = null;
    }
  }

  Future<void> _checkInitialState() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _wasOffline =
          results.isEmpty || results.contains(ConnectivityResult.none);
      if (!_wasOffline) {
        requestSync();
      }
    } catch (e) {
      _wasOffline = true;
    }
  }

  Future<void> requestSync() {
    final userId = ref.read(activeUserIdProvider);
    if (userId == null) return Future.value();

    final activeSync = _activeSync;
    if (activeSync != null) {
      _rerunRequested = true;
      return activeSync;
    }

    final syncFuture = _runSyncLoop();
    _activeSync = syncFuture;
    return syncFuture;
  }

  Future<void> _runSyncLoop() async {
    state = true;
    try {
      do {
        _rerunRequested = false;
        try {
          await _runSyncCycle();
        } catch (e, stack) {
          AppLogger.instance.error(
            'Sync',
            'Sync failed',
            error: e,
            stackTrace: stack,
          );
          break;
        }
      } while (_rerunRequested && ref.read(activeUserIdProvider) != null);
    } finally {
      state = false;
      _activeSync = null;
    }
  }

  Future<void> _runSyncCycle() async {
    final serverUrl = await ref.read(serverConfigProvider.future);
    await ref.read(allowSelfSignedCertProvider.future);
    if (serverUrl == null || serverUrl.isEmpty) {
      AppLogger.instance.info(
        'Sync',
        'App sync cycle skipped: no server configured',
      );
      return;
    }

    if (!await _serverSpeaksOurProtocol()) return;

    try {
      await ref.read(syncServiceProvider).run();
    } on DioException catch (error) {
      if (error.response?.statusCode != upgradeRequiredStatus) rethrow;
      AppLogger.instance.warn('Sync', 'Server refused our sync protocol');
      ref.invalidate(serverInfoProvider);
    }
  }

  Future<bool> _serverSpeaksOurProtocol() async {
    final compatibility = await ref.read(syncCompatibilityProvider.future);
    switch (compatibility) {
      case SyncCompatibility.ok:
        _applyLiveUpdates();
        return true;
      case SyncCompatibility.unreachable:
        // Let the sync itself report the real network error.
        ref.invalidate(serverInfoProvider);
        return true;
      case SyncCompatibility.serverOutdated:
      case SyncCompatibility.appOutdated:
        AppLogger.instance.warn('Sync', compatibility.message!);
        ref.read(syncEventsProvider).disconnect();
        // Ask again next cycle, so a server update needs no app restart.
        ref.invalidate(serverInfoProvider);
        return false;
    }
  }

  Future<void> manualSync() async {
    await requestSync();
  }
}

@riverpod
bool isOnline(Ref ref) {
  final connectivity = ref.watch(connectivityStreamProvider);
  return connectivity.maybeWhen(data: isOnlineFromResults, orElse: () => true);
}
