import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';

part 'server_info_provider.g.dart';

class ServerInfo {
  final String version;
  final String app;

  /// Sync protocols the server understands. Empty on a server old enough not to
  /// advertise them.
  final List<int> syncProtocols;

  ServerInfo({
    required this.version,
    required this.app,
    this.syncProtocols = const [],
  });

  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    return ServerInfo(
      version: json['version'] as String? ?? 'Unknown',
      app: json['app'] as String? ?? 'Unknown',
      syncProtocols:
          (json['syncProtocols'] as List?)?.whereType<int>().toList() ??
          const [],
    );
  }
}

@riverpod
Future<ServerInfo?> serverInfo(Ref ref) async {
  try {
    final dio = ref.watch(dioProvider);
    final response = await dio.get('/api/health');

    if (response.statusCode == 200) {
      return ServerInfo.fromJson(response.data);
    }
    return null;
  } catch (e) {
    // Return null if we can't fetch server info (e.g., offline)
    return null;
  }
}
