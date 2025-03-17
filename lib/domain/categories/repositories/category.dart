import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/data/categories/models/category.dart';
import 'package:dartz/dartz.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategoriesById(
    int userId,
    String accessToken,
  );

  Future<Either<Failure, String>> addCategory(
    int userId,
    String name,
    String icon,
    int type,
    String accessToken,
  );

  Future<Either<Failure, String>> updateCategory(
    int categoryId,
    String name,
    String icon,
    double? budget,
    int type,
    String accessToken,
  );

  Future<Either<Failure, bool>> deleteCategory(
    int categoryId,
    String accessToken,
  );
}
