import 'package:budgeit/core/enums/enums.dart';

class CategoryStream {
  final int categoryStreamId;
  final int categoriesId;
  final double stream;
  final String? notes;
  final String createdBy;
  final DateTime createdDate;
  final String? modifiedBy;
  final DateTime? modifiedDate;
  final String? categoryName;
  final String? categoryIcon;
  final int? type;

  CategoryStream({
    required this.categoryStreamId,
    required this.categoriesId,
    required this.stream,
    this.notes,
    required this.createdBy,
    required this.createdDate,
    this.modifiedBy,
    this.modifiedDate,
    this.categoryName,
    this.categoryIcon,
    this.type
  });

  factory CategoryStream.fromJson(Map<String, dynamic> json) {
    return CategoryStream(
      categoryStreamId: json['categoryStreamId'] ?? 0,
      categoriesId: json['categoriesId'] ?? 0,
      stream:
          (json['stream'] is int)
              ? (json['stream'] as int).toDouble()
              : (json['stream'] ?? 0.0),
      notes: json['notes'],
      createdBy: json['createdBy'] ?? '',
      createdDate:
          json['createdDate'] != null
              ? DateTime.parse(json['createdDate'])
              : DateTime.now(),
      modifiedBy: json['modifiedBy'],
      modifiedDate:
          json['modifiedDate'] != null
              ? DateTime.parse(json['modifiedDate'])
              : null,
      categoryName: json['categoryName'],
      categoryIcon: json['categoryIcon'],
      type: json['type']
    );
  }

  Map<String, dynamic> toJson() => {
    'categoryStreamId': categoryStreamId,
    'categoriesId': categoriesId,
    'stream': stream,
    'notes': notes,
    'createdBy': createdBy,
    'createdDate': createdDate.toIso8601String(),
    'modifiedBy': modifiedBy,
    'modifiedDate': modifiedDate?.toIso8601String(),
    'categoryName': categoryName,
    'categoryIcon': categoryIcon,
    'type': type
  };
}
