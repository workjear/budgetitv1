import 'package:budgeit/presentation/auth_page/page/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgeit/app_navigation.dart';
import 'package:budgeit/common/helper/navigation/app_navigator.dart';
import 'package:budgeit/core/config/assets/app_images.dart';
import 'package:budgeit/presentation/auth_page/bloc/auth/auth_cubit.dart';
import 'package:budgeit/presentation/auth_page/bloc/auth/auth_state.dart';
import 'package:budgeit/presentation/auth_page/page/signup.dart';
import 'package:budgeit/service_locator.dart';
import '../../../common/helper/toast/toast.dart';
import '../../../common/widgets/text_field.dart';
import '../../../core/config/themes/app_theme.dart';
import 'forgot_password.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>()..resetState(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            AppNavigator.pushAndRemove(context, const AppNavigation());
          } else if (state is AuthEmailVerificationPending) {
            AppNavigator.push(context, EmailVerificationPage(email: state.email));
          } else if (state is AuthError) {
            ToastHelper.showError(
              context: context,
              title: 'Error',
              description: 'Sign In Failed: ${state.message}',
            );
          }
        },
        builder: (context, state) {
          return SignInView(state: state);
        },
      ),
    );
  }
}

class SignInView extends StatefulWidget {
  final AuthState state;

  const SignInView({super.key, required this.state});

  @override
  _SignInViewState createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  Image.asset(width: 200, AppImages.logo),
                  SizedBox(height: screenHeight * 0.05),
                  Text("Welcome!", style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: screenHeight * 0.05),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value!.isEmpty ? 'Email is required' : null,
                        ),
                        SizedBox(height: 16),
                        AuthTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: true,
                          validator: (value) => value!.isEmpty ? 'Password is required' : null,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: widget.state is AuthLoading
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().signIn(
                                _emailController.text,
                                _passwordController.text,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: widget.state is AuthLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Sign in"),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => AppNavigator.push(
                            context,
                            ForgotPasswordPage(initialEmail: _emailController.text),
                          ),
                          child: const Text('Forgot Password?'),
                        ),
                        TextButton(
                          onPressed: () => AppNavigator.push(context, const SignUpPage()),
                          child: const Text.rich(
                            TextSpan(
                              text: "Don’t have an account? ",
                              children: [
                                TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(color: AppTheme.primaryColor)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}