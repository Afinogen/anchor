// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_compatibility.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncCompatibility)
const syncCompatibilityProvider = SyncCompatibilityProvider._();

final class SyncCompatibilityProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncCompatibility>,
          SyncCompatibility,
          FutureOr<SyncCompatibility>
        >
    with
        $FutureModifier<SyncCompatibility>,
        $FutureProvider<SyncCompatibility> {
  const SyncCompatibilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncCompatibilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncCompatibilityHash();

  @$internal
  @override
  $FutureProviderElement<SyncCompatibility> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SyncCompatibility> create(Ref ref) {
    return syncCompatibility(ref);
  }
}

String _$syncCompatibilityHash() => r'1001c8e31985ebe6cf38f460bd1678182717006a';
