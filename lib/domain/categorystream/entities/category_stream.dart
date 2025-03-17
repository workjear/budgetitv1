class CategoryStreamEntity {
  final int categoriesId;
  final double stream;
  final String? notes;
  final String createdBy;
  final DateTime createdDate;
  final String? modifiedBy;
  final DateTime? modifiedDate;

  CategoryStreamEntity({
    required this.categoriesId,
    required this.stream,
    this.notes,
    required this.createdBy,
    required this.createdDate,
    this.modifiedBy,
    this.modifiedDate,
  });
}