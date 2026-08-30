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

String _$syncCompatibilityHash() => r'4c95074af9bcb3a80d603809c76ea43e5a7fc2f1';
