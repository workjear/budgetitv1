class DepartmentState {
  final List<Map<String, dynamic>> departments;
  final String? selectedDepartment;

  DepartmentState({required this.departments, this.selectedDepartment});

  DepartmentState copyWith({List<Map<String, dynamic>>? departments, String? selectedDepartment}) {
    return DepartmentState(
      departments: departments ?? this.departments,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
    );
  }
}