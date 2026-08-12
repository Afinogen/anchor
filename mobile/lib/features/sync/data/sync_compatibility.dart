import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../settings/data/server_info_provider.dart';
import 'sync_api.dart';

part 'sync_compatibility.g.dart';

enum SyncCompatibility {
  ok,
  serverOutdated,
  appOutdated,

  unreachable;

  String? get message => switch (this) {
    ok || unreachable => null,
    serverOutdated =>
      'Your Anchor server is too old to sync with this app. '
          'Update the server to continue.',
    appOutdated =>
      'This app is too old to sync with your Anchor server. '
          'Update the app to continue.',
  };
}

@Riverpod(keepAlive: true)
Future<SyncCompatibility> syncCompatibility(Ref ref) async {
  final info = await ref.watch(serverInfoProvider.future);
  if (info == null) return SyncCompatibility.unreachable;
  if (info.syncProtocols.contains(syncProtocol)) return SyncCompatibility.ok;

  final serverIsAhead = info.syncProtocols.any(
    (protocol) => protocol > syncProtocol,
  );
  return serverIsAhead
      ? SyncCompatibility.appOutdated
      : SyncCompatibility.serverOutdated;
}
