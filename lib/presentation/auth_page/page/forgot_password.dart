import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/helper/navigation/app_navigator.dart';
import '../../../common/helper/toast/toast.dart';
import '../../../common/widgets/text_field.dart';
import '../../../service_locator.dart';
import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';

class ForgotPasswordPage extends StatelessWidget {
  final String initialEmail;
  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ToastHelper.showError(
              context: context,
              title: 'Error',
              description: state.message,
            );
          }
        },
        builder: (context, state) => ForgotPasswordView(state: state, initialEmail: initialEmail),
      ),
    );
  }
}

class ForgotPasswordView extends StatefulWidget {
  final AuthState state;
  final String initialEmail;
  const ForgotPasswordView({super.key, required this.state, required this.initialEmail});

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.state is AuthLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthCubit>().requestReset(_emailController.text.trim());
                    AppNavigator.push(
                      context,
                      VerifyResetCodePage(email: _emailController.text.trim()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: widget.state is AuthLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Request Reset Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

class VerifyResetCodePage extends StatelessWidget {
  final String email;
  const VerifyResetCodePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ToastHelper.showError(
              context: context,
              title: 'Error',
              description: state.message,
            );
          }
        },
        builder: (context, state) => VerifyResetCodeView(email: email, state: state),
      ),
    );
  }
}

class VerifyResetCodeView extends StatefulWidget {
  final String email;
  final AuthState state;
  const VerifyResetCodeView({super.key, required this.email, required this.state});

  @override
  _VerifyResetCodeViewState createState() => _VerifyResetCodeViewState();
}

class _VerifyResetCodeViewState extends State<VerifyResetCodeView> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Reset Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Enter the code sent to ${widget.email}'),
              const SizedBox(height: 20),
              AuthTextField(
                controller: _codeController,
                hintText: 'Reset Code',
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Code is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.state is AuthLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthCubit>().verifyResetCode(
                      widget.email,
                      _codeController.text.trim(),
                    );
                    AppNavigator.push(
                      context,
                      ResetPasswordPage(
                        email: widget.email,
                        code: _codeController.text.trim(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: widget.state is AuthLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}

class ResetPasswordPage extends StatelessWidget {
  final String email;
  final String code;
  const ResetPasswordPage({super.key, required this.email, required this.code});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial && ModalRoute.of(context)?.isCurrent == true) {
            // Pop twice to return to SignInPage (assuming ForgotPassword -> VerifyResetCode -> ResetPassword)
            if (AppNavigator.canPop(context)) {
              AppNavigator.pop(context); // Pop ResetPassword
              if (AppNavigator.canPop(context)) {
                AppNavigator.pop(context); // Pop VerifyResetCode
              }
            }
            ToastHelper.showSuccess(
              context: context,
              title: 'Error',
              description: 'Password reset successfully',
            );
          } else if (state is AuthError) {
            ToastHelper.showError(
              context: context,
              title: 'Error',
              description: state.message,
            );
          }
        },
        builder: (context, state) => ResetPasswordView(email: email, code: code, state: state),
      ),
    );
  }
}

class ResetPasswordView extends StatefulWidget {
  final String email;
  final String code;
  final AuthState state;
  const ResetPasswordView(
      {super.key, required this.email, required this.code, required this.state});

  @override
  _ResetPasswordViewState createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isPasswordSecure(String password) {
    final hasLength = password.length >= 8;
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*]').hasMatch(password);
    return hasLength && hasNumber && hasSpecial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                controller: _passwordController,
                hintText: 'New Password',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Password is required';
                  if (!_isPasswordSecure(value))
                    return 'Password must be 8+ chars with numbers & special chars';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon:
                  Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Confirm password is required';
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.state is AuthLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthCubit>().resetPassword(
                      widget.email,
                      widget.code,
                      _passwordController.text,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: widget.state is AuthLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}