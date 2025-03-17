import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/network/dio_client.dart';
import 'package:budgeit/data/categories/models/category.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

abstract class CategoryApiService {
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

class CategoryApiServiceImpl implements CategoryApiService {
  final client = sl<DioClient>(instanceName: 'apiUrl');

  @override
  Future<Either<Failure, List<Category>>> getCategoriesById(
    int userId,
    String accessToken,
  ) async {
    try {
      final response = await client.get(
        '/api/Categories/getcategoriesById?userId=$userId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final categories =
          (response.data as List)
              .map((json) => Category.fromJson(json))
              .toList();
      return Right(categories);
    } on DioException catch (e) {
      return Left(
        Failure(e.response?.data['message'] ?? 'Failed to fetch categories'),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addCategory(
      int userId,
      String name,
      String icon,
      int type,
      String accessToken,
      ) async {
    try {
      final payload = {
        'userId': userId,
        'name': name,
        'icon': icon, // Send icon name
        'type': type,
      };
      print('Sending request: $payload'); // Debug log
      final response = await client.post(
        '/api/Categories/addcategory',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return Right(response.data as String);
    } on DioException catch (e) {
      print('DioException: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      return Left(
        Failure(e.response?.data['message'] ?? 'Failed to add category'),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateCategory(
    int categoryId,
    String name,
    String icon,
    double? budget,
    int type,
    String accessToken,
  ) async {
    try {
      final response = await client.post(
        '/api/Categories/updatecategory',
        data: {
          'categoryId': categoryId,
          'name': name,
          'icon': icon,
          'budget': budget,
          'type': type,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return Right(response.data as String);
    } on DioException catch (e) {
      return Left(
        Failure(e.response?.data['message'] ?? 'Failed to update category'),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(int categoryId, String accessToken) async {
    try {
      // Try with a clear JSON body
      final response = await client.post(
        '/api/Categories/deletecategory?categoryId=$categoryId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Right(true);
      } else {
        return Left(Failure('Failed to delete category: ${response.statusCode}'));
      }
    } catch (e) {
      print('Delete category error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
