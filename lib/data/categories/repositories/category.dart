import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/data/categories/models/category.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../../../domain/categories/repositories/category.dart';
import '../services/categoty_api_services.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryApiService _apiService = sl<CategoryApiService>();

  @override
  Future<Either<Failure, List<Category>>> getCategoriesById(int userId, String accessToken) async {
    return await _apiService.getCategoriesById(userId, accessToken);
  }

  @override
  Future<Either<Failure, String>> addCategory(
      int userId, String name, String icon, int type, String accessToken) async {
    return await _apiService.addCategory(userId, name, icon, type, accessToken);
  }

  @override
  Future<Either<Failure, String>> updateCategory(
      int categoryId, String name, String icon, double? budget, int type, String accessToken) async {
    return await _apiService.updateCategory(categoryId, name, icon, budget, type, accessToken);
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(int categoryId, String accessToken) async {
    return await _apiService.deleteCategory(categoryId, accessToken);
  }
}