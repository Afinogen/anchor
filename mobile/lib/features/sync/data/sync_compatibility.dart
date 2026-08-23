import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/anchor_protocol.dart';
import '../../settings/data/server_info_provider.dart';

part 'sync_compatibility.g.dart';

enum SyncCompatibility {
  ok,
  serverOutdated,
  appOutdated,

  unreachable;

  bool get isMismatch =>
      this == SyncCompatibility.serverOutdated ||
      this == SyncCompatibility.appOutdated;

  String? get title => switch (this) {
    ok || unreachable => null,
    serverOutdated => 'Server needs updating',
    appOutdated => 'App needs updating',
  };

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

/// Whether this build can sync with a server advertising [serverProtocols].
SyncCompatibility compatibilityFor(List<int> serverProtocols) {
  // A server that advertises nothing predates the protocol.
  if (serverProtocols.isEmpty) return SyncCompatibility.serverOutdated;
  if (serverProtocols.contains(anchorProtocol)) return SyncCompatibility.ok;

  return serverProtocols.any((protocol) => protocol > anchorProtocol)
      ? SyncCompatibility.appOutdated
      : SyncCompatibility.serverOutdated;
}

@Riverpod(keepAlive: true)
Future<SyncCompatibility> syncCompatibility(Ref ref) async {
  final info = await ref.watch(serverInfoProvider.future);
  if (info == null) return SyncCompatibility.unreachable;
  return compatibilityFor(info.protocols);
}
