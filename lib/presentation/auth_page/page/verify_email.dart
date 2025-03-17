import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_navigation.dart';
import '../../../common/helper/navigation/app_navigator.dart';
import '../../../common/helper/toast/toast.dart';
import '../../../common/widgets/text_field.dart';
import '../../../service_locator.dart';
import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';

class EmailVerificationPage extends StatelessWidget {
  final String email;
  const EmailVerificationPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            AppNavigator.pushAndRemove(context, const AppNavigation());
          } else if (state is AuthError) {
            ToastHelper.showError(
              context: context,
              title: 'Error',
              description: state.message,
            );
          }
        },
        builder: (context, state) => EmailVerificationView(email: email, state: state),
      ),
    );
  }
}

class EmailVerificationView extends StatefulWidget {
  final String email;
  final AuthState state;
  const EmailVerificationView({super.key, required this.email, required this.state});

  @override
  _EmailVerificationViewState createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
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
                hintText: 'Verification Code',
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Code is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.state is AuthLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthCubit>().confirmEmail(
                      widget.email,
                      _codeController.text.trim(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: widget.state is AuthLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify'),
              ),
              TextButton(
                onPressed: widget.state is AuthLoading
                    ? null
                    : () => context.read<AuthCubit>().requestConfirmation(widget.email),
                child: const Text('Resend Code'),
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