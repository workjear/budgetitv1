import 'package:dartz/dartz.dart';

abstract class IconsRepository{
  Future<Either<String, List<String>>> getIcons(String collection);
}