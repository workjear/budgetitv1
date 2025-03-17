import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../../../domain/categorystream/repositories/category_stream.dart';
import '../models/category_stream.dart';
import '../services/categorystream_api_services.dart';

class CategoryStreamRepositoryImpl implements CategoryStreamRepository {
  final CategoryStreamApiService _apiService = sl<CategoryStreamApiService>();

  @override
  Future<Either<Failure, List<CategoryStream>>> getCategoryStreamsById(
      int userId, String accessToken) async {
    return await _apiService.getCategoryStreamsById(userId, accessToken);
  }

  @override
  Future<Either<Failure, List<CategoryStream>>> getDailyCategoryStreamsById(
      int userId, String accessToken) async {
    return await _apiService.getDailyCategoryStreamsById(userId, accessToken);
  }

  @override
  Future<Either<Failure, List<CategoryStream>>> getWeeklyCategoryStreamsById(
      int userId, String accessToken) async {
    return await _apiService.getWeeklyCategoryStreamsById(userId, accessToken);
  }

  @override
  Future<Either<Failure, List<CategoryStream>>> getMonthlyCategoryStreamsById(
      int userId, String accessToken) async {
    return await _apiService.getMonthlyCategoryStreamsById(userId, accessToken);
  }

  @override
  Future<Either<Failure, List<CategoryStream>>> getByDateRangeCategoryStreamsById(
      int userId, DateTime start, DateTime end, String accessToken) async {
    return await _apiService.getByDateRangeCategoryStreamsById(userId, start, end, accessToken);
  }

  @override
  Future<Either<Failure, List<CategoryStream>>> getByDateCategoryStreamsById(
      int userId, DateTime date, String accessToken) async {
    return await _apiService.getByDateCategoryStreamsById(userId, date, accessToken);
  }

  @override
  Future<Either<Failure, String>> addStream(
      int categoryId, double stream, String notes, String accessToken) async {
    return await _apiService.addStream(categoryId, stream, notes, accessToken);
  }

  @override
  Future<Either<Failure, String>> editStream(
      int streamId, double stream, String notes, String accessToken) async {
    return await _apiService.editStream(streamId, stream, notes, accessToken);
  }

  @override
  Future<Either<Failure, String>> deleteStream(int streamId, String accessToken) async {
    return await _apiService.deleteStream(streamId, accessToken);
  }
}