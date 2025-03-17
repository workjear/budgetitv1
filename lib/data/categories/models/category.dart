
// Assuming CategoryType enum matches the C# enum
import '../../../core/enums/enums.dart';
import '../../categorystream/models/category_stream.dart';


class Category {
  final int categoriesId; // Changed to match CategoriesId
  final int userId;       // Kept as int, assuming API serializes as int
  final String name;      // Required
  final String color;     // Required
  final String icon;      // Required
  final double? budget;   // Nullable, converted from decimal
  final CategoryType type;// Enum instead of int
  final String createdBy; // From BaseEntity
  final DateTime createdDate; // From BaseEntity
  final String? modifiedBy;   // From BaseEntity
  final DateTime? modifiedDate; // From BaseEntity
  final List<CategoryStream>? categoryStreams; // Optional, if included in API response

  Category({
    required this.categoriesId,
    required this.userId,
    required this.name,
    required this.color,
    required this.icon,
    this.budget,
    required this.type,
    required this.createdBy,
    required this.createdDate,
    this.modifiedBy,
    this.modifiedDate,
    this.categoryStreams,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoriesId: json['categoriesId'],
      userId: json['userId'],
      name: json['name'],
      color: json['color'] ?? '', // Default to empty string if null (API should enforce non-null)
      icon: json['icon'] ?? '',   // Default to empty string if null
      budget: json['budget']?.toDouble(), // Convert decimal to double
      type: CategoryType.values[json['type']], // Map int to enum
      createdBy: json['createdBy'],
      createdDate: DateTime.parse(json['createdDate']),
      modifiedBy: json['modifiedBy'],
      modifiedDate: json['modifiedDate'] != null
          ? DateTime.parse(json['modifiedDate'])
          : null,
      categoryStreams: json['categoryStream'] != null
          ? (json['categoryStream'] as List)
          .map((stream) => CategoryStream.fromJson(stream))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'categoriesId': categoriesId,
    'userId': userId,
    'name': name,
    'color': color,
    'icon': icon,
    'budget': budget,
    'type': type.index, // Convert enum to int for API
    'createdBy': createdBy,
    'createdDate': createdDate.toIso8601String(),
    'modifiedBy': modifiedBy,
    'modifiedDate': modifiedDate?.toIso8601String(),
    'categoryStream': categoryStreams?.map((stream) => stream.toJson()).toList(),
  };
}