import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/domain/icons/repositories/icons.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

// GetIconsUseCase
class GetIconsUseCase extends UseCase<Either<String, List<String>>, String> {
  @override
  Future<Either<String, List<String>>> call({String? params}) async {
    return await sl<IconsRepository>().getIcons(params!);
  }
}
