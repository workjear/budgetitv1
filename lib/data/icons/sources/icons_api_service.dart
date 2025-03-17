import 'package:budgeit/core/network/dio_client.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

abstract class IconsApiService {
  Future<Either<String, List<String>>> getIcons(String collection);
}

class IconsApiServiceImpl extends IconsApiService {
  final _dioClient = sl<DioClient>(instanceName: 'iconsClient');

  @override
  Future<Either<String, List<String>>> getIcons(String collection) async {
    try {
      var response = await _dioClient.get('collection?prefix=$collection');
      final responseData = response.data as Map<String, dynamic>;
      final categories = responseData['categories'] as Map<String, dynamic>;
      final iconsList = categories.values.expand((category) => category).cast<String>().toList();
      return Right(iconsList);
    } on DioException catch (e) {
      return Left(e.response?.data?.toString() ?? 'Failed to load icons');
    }
  }
}