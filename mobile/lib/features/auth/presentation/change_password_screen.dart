import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:anchor/core/widgets/app_snackbar.dart';
import 'package:anchor/core/widgets/settings_card.dart';
import '../../../core/widgets/large_title_app_bar.dart';
import 'auth_controller.dart';
import '../../../core/theme/context_extensions.dart';
import '../../../core/theme/tokens/app_radius.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authControllerProvider.notifier)
          .changePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
          );

      if (mounted) {
        final state = ref.read(authControllerProvider);
        if (!state.hasError) {
          AppSnackbar.showSuccess(
            context,
            message: 'Password changed successfully',
          );
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        AppSnackbar.showError(context, message: next.error.toString());
      }
    });

    final theme = Theme.of(context);
    final dims = context.dims;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.colorTokens.pageGradient),
        child: CustomScrollView(
          slivers: [
            // App Bar
            LargeTitleAppBar(title: 'Change Password'),

            // Form Content
            SliverPadding(
              padding: EdgeInsets.all(dims.md),
              sliver: SliverToBoxAdapter(
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SettingsCard(
                          child: Padding(
                            padding: EdgeInsets.all(dims.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Update your password to keep your account secure',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                SizedBox(height: dims.xl),
                                TextFormField(
                                  controller: _currentPasswordController,
                                  onChanged: (_) => setState(() {}),
                                  autofillHints: const [AutofillHints.password],
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Current Password',
                                    prefixIcon: const Icon(LucideIcons.lock),
                                    suffixIcon:
                                        _currentPasswordController.text.isEmpty
                                        ? null
                                        : IconButton(
                                            icon: Icon(
                                              _isCurrentPasswordVisible
                                                  ? LucideIcons.eyeOff
                                                  : LucideIcons.eye,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.4),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isCurrentPasswordVisible =
                                                    !_isCurrentPasswordVisible;
                                              });
                                            },
                                          ),
                                    filled: true,
                                    border: const OutlineInputBorder(
                                      borderRadius: AppRadius.mdBorder,
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.all(dims.md),
                                  ),
                                  obscureText: !_isCurrentPasswordVisible,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your current password';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: dims.md),
                                TextFormField(
                                  controller: _newPasswordController,
                                  onChanged: (_) => setState(() {}),
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                    prefixIcon: const Icon(LucideIcons.lock),
                                    suffixIcon:
                                        _newPasswordController.text.isEmpty
                                        ? null
                                        : IconButton(
                                            icon: Icon(
                                              _isNewPasswordVisible
                                                  ? LucideIcons.eyeOff
                                                  : LucideIcons.eye,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.4),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isNewPasswordVisible =
                                                    !_isNewPasswordVisible;
                                              });
                                            },
                                          ),
                                    filled: true,
                                    border: const OutlineInputBorder(
                                      borderRadius: AppRadius.mdBorder,
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.all(dims.md),
                                  ),
                                  obscureText: !_isNewPasswordVisible,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a new password';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: dims.md),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  onChanged: (_) => setState(() {}),
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _changePassword(),
                                  decoration: InputDecoration(
                                    labelText: 'Confirm New Password',
                                    prefixIcon: const Icon(
                                      LucideIcons.keyRound,
                                    ),
                                    suffixIcon:
                                        _confirmPasswordController.text.isEmpty
                                        ? null
                                        : IconButton(
                                            icon: Icon(
                                              _isConfirmPasswordVisible
                                                  ? LucideIcons.eyeOff
                                                  : LucideIcons.eye,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.4),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isConfirmPasswordVisible =
                                                    !_isConfirmPasswordVisible;
                                              });
                                            },
                                          ),
                                    filled: true,
                                    border: const OutlineInputBorder(
                                      borderRadius: AppRadius.mdBorder,
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.all(dims.md),
                                  ),
                                  obscureText: !_isConfirmPasswordVisible,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your new password';
                                    }
                                    if (value != _newPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: dims.xxl),
                                FilledButton(
                                  onPressed: isLoading ? null : _changePassword,
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: dims.md,
                                    ),
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
                                      : const Text('Change Password'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
