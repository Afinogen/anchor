import 'package:anchor/core/router/app_routes.dart';
import 'package:anchor/features/auth/presentation/providers/oidc_config_provider.dart';
import 'package:anchor/features/auth/presentation/providers/registration_mode_provider.dart';
import 'package:anchor/features/settings/data/server_info_provider.dart';
import 'package:anchor/features/sync/data/sync_compatibility.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../extensions/build_context_l10n.dart';
import '../network/dio_provider.dart';
import '../network/server_config_provider.dart';
import '../theme/context_extensions.dart';
import '../theme/tokens/app_icon_sizes.dart';
import '../theme/tokens/app_radius.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/anchor_icon.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/language_toggle_button.dart';

class ServerConfigScreen extends ConsumerStatefulWidget {
  final String? initialUrl;

  const ServerConfigScreen({super.key, this.initialUrl});

  @override
  ConsumerState<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends ConsumerState<ServerConfigScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isTesting = false;
  bool _isConnecting = false;
  String? _error;

  bool get _isLoading => _isTesting || _isConnecting;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialUrl;
    if (initial != null && initial.isNotEmpty) {
      _urlController.text = initial;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _handleError(Object e) {
    String errorMessage;
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = context.l10n.connectionTimedOut;
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = context.l10n.couldNotConnect;
      } else if (e.type == DioExceptionType.badCertificate) {
        errorMessage = context.l10n.certificateErrorTryToggle;
      } else {
        errorMessage = context.l10n.failedToConnect;
      }
    } else {
      errorMessage = context.l10n.failedToConnect;
    }
    setState(() {
      _error = errorMessage;
    });
  }

  Future<String?> _prepareUrl() async {
    if (!_formKey.currentState!.validate()) return null;
    String url = _urlController.text.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  Dio _getDio() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    final allowSelfSigned =
        ref.read(allowSelfSignedCertProvider).value ?? false;
    final url = _urlController.text.trim();
    if (allowSelfSigned && url.isNotEmpty) {
      dio.httpClientAdapter = createSelfSignedCertAdapter(url);
    }
    return dio;
  }

  Future<void> _testConnection() async {
    final url = await _prepareUrl();
    if (url == null) return;

    setState(() {
      _isTesting = true;
      _error = null;
    });

    try {
      final dio = _getDio();
      final response = await dio.get('$url/api/health');

      if (response.statusCode == 200 && response.data['app'] == 'anchor') {
        final version = response.data['version'] ?? 'Unknown';
        final compatibility = _compatibilityOf(response);
        if (mounted) {
          if (compatibility.isMismatch) {
            AppSnackbar.showWarning(
              context,
              message: context.l10n.serverVersionMismatch(
                version.toString(),
                compatibility.localizedMessage(context.l10n) ?? '',
              ),
            );
          } else {
            AppSnackbar.showSuccess(
              context,
              message: context.l10n.serverRunningVersion(version.toString()),
            );
          }
        }
      } else {
        setState(() {
          _error = context.l10n.invalidServerResponse;
        });
      }
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  Future<void> _connect() async {
    final url = await _prepareUrl();
    if (url == null) return;

    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      final dio = _getDio();
      final response = await dio.get('$url/api/health');

      if (response.statusCode == 200 && response.data['app'] == 'anchor') {
        final compatibility = _compatibilityOf(response);
        if (compatibility.isMismatch &&
            !await _confirmMismatch(compatibility)) {
          return;
        }

        final shouldPop = widget.initialUrl != null;
        final notifier = ref.read(serverConfigProvider.notifier);

        if (mounted) {
          if (shouldPop) {
            context.pop();
          } else {
            context.go(AppRoutes.login);
          }
        }

        await notifier.setServerUrl(url);
        ref.invalidate(oidcConfigProvider);
        ref.invalidate(registrationModeProvider);
        ref.invalidate(serverInfoProvider);
      } else {
        setState(() {
          _error = context.l10n.invalidServerResponse;
        });
      }
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  SyncCompatibility _compatibilityOf(Response<dynamic> response) {
    final protocols =
        (response.data['protocols'] as List?)?.whereType<int>().toList() ??
        const <int>[];
    return compatibilityFor(protocols);
  }

  Future<bool> _confirmMismatch(SyncCompatibility compatibility) async {
    if (!mounted) return false;
    final confirmed = await ConfirmDialog.show(
      context: context,
      icon: LucideIcons.triangleAlert,
      iconColor: Theme.of(context).colorScheme.error,
      title: compatibility.localizedTitle(context.l10n)!,
      message: compatibility.localizedMessage(context.l10n)!,
      confirmText: context.l10n.connectAnyway,
    );
    return confirmed ?? false;
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.pleaseEnterServerUrl;
    }

    final url = value.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return context.l10n.urlMustStartWith;
    }

    try {
      final uri = Uri.parse(url);
      if (uri.host.isEmpty) {
        return context.l10n.pleaseEnterValidUrl;
      }
    } catch (_) {
      return context.l10n.pleaseEnterValidUrl;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;
    final allowSelfSigned =
        ref.watch(allowSelfSignedCertProvider).value ?? false;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(dims.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: AnchorIcon(size: 100)),
                      const SizedBox(height: 48),

                      // Title
                      Text(
                        context.l10n.connectToServer,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: dims.xs),

                      // Subtitle
                      Text(
                        context.l10n.enterServerUrl,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // URL Input
                      TextFormField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: context.l10n.serverUrl,
                          hintText: context.l10n.serverUrlHint,
                          prefixIcon: const Icon(LucideIcons.globe),
                          border: const OutlineInputBorder(
                            borderRadius: AppRadius.mdBorder,
                          ),
                          helperText: context.l10n.serverUrlHelper,
                        ),
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                        validator: _validateUrl,
                      ),
                      SizedBox(height: dims.xs),

                      // Self-signed certificate toggle
                      Row(
                        children: [
                          Icon(
                            LucideIcons.shieldOff,
                            size: 18,
                            color: allowSelfSigned
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                          SizedBox(width: dims.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.allowSelfSigned,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                if (allowSelfSigned)
                                  Text(
                                    context.l10n.selfSignedWarning,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: allowSelfSigned,
                            onChanged: (value) {
                              ref
                                  .read(allowSelfSignedCertProvider.notifier)
                                  .toggle(value);
                              if (value && mounted) {
                                AppSnackbar.showWarning(
                                  context,
                                  message: context.l10n.selfSignedSnackbar,
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      // Error message
                      if (_error != null) ...[
                        SizedBox(height: dims.xs),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      SizedBox(height: dims.xl),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _testConnection,
                              icon: _isTesting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(LucideIcons.wifi),
                              label: Text(context.l10n.test),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: dims.md,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.buttonBorder,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: dims.md),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isLoading ? null : _connect,
                              icon: _isConnecting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(LucideIcons.arrowRight),
                              label: Text(context.l10n.connect),
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: dims.md,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.buttonBorder,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: dims.xxl),

                      // Info text
                      Container(
                        padding: EdgeInsets.all(dims.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: AppRadius.smBorder,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.info,
                              size: AppIconSizes.md,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: dims.sm),
                            Expanded(
                              child: Text(
                                context.l10n.selfHostedInfo,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(dims.sm),
                child: const LanguageToggleButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
