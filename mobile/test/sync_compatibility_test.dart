import 'package:anchor/core/network/anchor_protocol.dart';
import 'package:anchor/features/settings/data/server_info_provider.dart';
import 'package:anchor/features/sync/data/sync_compatibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compatibilityFor', () {
    test('syncs when the server advertises our protocol', () {
      expect(compatibilityFor([anchorProtocol]), SyncCompatibility.ok);
    });

    test('syncs when our protocol sits inside the advertised range', () {
      expect(
        compatibilityFor([
          anchorProtocol - 1,
          anchorProtocol,
          anchorProtocol + 1,
        ]),
        SyncCompatibility.ok,
      );
    });

    test('blames the app when every server protocol is ahead', () {
      expect(
        compatibilityFor([anchorProtocol + 1, anchorProtocol + 2]),
        SyncCompatibility.appOutdated,
      );
    });

    test('blames the server when every server protocol is behind', () {
      expect(
        compatibilityFor([anchorProtocol - 2, anchorProtocol - 1]),
        SyncCompatibility.serverOutdated,
      );
    });

    test('treats a server that advertises nothing as outdated', () {
      expect(compatibilityFor([]), SyncCompatibility.serverOutdated);
    });
  });

  group('SyncCompatibility copy', () {
    test('a mismatch carries something to show the user', () {
      for (final state in [
        SyncCompatibility.serverOutdated,
        SyncCompatibility.appOutdated,
      ]) {
        expect(state.isMismatch, isTrue);
        expect(state.title, isNotNull);
        expect(state.message, isNotNull);
      }
    });

    test('a working or unknown server says nothing', () {
      for (final state in [
        SyncCompatibility.ok,
        SyncCompatibility.unreachable,
      ]) {
        expect(state.isMismatch, isFalse);
        expect(state.message, isNull);
      }
    });
  });

  group('ServerInfo.fromJson', () {
    test('reads the advertised protocols', () {
      final info = ServerInfo.fromJson({
        'app': 'anchor',
        'version': '0.16.0',
        'protocols': [3, 4],
      });

      expect(info.protocols, [3, 4]);
      expect(compatibilityFor(info.protocols), SyncCompatibility.ok);
    });

    test('falls back to no protocols on a server that omits them', () {
      final info = ServerInfo.fromJson({'app': 'anchor', 'version': '0.9.0'});

      expect(info.protocols, isEmpty);
      expect(
        compatibilityFor(info.protocols),
        SyncCompatibility.serverOutdated,
      );
    });
  });
}
