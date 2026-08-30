import 'package:anchor/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:anchor/core/theme/context_extensions.dart';
import 'package:anchor/core/theme/tokens/app_radius.dart';
import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'package:anchor/core/widgets/app_snackbar.dart';
import 'auth_controller.dart';
import '../data/repository/auth_repository.dart';
import 'package:anchor/core/theme/tokens/app_opacity.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            _emailController.text,
            _passwordController.text,
            _nameController.text.trim(),
          );

      if (mounted) {
        final state = ref.read(authControllerProvider);
        if (!state.hasError) {
          // Check if user was logged in (has token) or is pending approval
          final token = await ref.read(authRepositoryProvider).getToken();
          if (token != null) {
            // User is active, navigate to home
            if (mounted) {
              AppSnackbar.showSuccess(
                context,
                message: context.l10n.registrationSuccessful,
              );
              context.go(AppRoutes.home);
            }
          } else {
            // User is pending approval
            if (mounted) {
              AppSnackbar.showSuccess(
                context,
                message: context.l10n.registrationPendingApproval,
              );
              context.go(AppRoutes.login);
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;
    final dims = context.dims;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        AppSnackbar.showError(context, message: next.error.toString());
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
      ),
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
                  Text(
                    context.l10n.createAccount,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: dims.xs),
                  Text(
                    context.l10n.startCapturingIdeas,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: AppOpacity.secondary,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _nameController,
                    autofillHints: const [AutofillHints.name],
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: context.l10n.name,
                      prefixIcon: const Icon(LucideIcons.user),
                      border: const OutlineInputBorder(
                        borderRadius: AppRadius.mdBorder,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.pleaseEnterName;
                      }
                      if (value.trim().length > 100) {
                        return context.l10n.nameTooLong;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: dims.md),
                  TextFormField(
                    controller: _emailController,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: context.l10n.email,
                      prefixIcon: const Icon(LucideIcons.mail),
                      border: const OutlineInputBorder(
                        borderRadius: AppRadius.mdBorder,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.pleaseEnterEmail;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: dims.md),
                  TextFormField(
                    controller: _passwordController,
                    onChanged: (_) => setState(() {}),
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: context.l10n.password,
                      prefixIcon: const Icon(LucideIcons.lock),
                      suffixIcon: _passwordController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? LucideIcons.eyeOff
                                    : LucideIcons.eye,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.4),
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
                        return context.l10n.pleaseEnterPassword;
                      }
                      if (value.length < 8) {
                        return context.l10n.passwordMinLength;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: dims.md),
                  TextFormField(
                    controller: _confirmPasswordController,
                    onChanged: (_) => setState(() {}),
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _register(),
                    decoration: InputDecoration(
                      labelText: context.l10n.confirmPassword,
                      prefixIcon: const Icon(LucideIcons.keyRound),
                      suffixIcon: _confirmPasswordController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? LucideIcons.eyeOff
                                    : LucideIcons.eye,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                      border: const OutlineInputBorder(
                        borderRadius: AppRadius.mdBorder,
                      ),
                    ),
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return context.l10n.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: dims.xl),
                  FilledButton(
                    onPressed: isLoading ? null : _register,
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.createAccount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
