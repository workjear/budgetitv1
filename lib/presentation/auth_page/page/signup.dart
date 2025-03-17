import 'package:budgeit/presentation/auth_page/page/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgeit/app_navigation.dart';
import 'package:budgeit/common/helper/navigation/app_navigator.dart';
import 'package:budgeit/core/config/assets/app_images.dart';
import 'package:budgeit/presentation/auth_page/bloc/auth/auth_cubit.dart';
import 'package:budgeit/presentation/auth_page/bloc/auth/auth_state.dart';
import 'package:budgeit/presentation/auth_page/bloc/department/department_cubit.dart';
import 'package:budgeit/presentation/auth_page/bloc/department/department_state.dart';
import 'package:budgeit/presentation/auth_page/page/signin.dart';
import 'package:budgeit/service_locator.dart';
import '../../../common/helper/toast/toast.dart';
import '../../../common/widgets/text_field.dart';
import '../../../core/config/themes/app_theme.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
              description: state.message,
            );
          }
        },
        builder: (context, state) {
          return BlocBuilder<DepartmentCubit, DepartmentState>(
            builder: (context, departmentState) {
              return SignUpView(state: state, departmentState: departmentState);
            },
          );
        },
      ),
    );
  }
}

class SignUpView extends StatefulWidget {
  final AuthState state;
  final DepartmentState departmentState;

  const SignUpView({super.key, required this.state, required this.departmentState});

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedBirthdate;
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.08),
                  Image.asset(width: 200, AppImages.logo),
                  SizedBox(height: screenHeight * 0.03),
                  Text("Sign Up", style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: screenHeight * 0.03),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DepartmentSelector(departmentState: widget.departmentState),
                        SizedBox(height: 16),
                        AuthTextField(
                          controller: _fullNameController,
                          hintText: 'Full name',
                          validator: (value) => value!.isEmpty ? 'Full name is required' : null,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          items: gender,
                          icon: const Icon(Icons.expand_more),
                          onChanged: (value) => setState(() => _selectedGender = value),
                          decoration: const InputDecoration(hintText: 'Gender'),
                          validator: (value) => value == null ? 'Gender is required' : null,
                        ),
                        SizedBox(height: 16),
                        BirthdateField(
                          selectedBirthdate: _selectedBirthdate,
                          onDateSelected: (date) => setState(() => _selectedBirthdate = date),
                        ),
                        SizedBox(height: 16),
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
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return 'Password is required';
                            if (!_isPasswordSecure(value)) return 'Password must be 8+ chars with numbers & special chars';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        AuthTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return 'Confirm password is required';
                            if (value != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: widget.state is AuthLoading
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              if (widget.departmentState.selectedDepartment == null) {
                                ToastHelper.showWarning(
                                  context: context,
                                  title: 'Error',
                                  description: 'Please select department',
                                );
                                return;
                              }
                              context.read<AuthCubit>().signup(
                                fullName: _fullNameController.text,
                                email: _emailController.text,
                                gender: _selectedGender ?? '',
                                password: _passwordController.text,
                                birthdate: _selectedBirthdate ?? DateTime.now(),
                                enrolledProgram: widget.departmentState.selectedDepartment!,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: widget.state is AuthLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Sign Up"),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => AppNavigator.push(context, const SignInPage()),
                          child: const Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              children: [
                                TextSpan(text: "Sign in", style: TextStyle(color: AppTheme.primaryColor)),
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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class DepartmentSelector extends StatelessWidget {
  final DepartmentState departmentState;

  const DepartmentSelector({super.key, required this.departmentState});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDepartmentBottomSheet(
        context: context,
        title: 'Select Department',
        departments: departmentState.departments,
        selectedDepartment: departmentState.selectedDepartment,
        onSelected: (value) => context.read<DepartmentCubit>().selectDepartment(value!),
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Department',
          hintText: departmentState.selectedDepartment ?? 'Select Department',
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          departmentState.selectedDepartment ?? 'Select Department',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class BirthdateField extends StatelessWidget {
  final DateTime? selectedBirthdate;
  final Function(DateTime?) onDateSelected;

  const BirthdateField({super.key, this.selectedBirthdate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Birthdate',
        hintText: 'Select your birthdate',
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: selectedBirthdate != null
            ? '${selectedBirthdate!.day}/${selectedBirthdate!.month}/${selectedBirthdate!.year}'
            : '',
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) onDateSelected(pickedDate);
      },
      validator: (value) => selectedBirthdate == null ? 'Birthdate is required' : null,
    );
  }
}

List<DropdownMenuItem<String>> gender = ["Male", "Female"]
    .map<DropdownMenuItem<String>>((String value) {
  return DropdownMenuItem<String>(value: value, child: Text(value));
}).toList();

// Keep your showDepartmentBottomSheet function as is

void showDepartmentBottomSheet({
  required BuildContext context,
  required String title,
  required List<Map<String, dynamic>> departments,
  required String? selectedDepartment,
  required Function(String?) onSelected,
}) {
  String? tempSelectedDepartment = selectedDepartment;

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: departments.length,
                    itemBuilder: (BuildContext context, int index) {
                      final department = departments[index];
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text(department['name']),
                                  value: department['name'],
                                  groupValue: tempSelectedDepartment,
                                  onChanged: (String? value) {
                                    setState(() {
                                      tempSelectedDepartment = value;
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_drop_down),
                                onPressed: () {
                                  setState(() {
                                    department['isExpanded'] =
                                    !(department['isExpanded'] ?? false);
                                  });
                                },
                              ),
                            ],
                          ),
                          if (department['isExpanded'] ?? false)
                            ...department['programs'].map<Widget>(
                                  (program) => ListTile(
                                title: Text(
                                  program.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        onSelected(tempSelectedDepartment);
                        Navigator.pop(context);
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}