enum CategoryType {
  personalExpense(0),
  educationalExpense(1),
  income(2);

  final int value;
  const CategoryType(this.value);

  static CategoryType fromValue(int value) {
    return CategoryType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => CategoryType.personalExpense, // Default fallback
    );
  }
}