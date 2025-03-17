import 'package:budgeit/data/icons/sources/icons_api_service.dart';
import 'package:budgeit/domain/icons/repositories/icons.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

class IconsRepositoryImpl extends IconsRepository {
  @override
  Future<Either<String, List<String>>> getIcons(String collection) async {
    return await sl<IconsApiService>().getIcons(collection);
  }
}