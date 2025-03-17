import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:dartz/dartz.dart';

import '../../../data/categorystream/models/category_stream.dart';

abstract class CategoryStreamRepository {
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

  Future<Either<Failure, List<CategoryStream>>>getByDateRangeCategoryStreamsById(
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
