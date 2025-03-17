import 'package:budgeit/domain/auth/entities/user.dart';
import 'package:budgeit/presentation/profile/bloc/profile_cubit.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../common/helper/toast/toast.dart';

class ProfilePage extends StatelessWidget {
  final String accessToken;
  final UserEntity userData;

  const ProfilePage({
    super.key,
    required this.accessToken,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>(),
      child: ProfileView(
        accessToken: accessToken,
        userData: userData,
      ),
    );
  }
}

class ProfileView extends StatefulWidget {
  final String accessToken;
  final UserEntity userData;

  const ProfileView({
    super.key,
    required this.accessToken,
    required this.userData,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late TextEditingController _fullNameController;
  late TextEditingController _birthdateController;
  late TextEditingController _passwordController;
  late String _selectedGender;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.userData.fullName);
    _birthdateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.userData.birthdate),
    );
    _passwordController = TextEditingController(text: '********');
    _selectedGender = widget.userData.gender;

    context.read<ProfileCubit>().loadUserProfile(
      userId: int.parse(widget.userData.id),
      fullName: widget.userData.fullName,
      gender: widget.userData.gender,
      birthdate: DateFormat('yyyy-MM-dd').format(widget.userData.birthdate),
      accessToken: widget.accessToken,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthdateController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_birthdateController.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _passwordController.text = '********';
        _fullNameController.text = widget.userData.fullName;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(widget.userData.birthdate);
        _selectedGender = widget.userData.gender;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final id = int.parse(widget.userData.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditMode ? 'Edit Profile' : 'Profile'),
        backgroundColor: colorScheme.surfaceContainerHighest,
        actions: [
          if (_isEditMode) ...[
            Tooltip(
              message: 'Update',
              child: TextButton(
                onPressed: () {
                  context.read<ProfileCubit>().updateProfile(
                    userId: id,
                    fullName: _fullNameController.text,
                    gender: _selectedGender,
                    birthdate: _birthdateController.text,
                    accessToken: widget.accessToken,
                  );
                },
                child: Text(
                  'Update',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ),
            Tooltip(
              message: 'Cancel',
              child: TextButton(
                onPressed: _toggleEditMode,
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ),
          ] else ...[
            Tooltip(
              message: 'Edit',
              child: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: colorScheme.primary,
                ),
                onPressed: _toggleEditMode,
              ),
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileSuccess) {
              ToastHelper.showSuccess(
                context: context,
                title: 'Success',
                description: 'Profile updated successfully',
              );
              setState(() {
                _isEditMode = false;
              });
            } else if (state is ProfileError) {
              ToastHelper.showError(
                context: context,
                title: 'Error',
                description: state.message,
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Personal Information'),
                  const SizedBox(height: 8),
                  _buildField(
                    icon: Icons.person_outline,
                    label: 'Name',
                    value: _fullNameController.text,
                    isEditable: _isEditMode,
                    child: TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const Divider(),
                  _buildField(
                    icon: Icons.people_outline,
                    label: 'Gender',
                    value: _selectedGender,
                    isEditable: _isEditMode,
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                  const Divider(),
                  _buildField(
                    icon: Icons.calendar_today_outlined,
                    label: 'Birthdate',
                    value: _birthdateController.text,
                    isEditable: _isEditMode,
                    child: TextField(
                      controller: _birthdateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        hintText: 'YYYY-MM-DD',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: const Icon(Icons.event),
                      ),
                    ),
                  ),
                  const Divider(),
                  _buildField(
                    icon: Icons.school_outlined,
                    label: 'Enrolled Program',
                    value: widget.userData.enrolledProgram ?? 'Not enrolled in any program',
                    isEditable: false,
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Account Information'),
                  const SizedBox(height: 8),
                  _buildField(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: widget.userData.email,
                    isEditable: false,
                  ),
                  const Divider(),
                  _buildField(
                    icon: Icons.lock_outline,
                    label: 'Password',
                    value: _passwordController.text,
                    isEditable: _isEditMode,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: const Icon(Icons.visibility_off),
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required String value,
    required bool isEditable,
    Widget? child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          isEditable && child != null
              ? child
              : Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}