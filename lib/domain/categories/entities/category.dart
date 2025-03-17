class CategoryEntity {
  final int userId;
  final String name;
  final String? color;
  final double? budget;
  final int type;
  final String? icon;
  final String createdBy;
  final DateTime createdDate;
  final String? modifiedBy;
  final DateTime? modifiedDate;

  CategoryEntity({
    required this.userId,
    required this.name,
    this.color,
    this.budget,
    required this.type,
    this.icon,
    required this.createdBy,
    required this.createdDate,
    this.modifiedBy,
    this.modifiedDate,
  });
}