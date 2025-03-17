import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/network/dio_client.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/category_stream.dart';

abstract class CategoryStreamApiService {
  Future<Either<Failure, List<CategoryStream>>> getCategoryStreamsById(
    int userId,
    String accessToken,
  );

  Future<Either<Failure, List<CategoryStream>>> getDailyCategoryStreamsById(
    int userId,
    String accessToken,
  );

  Future<Either<Failure, List<CategoryStream>>> getWeeklyCategoryStreamsById(
    int userId,
    String accessToken,
  );

  Future<Either<Failure, List<CategoryStream>>> getMonthlyCategoryStreamsById(
    int userId,
    String accessToken,
  );

  Future<Either<Failure, List<CategoryStream>>>
  getByDateRangeCategoryStreamsById(
    int userId,
    DateTime start,
    DateTime end,
    String accessToken,
  );

  Future<Either<Failure, List<CategoryStream>>> getByDateCategoryStreamsById(
    int userId,
    DateTime date,
    String accessToken,
  );

  Future<Either<Failure, String>> addStream(
    int categoryId,
    double stream,
    String notes,
    String accessToken,
  );

  Future<Either<Failure, String>> editStream(
    int streamId,
    double stream,
    String notes,
    String accessToken,
  );

  Future<Either<Failure, String>> deleteStream(
    int streamId,
    String accessToken,
  );
}

class CategoryStreamApiServiceImpl implements CategoryStreamApiService {
  final client = sl<DioClient>(instanceName: 'apiUrl');

  @override
  Future<Either<Failure, List<CategoryStream>>> getCategoryStreamsById(
      int userId,
      String accessToken,) async {
    try {
      final response = await client.get(
        '/api/Categories/getcategorystreamsbyid?userId=$userId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final streams =
      (response.data as List)
          .map((json) => CategoryStream.fromJson(json))
          .toList();
      return Right(streams);
    } on DioException catch (e) {
      return Left(
        Failure(e.response?.data['message'] ?? 'Failed to fetch streams'),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryStream>>> getDailyCategoryStreamsById(
      int userId,
      String accessToken,) async {
    try {
      final response = await client.get(
        '/api/Categories/getdailycategorystreamsbyid?userId=$userId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final streams =
      (response.data as List)
          .map((json) => CategoryStream.fromJson(json))
          .toList();
      return Right(streams);
    } on DioException catch (e) {
      return Left(
        Failure(e.response?.data['message'] ?? 'Failed to fetch daily streams'),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryStream>>> getWeeklyCategoryStreamsById(
      int userId,
      String accessToken,) async {
    try {
      final response = await client.get(
        '/api/Categories/getweeklycategorystreamsbyid?userId=$userId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final streams =
      (response.data as List)
          .map((json) => CategoryStream.fromJson(json))
          .toList();
      return Right(streams);
    } on DioException catch (e) {
      return Left(
        Failure(
          e.response?.data['message'] ?? 'Failed to fetch weekly streams',
        ),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryStream>>> getMonthlyCategoryStreamsById(
      int userId,
      String accessToken,) async {
    try {
      final response = await client.get(
        '/api/Categories/getmonthlycategorystreamsbyid?userId=$userId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final streams =
      (response.data as List)
          .map((json) => CategoryStream.fromJson(json))
          .toList();
      return Right(streams);
    } on DioException catch (e) {
      return Left(
        Failure(
          e.response?.data['message'] ?? 'Failed to fetch monthly streams',
        ),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryStream>>> getByDateRangeCategoryStreamsById(
      int userId, DateTime start, DateTime end, String accessToken) async {
    try {

      final response = await client.get(
        '/api/Categories/getbydaterangecategorystreamsbyid?userId=$userId&start=$start&end=$end',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data is List && (response.data as List).isEmpty) {
        print('API returned empty list');
        return const Right([]);
      }

      final streams = (response.data as List)
          .map((json) => CategoryStream.fromJson(json))
          .toList();

      return Right(streams);
    } on DioException catch (e) {
      return Left(
        Failure(
          e.response?.data['message'] ??
              'Failed to fetch streams by date range',
        ),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryStream>>> getByDateCategoryStreamsById(
      int userId,
      DateTime date,
      String accessToken,) async {
    try {
      final response = await client.get(
        '/api/Categories/getbydatecategorystreamsbyid?userId=$userId&date=${date
            .toIso8601String()}',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final streams =
      (response.data as List)
          .map((json) => CategoryStream.fromJson(json))
          .toList();
      return Right(streams);
    } on DioException catch (e) {
      return Left(
        Failure(
          e.response?.data['message'] ?? 'Failed to fetch streams by date',
        ),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addStream(int categoryId,
      double stream,
      String notes,
      String accessToken,) async {
    try {
      final response = await client.post(
        '/api/Categories/addstream?categoryId=$categoryId&stream=$stream&notes=$notes',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return Right(response.data as String);
    } on DioException catch (e) {
      print('DioException: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage;
      switch (e.response?.statusCode) {
        case 400:
          errorMessage = e.response?.data['message'] ?? 'Failed to add stream';
          break;
        case 401:
          errorMessage = 'Unauthorized: Invalid token or permissions';
          break;
        case 404:
          errorMessage = e.response?.data ?? 'Category or user not found';
          break;
        default:
          errorMessage = 'Failed to add stream: ${e.message}';
      }
      return Left(Failure(errorMessage));
    } catch (e) {
      print('Unexpected error: $e');
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> editStream(int streamId,
      double stream,
      String notes,
      String accessToken,) async {
    try {
      final response = await client.post(
        '/api/Categories/editstream',
        data: {'StreamId': streamId, 'Stream': stream, 'Notes': notes},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return Right(response.data as String);
    } on DioException catch (e) {
      print('DioException: ${e.response?.statusCode} - ${e.response?.data}');
      final errorMessage = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Failed to delete stream'
          : e.response?.data?.toString() ??
          'Failed to delete stream: ${e.message}';
      return Left(Failure(errorMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteStream(int streamId,
      String accessToken) async {
    try {
      final response = await client.post(
        '/api/Categories/deletestream?streamId=$streamId',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          contentType: 'application/json', // Ensure JSON content type
        ),
      );

      // Log the response for debugging
      print('Delete Stream Response: ${response.data}');

      // Handle the response
      if (response.data is String) {
        return Right(
            response.data as String); // Expecting "Success" from server
      } else {
        return Right('Stream deleted successfully'); // Fallback
      }
    } on DioException catch (e) {
      print('DioException: ${e.response?.statusCode} - ${e.response?.data}');
      final errorMessage = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Failed to delete stream'
          : e.response?.data?.toString() ??
          'Failed to delete stream: ${e.message}';
      return Left(Failure(errorMessage));
    } catch (e) {
      return Left(Failure('Unexpected error: $e'));
    }
  }
}
