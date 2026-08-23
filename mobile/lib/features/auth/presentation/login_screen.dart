import 'package:anchor/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:anchor/core/network/server_config_provider.dart';
import 'package:anchor/core/theme/context_extensions.dart';
import 'package:anchor/core/theme/tokens/app_icon_sizes.dart';
import 'package:anchor/core/theme/tokens/app_radius.dart';
import 'package:anchor/core/widgets/app_snackbar.dart';
import 'package:anchor/features/auth/presentation/providers/oidc_config_provider.dart';
import 'package:anchor/features/auth/presentation/providers/registration_mode_provider.dart';
import 'auth_controller.dart';
import 'package:anchor/core/theme/tokens/app_opacity.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text, _passwordController.text);
    }
  }

  Future<void> _loginWithOidc() async {
    await ref.read(authControllerProvider.notifier).loginWithOidc();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final oidcConfigAsync = ref.watch(oidcConfigProvider);
    final registrationModeAsync = ref.watch(registrationModeProvider);
    final isLoading = state.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && previous?.isLoading == true) {
        AppSnackbar.showError(context, message: next.error.toString());
      }
    });

    final serverUrl = ref.watch(serverUrlProvider);
    final oidcConfig = oidcConfigAsync.hasValue ? oidcConfigAsync.value : null;
    final oidcConfigLoading = oidcConfigAsync.isLoading;
    final showLocalLogin =
        oidcConfig == null || !oidcConfig.disableInternalAuth;
    final signupDisabled =
        registrationModeAsync.hasValue &&
        registrationModeAsync.value == 'disabled';
    final dims = context.dims;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(dims.xl),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Server URL indicator
                  _ServerUrlChip(
                    serverUrl: serverUrl,
                    onChangeServer: () {
                      context.push(AppRoutes.serverConfig, extra: serverUrl);
                    },
                  ),
                  SizedBox(height: dims.xl),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: dims.xs),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: AppOpacity.secondary,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // OIDC Login button
                  if (oidcConfigLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(dims.xl),
                        child: const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (oidcConfig?.enabled == true) ...[
                    FilledButton.icon(
                      onPressed: isLoading ? null : _loginWithOidc,
                      icon: const Icon(
                        LucideIcons.logIn,
                        size: AppIconSizes.md,
                      ),
                      label: Text('Login with ${oidcConfig!.providerName}'),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: dims.md),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonBorder,
                        ),
                      ),
                    ),
                    if (showLocalLogin) ...[
                      SizedBox(height: dims.md),
                      const _OrDivider(),
                      SizedBox(height: dims.md),
                    ],
                  ],
                  if (showLocalLogin) ...[
                    TextFormField(
                      controller: _emailController,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(LucideIcons.mail),
                        border: const OutlineInputBorder(
                          borderRadius: AppRadius.mdBorder,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: dims.md),
                    TextFormField(
                      controller: _passwordController,
                      onChanged: (_) => setState(() {}),
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(LucideIcons.lock),
                        suffixIcon: _passwordController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                        border: const OutlineInputBorder(
                          borderRadius: AppRadius.mdBorder,
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: dims.xl),
                    FilledButton(
                      onPressed: isLoading ? null : _login,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: dims.md),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonBorder,
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                    if (!signupDisabled) ...[
                      SizedBox(height: dims.md),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.register),
                        child: const Text('Create an account'),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dims.md),
          child: Text(
            'Or continue with',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: AppOpacity.secondary),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _ServerUrlChip extends StatelessWidget {
  final String? serverUrl;
  final VoidCallback onChangeServer;

  const _ServerUrlChip({required this.serverUrl, required this.onChangeServer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;

    if (serverUrl == null) return const SizedBox.shrink();

    // Extract host from URL for display
    String displayUrl = serverUrl!;
    try {
      final uri = Uri.parse(serverUrl!);
      displayUrl = uri.host;
      if (uri.port != 80 && uri.port != 443) {
        displayUrl += ':${uri.port}';
      }
    } catch (_) {}

    return Center(
      child: InkWell(
        onTap: onChangeServer,
        borderRadius: AppRadius.lgBorder,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: dims.sm, vertical: dims.xs),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: AppRadius.lgBorder,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.server,
                size: AppIconSizes.xs,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                displayUrl,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(width: dims.xxs),
              Icon(
                LucideIcons.chevronDown,
                size: AppIconSizes.xs,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
